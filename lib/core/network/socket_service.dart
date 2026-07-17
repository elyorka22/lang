import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/env_config.dart';
import '../storage/secure_storage_service.dart';

/// Socket.IO realtime service for chat presence, typing, and messages.
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService(ref.read(secureStorageProvider));
});

class SocketService {
  SocketService(this._storage);

  final SecureStorageService _storage;
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await _storage.getAccessToken();
    _socket = io.io(
      EnvConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setAuth({'token': token})
          .build(),
    );

    _socket!
      ..onConnect((_) {})
      ..onDisconnect((_) {})
      ..onConnectError((_) {});
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void joinConversation(String conversationId) {
    _socket?.emit('conversation:join', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('conversation:leave', {'conversationId': conversationId});
  }

  void sendTyping(String conversationId, {required bool isTyping}) {
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  void onMessage(void Function(Map<String, dynamic> data) handler) {
    _socket?.on('message:new', (data) {
      if (data is Map) {
        handler(Map<String, dynamic>.from(data));
      }
    });
  }

  void onTyping(void Function(Map<String, dynamic> data) handler) {
    _socket?.on('typing', (data) {
      if (data is Map) {
        handler(Map<String, dynamic>.from(data));
      }
    });
  }

  void onPresence(void Function(Map<String, dynamic> data) handler) {
    _socket?.on('presence:update', (data) {
      if (data is Map) {
        handler(Map<String, dynamic>.from(data));
      }
    });
  }

  void onRead(void Function(Map<String, dynamic> data) handler) {
    _socket?.on('message:read', (data) {
      if (data is Map) {
        handler(Map<String, dynamic>.from(data));
      }
    });
  }

  void emit(String event, Map<String, dynamic> data) {
    _socket?.emit(event, data);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
