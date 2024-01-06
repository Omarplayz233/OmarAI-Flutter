import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Message> messages = [];
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Message Interface'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                reverse: true,
                children: messages.map((message) {
                  return MessageBubble(
                    text: message.text,
                    isMe: message.isMe,
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'Enter Text',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onFieldSubmitted: (text) {
                      String messageText = text.trim();
                      if (messageText.isNotEmpty) {
                        sendMessage(
                            messageText, true); // Sent message from the user
                        _textController
                            .clear(); // Clear the text field after sending
                        // Simulate receiving a message from the other person
                        sendMessage('Example', false);
                      }
                    },
                  ),
                ),
                SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    String messageText = _textController.text.trim();
                    if (messageText.isNotEmpty) {
                      sendMessage(
                          messageText, true); // Sent message from the user
                      _textController
                          .clear(); // Clear the text field after sending
                      // Simulate receiving a message from the other person
                      sendMessage('Example', false);
                    }
                  },
                  mini: true,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text, bool isMe) {
    setState(() {
      messages.insert(0, Message(text: text, isMe: isMe));
    });
    print('Message Sent: $text');
  }
}

class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMe ? 30 : 0),
              topRight: Radius.circular(isMe ? 0 : 30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.grey[200],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
