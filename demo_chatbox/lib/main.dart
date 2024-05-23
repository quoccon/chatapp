import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'controller/chat_controller.dart';
import 'model/message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController msgController = TextEditingController();
  late IO.Socket socket;

  ChatController chatController = ChatController();

  @override
  void initState() {
    socket = IO.io(
        "http://10.0.2.2:2000",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    socket.connect();
    setUpSocketListener();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: Obx(
                  () => ListView.builder(
                    itemCount: chatController.chatMessage.length,
                    itemBuilder: (context, index) {
                      var currentItem = chatController.chatMessage[index];
                      return MessageItem(
                        sentByMe: currentItem.sentByMe == socket.id,
                        message: currentItem.message,
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: msgController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: Container(
                        child: IconButton(
                            color: Colors.white,
                            onPressed: () {
                              sendMessage(msgController.text);
                              msgController.clear();
                            },
                            icon: const Icon(Icons.send)),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void sendMessage(String text) {
    var messageJson = {"message": text, "sentByMe": socket.id};
    socket.emit('message', messageJson);
    chatController.chatMessage.add(Message.fromJson(messageJson));
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data) {
      print(data);
      chatController.chatMessage.add(Message.fromJson(data));
    });
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({super.key, required this.sentByMe, required this.message});

  final bool sentByMe;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sentByMe ? Colors.grey : Colors.black,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(
                color: sentByMe ? Colors.black : Colors.white,
                fontSize: 15,
              ),
            ),
            Text(
              "1:10 am",
              style: TextStyle(
                color: sentByMe ? Colors.black : Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
