import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

class SignalRService {
  static HubConnection? _connection;
  static final _alertController = StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get alertStream => _alertController.stream;

  static Future<void> connect() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return;

    _connection = HubConnectionBuilder()
        .withUrl(
          '${ApiConstants.baseUrl}${ApiConstants.signalRHub}',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('AlertTriggered', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _alertController.add(arguments[0] as Map<String, dynamic>);
      }
    });

    _connection!.onclose(({error}) {
      Future.delayed(const Duration(seconds: 5), _tryReconnect);
    });

    await _connection!.start();
  }

  static Future<void> _tryReconnect() async {
    if (_connection?.state == HubConnectionState.Disconnected) {
      await connect();
    }
  }

  static Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }
}
