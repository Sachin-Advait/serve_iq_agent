import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static WebSocketChannel? _channel;
  static bool _isConnected = false;
  static bool _isIntentionalDisconnect = false;
  static bool _isSubscribed = false;
  static Timer? _reconnectTimer;
  static Timer? _heartbeatTimer;
  static int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _reconnectDelay = Duration(seconds: 5);

  // Store connection parameters for reconnection
  static String? _counterId;
  static Function(List<dynamic> data)? _onUpcomingUpdate;
  static StreamSubscription? _streamSubscription;

  // Message deduplication
  static final Set<String> _processedMessageIds = {};
  static const int _maxCachedMessageIds = 100;

  static void connect({
    required String counterId,
    required Function(List<dynamic> data) onUpcomingUpdate,
  }) {
    // Store parameters for reconnection
    _counterId = counterId;
    _onUpcomingUpdate = onUpcomingUpdate;
    _isIntentionalDisconnect = false;

    // Disconnect existing connection if any
    if (_isConnected) {
      _cleanup();
    }

    _connectInternal();
  }

  static void _connectInternal() {
    if (_counterId == null || _onUpcomingUpdate == null) {
      debugPrint("Cannot connect: missing connection parameters");
      return;
    }

    try {
      // Cancel any existing stream subscription
      _streamSubscription?.cancel();
      _streamSubscription = null;
      _isSubscribed = false;

      debugPrint("Attempting WebSocket connection to ${ApiConstants.wsUrl}");

      final wsUri = Uri.parse(ApiConstants.wsUrl);
      _channel = WebSocketChannel.connect(wsUri);
      _isConnected = true;

      debugPrint(
        "WebSocket Connected for counter: $_counterId (Attempt ${_reconnectAttempts + 1})",
      );

      // Send STOMP CONNECT frame
      final connectFrame =
          'CONNECT\naccept-version:1.0,1.1,2.0\nheart-beat:10000,10000\n\n\x00';
      _channel!.sink.add(connectFrame);

      // Start heartbeat timer
      _startHeartbeat();

      // Listen to messages
      _streamSubscription = _channel!.stream.listen(
        (message) {
          try {
            final messageStr = message.toString();
            debugPrint("Raw WebSocket message received");

            // Parse STOMP frames
            if (messageStr.startsWith('CONNECTED')) {
              debugPrint("STOMP Connected successfully");
              _reconnectAttempts = 0; // Reset on successful connection

              // Only subscribe if not already subscribed
              if (!_isSubscribed) {
                final subscribeFrame =
                    'SUBSCRIBE\nid:sub-0\ndestination:/topic/agent-upcoming/$_counterId\n\n\x00';
                _channel!.sink.add(subscribeFrame);
                _isSubscribed = true;
                debugPrint("Subscribed to /topic/agent-upcoming/$_counterId");
              }
            } else if (messageStr.startsWith('MESSAGE')) {
              // Extract message-id for deduplication
              final messageIdMatch = RegExp(
                r'message-id:([^\n]+)',
              ).firstMatch(messageStr);
              final messageId = messageIdMatch?.group(1)?.trim();

              // Skip if we've already processed this message
              if (messageId != null &&
                  _processedMessageIds.contains(messageId)) {
                debugPrint("Duplicate message detected, skipping: $messageId");
                return;
              }

              // Extract the body from STOMP MESSAGE frame
              final bodyStart = messageStr.indexOf('\n\n') + 2;
              final bodyEnd = messageStr.indexOf('\x00', bodyStart);

              if (bodyStart > 1 && bodyEnd > bodyStart) {
                final body = messageStr.substring(bodyStart, bodyEnd);

                if (body.isNotEmpty) {
                  final decodedData = jsonDecode(body);

                  if (decodedData is List) {
                    debugPrint(
                      "Received ${decodedData.length} tokens via WebSocket",
                    );

                    // Mark message as processed
                    if (messageId != null) {
                      _processedMessageIds.add(messageId);

                      // Keep cache size manageable
                      if (_processedMessageIds.length > _maxCachedMessageIds) {
                        final toRemove =
                            _processedMessageIds.length - _maxCachedMessageIds;
                        _processedMessageIds.removeAll(
                          _processedMessageIds.take(toRemove),
                        );
                      }
                    }

                    _onUpcomingUpdate?.call(List<dynamic>.from(decodedData));
                  }
                }
              }
            }
          } catch (e, stackTrace) {
            debugPrint("Error processing WebSocket message: $e");
            debugPrint("StackTrace: $stackTrace");
          }
        },
        onError: (error) {
          debugPrint("WebSocket Error: $error");
          _isConnected = false;
          _isSubscribed = false;
          _handleDisconnection();
        },
        onDone: () {
          debugPrint("WebSocket Disconnected");
          _isConnected = false;
          _isSubscribed = false;
          _handleDisconnection();
        },
        cancelOnError: false, // Changed to false to allow reconnection
      );
    } catch (e) {
      debugPrint("Failed to connect WebSocket: $e");
      _isConnected = false;
      _isSubscribed = false;
      _handleDisconnection();
    }
  }

  static void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add('\n');
          debugPrint("Heartbeat sent");
        } catch (e) {
          debugPrint("Heartbeat failed: $e");
          _handleDisconnection();
        }
      }
    });
  }

  static void _handleDisconnection() {
    debugPrint("_handleDisconnection called");

    // Stop heartbeat
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    // Cancel any existing reconnect timer
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // Don't reconnect if it was an intentional disconnect
    if (_isIntentionalDisconnect) {
      debugPrint("Intentional disconnect, not reconnecting");
      return;
    }

    // Don't reconnect if connection parameters are missing
    if (_counterId == null || _onUpcomingUpdate == null) {
      debugPrint("Missing connection parameters, cannot reconnect");
      return;
    }

    // Don't reconnect if max attempts reached
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint(
        "Max reconnection attempts ($_maxReconnectAttempts) reached. Giving up.",
      );
      return;
    }

    // Schedule reconnection
    _reconnectAttempts++;
    debugPrint(
      "⏱️ Scheduling reconnection attempt $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds} seconds...",
    );

    _reconnectTimer = Timer(_reconnectDelay, () {
      debugPrint(
        "🔄 Attempting to reconnect (Attempt $_reconnectAttempts/$_maxReconnectAttempts)...",
      );
      _connectInternal();
    });
  }

  static void _cleanup() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _isSubscribed = false;

    if (_channel != null) {
      try {
        _channel!.sink.close();
      } catch (e) {
        debugPrint("Error closing channel: $e");
      }
      _channel = null;
    }
  }

  static void disconnect() {
    debugPrint("🛑 Manual disconnect requested");
    _isIntentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // Cancel stream subscription
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _isSubscribed = false;

    // Stop heartbeat
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    // Clear processed message IDs
    _processedMessageIds.clear();

    if (_channel != null) {
      try {
        // Send STOMP UNSUBSCRIBE frame first
        if (_isConnected) {
          _channel!.sink.add('UNSUBSCRIBE\nid:sub-0\n\n\x00');
        }

        // Send STOMP DISCONNECT frame
        _channel!.sink.add('DISCONNECT\n\n\x00');
        _channel!.sink.close();
      } catch (e) {
        debugPrint("Error during disconnect: $e");
      }
      _channel = null;
      _isConnected = false;
      debugPrint("WebSocket manually disconnected");
    }

    // Clear stored parameters
    _counterId = null;
    _onUpcomingUpdate = null;
    _reconnectAttempts = 0;
  }

  static void resetReconnectionAttempts() {
    _reconnectAttempts = 0;
    debugPrint("Reconnection attempts reset to 0");
  }

  static bool get isConnected => _isConnected;

  static int get reconnectAttempts => _reconnectAttempts;
}
