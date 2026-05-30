import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

enum SignalRStatus { disconnected, connecting, connected, reconnecting }

class SignalRService {
  static HubConnection? _connection;

  static final _statusController = StreamController<SignalRStatus>.broadcast();
  static final _alertTriggeredController = StreamController<Map<String, dynamic>>.broadcast();
  static final _alertStatusChangedController = StreamController<Map<String, dynamic>>.broadcast();
  static final _insightUpdatedController = StreamController<Map<String, dynamic>>.broadcast();

  static Stream<SignalRStatus> get statusStream => _statusController.stream;
  static Stream<Map<String, dynamic>> get alertTriggeredStream => _alertTriggeredController.stream;
  static Stream<Map<String, dynamic>> get alertStatusChangedStream => _alertStatusChangedController.stream;
  static Stream<Map<String, dynamic>> get insightUpdatedStream => _insightUpdatedController.stream;

  static Future<void> connect() async {
    await disconnect();

    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return;

    _connection = HubConnectionBuilder()
        .withUrl(
          '${ApiConstants.baseUrl}${ApiConstants.signalRHub}',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => StorageService.accessToken ?? '',
          ),
        )
        .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
        .build();

    _connection!.on('AlertTriggered', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _alertTriggeredController.add(arguments[0] as Map<String, dynamic>);
      }
    });

    _connection!.on('AlertStatusChanged', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _alertStatusChangedController.add(arguments[0] as Map<String, dynamic>);
      }
    });

    _connection!.on('InsightUpdated', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _insightUpdatedController.add(arguments[0] as Map<String, dynamic>);
      }
    });

    _connection!.onreconnecting(({error}) {
      _statusController.add(SignalRStatus.reconnecting);
    });

    _connection!.onreconnected(({connectionId}) {
      _statusController.add(SignalRStatus.connected);
    });

    _connection!.onclose(({error}) {
      _statusController.add(SignalRStatus.disconnected);
    });

    _statusController.add(SignalRStatus.connecting);

    try {
      await _connection!.start();
      _statusController.add(SignalRStatus.connected);
    } catch (e) {
      _statusController.add(SignalRStatus.disconnected);
    }
  }

  static Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.stop();
      _connection = null;
    }
    _statusController.add(SignalRStatus.disconnected);
  }
}
