import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../data/models/chat_model.dart';


@singleton
class SocketService {
  late StreamController<Chat> _chatResponse;
  late StreamController<dynamic> _typingResponse;

  static String _userName = '';
  static String _room = '';
  List<dynamic> allMessage = [];
  late io.Socket socket;

  String? get userId => socket.id;

  Stream<Chat> get getResponse => _chatResponse.stream.asBroadcastStream();
  Stream<dynamic> get typingResponse => _typingResponse.stream.asBroadcastStream();

  void setUserName(String name) {
    _userName = name;
  }

  void setRoom(String room) {
    _room = room;
  }

  void sendMessage(String msg) {
    final message = Chat(
      userId: userId,
      userName: _userName,
      message: msg,
      time: DateTime.now().toString(),
    );
    final options = {"room_name": _room, "data": message.toJson(), "timeout": 1000};
    _chatResponse.sink.add(message);
    socket.emit("send-room-message-v2", options);
  }

  void isTyping(bool isTyping) {
    final options = {
      "room_name": _room,
      "data": {'id': userId, 'isTyping': isTyping, 'userName': _userName},
      "timeout": 1000
    };
    socket.emit("${dotenv.env['SENT']}", options);
  }

  void createSocketConnection() {
    _chatResponse = StreamController();
    _typingResponse = StreamController();
    dev.log("$_room & $_userName");
    socket = io.io(
      '${dotenv.env['SOCKET']}',
      io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().setQuery({'userName': _userName}).build(),
    );
    socket.connect();

    socket.onConnect((_) {
      dev.log('Socket message to ${socket.id} is connected !!');
      socket.emit('join-room', _room);
      // Join room

      socket.on('id', (_) {
        dev.log("socket serve ID : ${_[0]}");
      });

      socket.on('${dotenv.env['RECEIVE']}', (_) {
        final isYourRoom = _["room_name"] == _room;
        if (isYourRoom) {
          String myRoom = _["room_name"];
          final data = _["data"];
          dev.log("Start join room : $myRoom");
          dev.log("receive the data .... $data");
          if (data["message"] != null) {
            _chatResponse.sink.add(Chat.fromRawJson(data));
            dev.log("msg is : ${data['msg']}");
          }
          if (data["isTyping"] != null) {
            _typingResponse.sink.add(data);
            dev.log("Start typing : ${data["isTyping"]}");
          }
        }
      });
    });

    socket.onDisconnect((_) => dev.log('disconnect'));
  }

  void dispose() {
    socket.dispose();
    socket.destroy();
    socket.close();
    socket.disconnect();
    _chatResponse.close();
    _typingResponse.close();
    // _userResponse.close();
  }
}
