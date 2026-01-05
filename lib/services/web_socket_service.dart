// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  static StompClient? _stompClient;
  static Timer? _reconnectionTimer;
  static Timer? _healthCheckTimer;
  static Timer? _connectionTimeoutTimer;

  static DateTime? _lastMessageReceived;
  static DateTime? _lastHeartbeatReceived;
  static String? _currentCounterId;
  static Function(List<dynamic> data)? _onUpcomingUpdate;
  static Function(Map<String, dynamic> counter)? _onCounterUpdate;
  static Function(String message, bool isError)? _onConnectionStatus;

  static int _reconnectAttempts = 0;
  static bool _isWebSocketConnected = false;
  static bool _isConnecting = false;
  static bool _shouldReconnect = true;
  static bool _hasNotifiedUser = false;

  // Configuration
  static const int MAX_RECONNECT_ATTEMPTS = 10;
  static const Duration HEALTH_CHECK_INTERVAL = Duration(minutes: 1);
  static const Duration HEARTBEAT_TIMEOUT = Duration(minutes: 3);
  static const Duration MESSAGE_TIMEOUT = Duration(minutes: 10);
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 10);

  static bool get isConnected => _isWebSocketConnected;
  static DateTime? get lastMessageReceived => _lastMessageReceived;
  static int get reconnectAttempts => _reconnectAttempts;

  /// Connect to WebSocket with callbacks
  static Future<void> connect({
    required String counterId,
    required Function(List<dynamic>) onUpcomingUpdate,
    required Function(Map<String, dynamic>) onCounterUpdate,
    Function(String message, bool isError)? onConnectionStatus,
  }) async {
    _currentCounterId = counterId;
    _onUpcomingUpdate = onUpcomingUpdate;
    _onCounterUpdate = onCounterUpdate;
    _onConnectionStatus = onConnectionStatus;
    _shouldReconnect = true;
    _hasNotifiedUser = false;

    await _connectWebSocket();
    _startHealthCheck();
  }

  static void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _lastMessageReceived = DateTime.now();
    _lastHeartbeatReceived = DateTime.now();

    _healthCheckTimer = Timer.periodic(HEALTH_CHECK_INTERVAL, (timer) {
      // Don't run health checks if we've exceeded max reconnect attempts
      if (_reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
        debugPrint(
          '[WS] ${DateTime.now()} [WARN] Max reconnect attempts reached - stopping health checks',
        );
        _healthCheckTimer?.cancel();
        _healthCheckTimer = null;
        return;
      }

      // Only run health checks if we think we're connected
      if (!_isWebSocketConnected) {
        debugPrint(
          '[WS] ${DateTime.now()} [DEBUG] Not connected - skipping health check',
        );
        return;
      }

      final now = DateTime.now();
      final timeSinceLastHeartbeat = now.difference(
        _lastHeartbeatReceived ?? now,
      );
      final timeSinceLastMessage = now.difference(_lastMessageReceived ?? now);

      debugPrint(
        '[WS] ${DateTime.now()} [INFO] Health check - Connected: $_isWebSocketConnected, '
        'Last heartbeat: ${timeSinceLastHeartbeat.inSeconds}s ago, '
        'Last message: ${timeSinceLastMessage.inSeconds}s ago',
      );

      // Check heartbeat first (most reliable indicator)
      if (timeSinceLastHeartbeat > HEARTBEAT_TIMEOUT) {
        debugPrint(
          '[WS] ${DateTime.now()} [WARN] Heartbeat timeout (${timeSinceLastHeartbeat.inSeconds}s) - scheduling reconnect',
        );
        _reconnectWebSocket();
        return;
      }

      // Log warning if no business messages for a while
      if (timeSinceLastMessage > MESSAGE_TIMEOUT) {
        debugPrint(
          '[WS] ${DateTime.now()} [WARN] No messages received for ${timeSinceLastMessage.inMinutes} minutes',
        );
      }
    });
  }

  static Future<void> _connectWebSocket() async {
    if (_isConnecting) {
      debugPrint(
        '[WS] ${DateTime.now()} [DEBUG] WebSocket connection already in progress, skipping',
      );
      return;
    }

    _isConnecting = true;
    _reconnectionTimer?.cancel(); // Cancel any pending reconnection
    _connectionTimeoutTimer?.cancel();

    // Set connection timeout
    _connectionTimeoutTimer = Timer(CONNECTION_TIMEOUT, () {
      if (_isConnecting) {
        debugPrint(
          '[WS] ${DateTime.now()} [ERROR] ⏱️ WebSocket connection timeout',
        );
        _isConnecting = false;
        _stompClient?.deactivate();
        _stompClient = null;
        _scheduleReconnection();
      }
    });

    // Clean up existing connection
    if (_stompClient != null) {
      debugPrint(
        '[WS] ${DateTime.now()} [INFO] Deactivating existing WebSocket connection',
      );
      try {
        _stompClient?.deactivate();
        await Future.delayed(Duration(milliseconds: 300)); // Give time to close
      } catch (e) {
        debugPrint(
          '[WS] ${DateTime.now()} [ERROR] Error during WebSocket deactivation: $e',
        );
      }
      _stompClient = null;
    }

    debugPrint(
      '[WS] ${DateTime.now()} [INFO] Initializing WebSocket connection to ${ApiConstants.wsUrl}',
    );

    _stompClient = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        onConnect: (StompFrame frame) async {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;
          _isWebSocketConnected = true;
          _lastMessageReceived = DateTime.now();
          _lastHeartbeatReceived = DateTime.now();
          _reconnectAttempts = 0;
          _hasNotifiedUser = false;

          debugPrint(
            '[WS] ${DateTime.now()} [SUCCESS] ✅ WebSocket connected for counter: $_currentCounterId',
          );

          // Notify user of successful connection
          _onConnectionStatus?.call('Connected to server', false);

          // Subscribe to upcoming queue updates
          _stompClient?.subscribe(
            destination: '/topic/agent-upcoming/$_currentCounterId',
            callback: (StompFrame frame) {
              _lastMessageReceived = DateTime.now();
              _reconnectAttempts = 0;

              debugPrint(
                '[WS] ${DateTime.now()} [INFO] 📨 Upcoming queue message received',
              );

              if (frame.body != null && frame.body!.isNotEmpty) {
                try {
                  final decoded = json.decode(frame.body!);
                  if (decoded is List) {
                    _onUpcomingUpdate?.call(List<dynamic>.from(decoded));
                  }
                } catch (e) {
                  debugPrint(
                    '[WS] ${DateTime.now()} [ERROR] Error parsing upcoming queue message: $e',
                  );
                }
              }
            },
          );

          // Subscribe to counter status updates
          _stompClient?.subscribe(
            destination: '/topic/counter/$_currentCounterId',
            callback: (StompFrame frame) {
              _lastMessageReceived = DateTime.now();
              _reconnectAttempts = 0;

              debugPrint(
                '[WS] ${DateTime.now()} [INFO] 📨 Counter status message received',
              );

              if (frame.body != null && frame.body!.isNotEmpty) {
                try {
                  final decoded = json.decode(frame.body!);
                  if (decoded is Map<String, dynamic>) {
                    _onCounterUpdate?.call(decoded);
                  }
                } catch (e) {
                  debugPrint(
                    '[WS] ${DateTime.now()} [ERROR] Error parsing counter message: $e',
                  );
                }
              }
            },
          );

          // Subscribe to global heartbeat topic
          _stompClient?.subscribe(
            destination: '/topic/heartbeat',
            callback: (StompFrame frame) {
              _lastHeartbeatReceived = DateTime.now();
              debugPrint('[WS] ${DateTime.now()} [INFO] 💓 Heartbeat received');
            },
          );

          debugPrint(
            '[WS] ${DateTime.now()} [SUCCESS] ✅ All subscriptions completed',
          );
        },
        onWebSocketError: (dynamic error) {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;
          _isWebSocketConnected = false;
          debugPrint(
            '[WS] ${DateTime.now()} [ERROR] ❌ WebSocket error: $error',
          );
          _scheduleReconnection();
        },
        onStompError: (StompFrame frame) {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;
          _isWebSocketConnected = false;
          debugPrint(
            '[WS] ${DateTime.now()} [ERROR] ❌ STOMP error: ${frame.body}',
          );
          _scheduleReconnection();
        },
        onDisconnect: (StompFrame frame) {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;

          if (_isWebSocketConnected) {
            debugPrint(
              '[WS] ${DateTime.now()} [WARN] ⚠️ WebSocket disconnected unexpectedly',
            );
            _isWebSocketConnected = false;
            _scheduleReconnection();
          }
        },
        beforeConnect: () async {
          debugPrint(
            '[WS] ${DateTime.now()} [INFO] Attempting WebSocket connection...',
          );
        },
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
        heartbeatIncoming: Duration(seconds: 60),
        heartbeatOutgoing: Duration(seconds: 60),
        reconnectDelay: Duration.zero,
        connectionTimeout: CONNECTION_TIMEOUT, // Add this
      ),
    );

    debugPrint('[WS] ${DateTime.now()} [INFO] Activating STOMP client...');

    try {
      _stompClient?.activate();
    } catch (e) {
      debugPrint(
        '[WS] ${DateTime.now()} [ERROR] Failed to activate STOMP client: $e',
      );
      _isConnecting = false;
      _scheduleReconnection();
    }
  }

  static Future<void> _reconnectWebSocket() async {
    debugPrint(
      '[WS] ${DateTime.now()} [WARN] 🔄 Forcing WebSocket reconnection (attempt $_reconnectAttempts)',
    );
    _isWebSocketConnected = false;
    _isConnecting = false;
    await _connectWebSocket();
  }

  static void _scheduleReconnection() {
    if (!_shouldReconnect || _isConnecting) {
      return;
    }

    // Cancel any existing reconnection timer
    _reconnectionTimer?.cancel();

    if (_reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      debugPrint(
        '[WS] ${DateTime.now()} [ERROR] ⛔ MAX reconnection attempts ($MAX_RECONNECT_ATTEMPTS) reached',
      );

      // Stop health check timer
      _healthCheckTimer?.cancel();
      _healthCheckTimer = null;

      // Notify user once
      if (!_hasNotifiedUser) {
        _onConnectionStatus?.call(
          'Unable to connect to server after $MAX_RECONNECT_ATTEMPTS attempts. '
          'Please check your connection and tap retry.',
          true, // isError = true
        );
        _hasNotifiedUser = true;
      }

      return;
    }

    // Notify user after 3 failed attempts
    if (_reconnectAttempts == 3 && !_hasNotifiedUser) {
      _onConnectionStatus?.call(
        'Having trouble connecting to the server. Retrying...',
        true, // isError = true
      );
      _hasNotifiedUser = true;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: (5 * _reconnectAttempts).clamp(5, 30));

    debugPrint(
      '[WS] ${DateTime.now()} [INFO] ⏰ Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s',
    );

    _reconnectionTimer = Timer(delay, () async {
      if (_shouldReconnect && !_isConnecting) {
        await _connectWebSocket();
      }
    });
  }

  /// Handle app resume from background
  static Future<void> onAppResumed() async {
    debugPrint('[WS] ${DateTime.now()} [INFO] 📱 App resumed from background');

    if (!_isWebSocketConnected && _currentCounterId != null) {
      // Reset attempts on app resume to give it a fresh start
      if (_reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
        debugPrint(
          '[WS] ${DateTime.now()} [INFO] Resetting reconnection attempts on app resume',
        );
        _reconnectAttempts = 0;
        _hasNotifiedUser = false;
      }
      await _reconnectWebSocket();
      _startHealthCheck();
    }
  }

  /// Manually reconnect (useful for retry buttons)
  static Future<void> reconnect() async {
    if (_currentCounterId == null) {
      debugPrint(
        '[WS] ${DateTime.now()} [ERROR] Cannot reconnect: no counter ID set',
      );
      return;
    }

    debugPrint(
      '[WS] ${DateTime.now()} [INFO] 🔄 Manual reconnection requested',
    );

    // Reset reconnection state for manual retry
    _reconnectAttempts = 0;
    _hasNotifiedUser = false;
    _lastMessageReceived = DateTime.now();
    _lastHeartbeatReceived = DateTime.now();

    await _reconnectWebSocket();
    _startHealthCheck();
  }

  /// Reset and retry after max attempts reached (for manual retry button)
  static Future<void> resetAndRetry() async {
    debugPrint(
      '[WS] ${DateTime.now()} [INFO] 🔄 Reset and retry - clearing reconnection state',
    );

    // CRITICAL: Cancel ALL timers first
    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;

    // Reset state
    _reconnectAttempts = 0;
    _hasNotifiedUser = false;
    _lastMessageReceived = DateTime.now();
    _lastHeartbeatReceived = DateTime.now();
    _isConnecting = false;
    _isWebSocketConnected = false;

    // Clean up existing connection
    if (_stompClient != null) {
      try {
        _stompClient?.deactivate();
        await Future.delayed(
          Duration(milliseconds: 500),
        ); // Give time to deactivate
      } catch (e) {
        debugPrint(
          '[WS] ${DateTime.now()} [WARN] Error during deactivation: $e',
        );
      }
      _stompClient = null;
    }

    if (_currentCounterId != null) {
      // Add a small delay to ensure cleanup is complete
      await Future.delayed(Duration(milliseconds: 300));

      await _connectWebSocket();
      _startHealthCheck();
    } else {
      debugPrint(
        '[WS] ${DateTime.now()} [ERROR] Cannot reset and retry: no counter ID set',
      );
    }
  }

  /// Disconnect and cleanup
  static void disconnect() {
    debugPrint(
      '[WS] ${DateTime.now()} [INFO] 🔌 Disconnecting WebSocket service',
    );

    _shouldReconnect = false;
    _healthCheckTimer?.cancel();
    _reconnectionTimer?.cancel();
    _connectionTimeoutTimer?.cancel();
    _stompClient?.deactivate();

    _healthCheckTimer = null;
    _reconnectionTimer = null;
    _connectionTimeoutTimer = null;
    _stompClient = null;

    _isWebSocketConnected = false;
    _isConnecting = false;
    _currentCounterId = null;
    _onUpcomingUpdate = null;
    _onCounterUpdate = null;
    _onConnectionStatus = null;
    _reconnectAttempts = 0;
    _hasNotifiedUser = false;

    debugPrint(
      '[WS] ${DateTime.now()} [SUCCESS] ✅ WebSocket disconnected and cleaned up',
    );
  }

  /// Get connection status information for debugging
  static Map<String, dynamic> getDebugInfo() {
    return {
      'isConnected': _isWebSocketConnected,
      'isConnecting': _isConnecting,
      'shouldReconnect': _shouldReconnect,
      'counterId': _currentCounterId,
      'reconnectAttempts': _reconnectAttempts,
      'maxReconnectAttempts': MAX_RECONNECT_ATTEMPTS,
      'lastMessageReceived': _lastMessageReceived?.toIso8601String(),
      'lastHeartbeatReceived': _lastHeartbeatReceived?.toIso8601String(),
      'hasNotifiedUser': _hasNotifiedUser,
    };
  }
}
