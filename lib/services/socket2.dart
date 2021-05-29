import 'package:socket_io_client/socket_io_client.dart' as client;
import 'package:socket_io_client/socket_io_client.dart' as IO;
// Add this package to your pubspec.yaml import
class SocketAna {
  static const _url = 'https://signal1.maulaji.com';

  static client.Socket _socket;

  static _initialize() {
    if (_socket != null) return;

    _socket = client.io(
      _url,
      <String, dynamic>{
        'transports': ['websocket']
      },
    );
    _socket.on('connect', (_) => print('Connected'));
    _socket.on('mkl', (_) => print('Connected'));
    _socket.connect();
  }

  static emit(String event, {dynamic arguments}) {
    _initialize(); // Ensure it's initialized
    _socket.emit(event, arguments ?? {});
  }

  static subscribe(String event, Function function) {
    _initialize(); // Ensure it's initialized
    _socket.on(event, function);
  }

  static unsubscribe(String event, Function function) {
    _initialize(); // Ensure it's initialized
    _socket.off(event, function);
  }
}


class SocketService {
  IO.Socket socket;
  bool connected = false;
  final sessionId = "123456";

  // time-based
  final userId ="1";

  sendMessage(String text, dynamic data) {
    if (connected) {
      socket.emit('processInput', {
        'URLToken':"123",
        'text': text,
        'userId': userId,
        'sessionId': sessionId,
        'channel': 'flutter',
        'data': data,
        'source': 'device'
      });
    } else {
      print('[SocketClient] Unable to directly send your message since we are not connected.');
    }
  }

  createSocketConnection() {
    print("[SocketClient] try to connect to Cognigy.AI");

    socket = IO.io('https://signal1.maulaji.com', <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {
        'URLToken': "123"
      }
    });

    this.socket.on("connect", (_) {
      print("[SocketClient] connection established");

      connected = true;
    });

    this.socket.on("disconnect", (_) => print("[SocketClient] disconnected"));
  }
}