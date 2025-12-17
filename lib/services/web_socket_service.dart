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
  static Function(Map<String, dynamic> counter)? _onCounterUpdate;
  static StreamSubscription? _streamSubscription;

  // Message deduplication
  static final Set<String> _processedMessageIds = {};
  static const int _maxCachedMessageIds = 100;

  static void connect({
    required String counterId,
    required Function(List<dynamic> data) onUpcomingUpdate,
    required Function(Map<String, dynamic> counter) onCounterUpdate,
  }) {
    _counterId = counterId;
    _onUpcomingUpdate = onUpcomingUpdate;
    _onCounterUpdate = onCounterUpdate;
    _isIntentionalDisconnect = false;

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
      _streamSubscription?.cancel();
      _streamSubscription = null;
      _isSubscribed = false;

      final wsUri = Uri.parse(ApiConstants.wsUrl);
      _channel = WebSocketChannel.connect(wsUri);
      _isConnected = true;

      final connectFrame =
          'CONNECT\naccept-version:1.0,1.1,2.0\nheart-beat:10000,10000\n\n\x00';
      _channel!.sink.add(connectFrame);

      _startHeartbeat();

      _streamSubscription = _channel!.stream.listen(
        (message) {
          try {
            final messageStr = message.toString();

            if (messageStr.startsWith('CONNECTED')) {
              _reconnectAttempts = 0;

              if (!_isSubscribed) {
                _channel!.sink.add(
                  'SUBSCRIBE\nid:sub-queue\ndestination:/topic/agent-upcoming/$_counterId\n\n\x00',
                );

                _channel!.sink.add(
                  'SUBSCRIBE\nid:sub-counter\ndestination:/topic/counter/$_counterId\n\n\x00',
                );

                _isSubscribed = true;
              }
            } else if (messageStr.startsWith('MESSAGE')) {
              final messageIdMatch = RegExp(
                r'message-id:([^\n]+)',
              ).firstMatch(messageStr);
              final messageId = messageIdMatch?.group(1)?.trim();

              if (messageId != null &&
                  _processedMessageIds.contains(messageId)) {
                return;
              }

              // ✅ ADD: extract destination
              final destinationMatch = RegExp(
                r'destination:([^\n]+)',
              ).firstMatch(messageStr);
              final destination = destinationMatch?.group(1);

              final bodyStart = messageStr.indexOf('\n\n') + 2;
              final bodyEnd = messageStr.indexOf('\x00', bodyStart);

              if (bodyStart > 1 && bodyEnd > bodyStart) {
                final body = messageStr.substring(bodyStart, bodyEnd);

                if (body.isNotEmpty) {
                  // ✅ ADD: route based on destination
                  if (destination?.startsWith('/topic/agent-upcoming/') ==
                      true) {
                    final decodedData = jsonDecode(body);

                    if (decodedData is List) {
                      _onUpcomingUpdate?.call(List<dynamic>.from(decodedData));
                    }
                  } else if (destination?.startsWith('/topic/counter/') ==
                      true) {
                    final decodedData = jsonDecode(body);

                    if (decodedData is Map<String, dynamic>) {
                      _onCounterUpdate?.call(decodedData);
                    }
                  }

                  if (messageId != null) {
                    _processedMessageIds.add(messageId);
                    if (_processedMessageIds.length > _maxCachedMessageIds) {
                      _processedMessageIds.remove(_processedMessageIds.first);
                    }
                  }
                }
              }
            }
          } catch (e, stackTrace) {
            debugPrint("Error processing WebSocket message: $e");
            debugPrint("StackTrace: $stackTrace");
          }
        },
        onError: (_) => _handleDisconnection(),
        onDone: _handleDisconnection,
        cancelOnError: false,
      );
    } catch (_) {
      _handleDisconnection();
    }
  }

  static void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isConnected && _channel != null) {
        _channel!.sink.add('\n');
      }
    });
  }

  static void _handleDisconnection() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_isIntentionalDisconnect) return;

    if (_counterId == null || _onUpcomingUpdate == null) return;

    if (_reconnectAttempts >= _maxReconnectAttempts) return;

    _reconnectAttempts++;
    _reconnectTimer = Timer(_reconnectDelay, _connectInternal);
  }

  static void _cleanup() {
    _heartbeatTimer?.cancel();
    _streamSubscription?.cancel();
    _isSubscribed = false;
    _channel?.sink.close();
    _channel = null;
  }

  static void disconnect() {
    _isIntentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _streamSubscription?.cancel();
    _processedMessageIds.clear();

    if (_channel != null) {
      _channel!.sink.add('DISCONNECT\n\n\x00');
      _channel!.sink.close();
    }

    _channel = null;
    _isConnected = false;
    _counterId = null;
    _onUpcomingUpdate = null;
    _onCounterUpdate = null;
    _reconnectAttempts = 0;
  }

  static bool get isConnected => _isConnected;
}
