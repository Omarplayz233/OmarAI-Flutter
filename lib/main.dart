import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dio/dio.dart'; // Import dio package

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

  int _selectedIndex = 0;
  bool isSendingMessage = false;
  bool switchValue = false; // Add this variable

  // API Key for accessing the generative language API
  String apiKey = "gemini-pro-key";

  @override
  Widget build(BuildContext context) {
    Color bubbleColor = Theme.of(context).primaryColor;

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.lightBlueAccent, // Set the primary color
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Message Interface'),
        ),
        body: _selectedIndex == 0 ? buildChatScreen() : buildSettingsScreen(),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget buildChatScreen() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return MessageBubble(
                text: messages[index].text,
                isMe: messages[index].isMe,
                bubbleColor: messages[index].isMe
                    ? Theme.of(context).primaryColor
                    : Color(0xffdbdada), // Change color for AI response
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                enabled:
                    !isSendingMessage, // Disable text field while sending message
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
                    sendMessage(messageText, true);
                    _textController.clear();
                    // Call the API when a message is sent
                    makeApiCall(messageText);
                  }
                },
              ),
            ),
            SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () async {
                setState(() {
                  isSendingMessage = true;
                });

                String messageText = _textController.text.trim();
                if (messageText.isNotEmpty) {
                  sendMessage(messageText, true);
                  _textController.clear();
                  // Call the API when a message is sent
                  await makeApiCall(messageText);
                }

                setState(() {
                  isSendingMessage = false;
                });
              },
              mini: true,
              child: isSendingMessage
                  ? CircularProgressIndicator() // Show loading indicator
                  : Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSettingsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Settings Screen',
            style: TextStyle(fontSize: 24),
          ),
          Switch(
            value: switchValue,
            onChanged: (value) {
              setState(() {
                switchValue = value;
              });
            },
          ),
          Text(
            'Switch is ${switchValue ? 'ON' : 'OFF'}',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void sendMessage(String text, bool isMe) {
    setState(() {
      messages.insert(0, Message(text: text, isMe: isMe));
    });
    print('Message Sent: $text');
  }

  Future<void> makeApiCall(String text) async {
    // URL for the generative language API
    String apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey";

    try {
      // Prepare the request body
      var requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text": text,
              }
            ],
          }
        ]
      };

      // Create Dio instance
      Dio dio = Dio();

      // Make the Dio POST request
      var response = await dio.post(
        apiUrl,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode(requestBody),
      );

      // Parse the response and get the AI's reply
      var jsonResponse = json.decode(response.data);

      if (jsonResponse != null &&
          jsonResponse.containsKey("candidates") &&
          jsonResponse["candidates"].isNotEmpty) {
        var aiReply =
            jsonResponse["candidates"][0]["content"]["parts"][0]["text"];

        // Display AI's reply in the UI
        sendMessage(aiReply, false);

        print("API Response:");
        print(response.data);
      } else {
        print("Invalid API response format");
      }
    } catch (error) {
      print("Error making API call: $error");
    }
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
  final Color bubbleColor;

  const MessageBubble({
    required this.text,
    required this.isMe,
    required this.bubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = isMe ? Colors.white : Colors.black;

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
            color: bubbleColor,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: MarkdownBody(
                data: text,
                styleSheet:
                    MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: TextStyle(color: textColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
