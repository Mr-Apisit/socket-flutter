import 'package:flutter/material.dart';

import '../data/models/chat_model.dart';

import '../injector.dart';
import '../services/socket_service.dart';
import '../widgets/chat_widgets/chat_input_widget.dart';
import '../widgets/chat_widgets/message_widget.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});
  final SocketService socketService = getIt.get<SocketService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              socketService.dispose();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          centerTitle: true,
          title: const Text("Mr.Tree test chat")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChatBody(),
            const SizedBox(height: 6),
            BuddyTyping(),
            const Divider(
              height: .1,
              thickness: .1,
              color: Colors.blueGrey,
            ),
            ChatTextInput(),
          ],
        ),
      ),
    );
  }
}

class BuddyTyping extends StatelessWidget {
  BuddyTyping({super.key});
  final SocketService socketService = getIt.get<SocketService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      alignment: Alignment.centerLeft,
      child: StreamBuilder(
        stream: socketService.typingResponse,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          return snapshot.data['isTyping']
              ? Text(
                  '${snapshot.data['userName']} กำลังพิมพ์ข้อความ...',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  _ChatBody({Key? key}) : super(key: key);
  final SocketService socketService = getIt.get<SocketService>();

  @override
  Widget build(BuildContext context) {
    var chats = <Chat>[];
    ScrollController scrollController = ScrollController();

    ///scrolls to the bottom of page
    void scrollDown() {
      try {
        Future.delayed(const Duration(milliseconds: 300),
            () => scrollController.jumpTo(scrollController.position.maxScrollExtent));
      } on Exception catch (_) {}
    }

    return Expanded(
      child: StreamBuilder(
        stream: socketService.getResponse,
        builder: (BuildContext context, AsyncSnapshot<Chat> snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            chats.add(snapshot.data!);
          }
          scrollDown();
          return ListView.builder(
            controller: scrollController,
            itemCount: chats.length,
            itemBuilder: (BuildContext context, int index) => MessageView(chat: chats[index]),
          );
        },
      ),
    );
  }
}
