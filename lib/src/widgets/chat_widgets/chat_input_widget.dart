import 'package:flutter/material.dart';

import '../../injector.dart';
import '../../services/socket_service.dart';

class ChatTextInput extends StatelessWidget {
  ChatTextInput({Key? key}) : super(key: key);
  final SocketService socketService = getIt.get<SocketService>();

  @override
  Widget build(BuildContext context) {
    var textController = TextEditingController();
    var focusCode = FocusNode();

    sendMessage() {
      var message = textController.text;
      socketService.isTyping(false);
      socketService.sendMessage(message);
      textController.text = '';
      focusCode.requestFocus();
    }

    return Container(
      margin: const EdgeInsets.all(12),
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: focusCode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.send,
              autofocus: true,
              controller: textController,
              onChanged: (val) {
                val.isNotEmpty ? socketService.isTyping(true) : socketService.isTyping(false);
              },
              onSubmitted: (s) => sendMessage(),
              decoration: const InputDecoration(
                  hintText: 'Send a message', border: OutlineInputBorder(), focusedBorder: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              sendMessage();
            },
            child: const CircleAvatar(
              child: Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
