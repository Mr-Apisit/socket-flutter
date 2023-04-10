import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/injector.dart';
import 'src/pages/chat_page.dart';
import 'src/services/socket_service.dart';

void main() {
  configureDependencies();
  dotenv.load(fileName: ".env");
  // final SocketService socketService = getIt.get<SocketService>();
  // socketService.createSocketConnection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Mr.tree chat socket",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SetupPage());
  }
}

class SetupPage extends StatelessWidget {
  SetupPage({super.key});
  final SocketService socketService = getIt.get<SocketService>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var name = '';
    var room = '';

    proceed() {
      if (name.length < 3) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Please Input at least 3 characters!')));
      } else {
        socketService.setUserName(name);
        socketService.setRoom(room);
        socketService.createSocketConnection();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChatPage(),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Chat with socket")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: size.width * 0.6,
              child: TextField(
                textAlign: TextAlign.center,
                autofocus: true,
                onChanged: (_) {
                  room = _;
                },
                onSubmitted: (s) => proceed(),
                decoration: const InputDecoration(
                    hintText: 'Enter Your Room', border: OutlineInputBorder(), focusedBorder: OutlineInputBorder()),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: size.width * 0.6,
              child: TextField(
                textAlign: TextAlign.center,
                autofocus: true,
                onChanged: (_) {
                  name = _;
                },
                onSubmitted: (s) => proceed(),
                decoration: const InputDecoration(
                    hintText: 'Enter Your User ทอ.', border: OutlineInputBorder(), focusedBorder: OutlineInputBorder()),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => proceed(), child: const Text('Proceed')),
            SizedBox(height: size.height * 0.3),
            const Text(
              'Pre-start chat',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
