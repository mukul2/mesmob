import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket socket;
  String link ="https://signal-socket-ibsjl.ondigitalocean.app" ;
  String link2 ="https://signal1.maulaji.com" ;

  createSocketConnection() {
    socket = IO.io(link2, <String, dynamic>{
      'transports': ['websocket'],
    });

    this.socket.on("connect", (_) => print('Connected'));
    this.socket.on("disconnect", (_) => print('Disconnected'));
    this.socket.on("onConnecting", (_) => print('onConnecting'));


  }
}