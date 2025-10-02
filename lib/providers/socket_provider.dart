import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final socketProvider = Provider<IO.Socket>((ref) {
  final socket = IO.io(
    'https://backend.pasitlab.com',
    IO.OptionBuilder()
        .setTransports(['polling', 'websocket'])
        .setPath('/my-websocket/')
        .disableAutoConnect()
        .build(),
  );

  ref.onDispose(() {
    socket.disconnect();
    socket.dispose();
  });

  return socket;
});
