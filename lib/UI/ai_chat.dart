// import 'package:final_collab/controller/ai_controller.dart';
import 'package:flutter/material.dart';
import '../logic/controller/ai_controller.dart';

import '../logic/controller/ai_controller.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  _AIChatPageState createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final AIController _aiController = AIController(
    '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',
    "meta-llama/llama-4-scout-17b-16e-instruct",
  );
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage() async {
    final userMessage = _controller.text;
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'user': userMessage});
    });

    _controller.clear();

    final aiResponse = await _aiController.sendMessage(userMessage);

    setState(() {
      _messages.add({'ai': aiResponse});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF7EF),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/backButton.png', width: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 30.0), // Add right padding to the left image
              child: Image.asset(
                'assets/faceRightRabbit.png',
                width: 50,
                height: 50,
              ),
            ),
            const Text(
              'AI Chat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.0), // Add left padding to the right image
              child: Image.asset(
                'assets/faceLeftRabbit.png',
                width: 50,
                height: 50,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color.fromRGBO(251, 247, 239, 1),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.containsKey('user');
                  return _buildChatBubble(
                    isUser ? message['user']! : message['ai']!,
                    isUser: isUser,
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? const Color.fromRGBO(151, 94, 224, 1) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(left:8.0,right: 8.0,top: 8.0,bottom: 55.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2.0)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Write Here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color.fromRGBO(251, 247, 239, 1),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: const Color.fromRGBO(151, 94, 224, 1),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}