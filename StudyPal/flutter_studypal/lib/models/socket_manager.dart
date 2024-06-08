import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static late IO.Socket _socket;

  static void initSocket() {
    _socket = IO.io(
      'http://10.0.2.2:4000',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
  }

  static IO.Socket get socket => _socket;
}
