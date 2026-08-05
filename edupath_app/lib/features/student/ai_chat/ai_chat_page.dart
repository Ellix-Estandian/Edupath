import 'package:flutter/material.dart';

import '../../../core/services/ai_service.dart';
import '../../../models/chat_message.dart';
import '../../../models/course.dart';

class AIChatPage extends StatefulWidget {
  final Course course;

  const AIChatPage({
    super.key,
    required this.course,
  });

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final AIService _aiService = AIService();

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> messages = [];

  bool loading = false;

  Future<void> sendMessage() async {
    final question = _controller.text.trim();

    if (question.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: question,
          isUser: true,
        ),
      );
      loading = true;
    });

    _controller.clear();

    scrollToBottom();

    try {
      final answer = await _aiService.ask(
        question: question,
        courseId: widget.course.id,
      );

      setState(() {
        messages.add(
          ChatMessage(
            text: answer,
            isUser: false,
          ),
        );
      });
    } catch (e) {
      debugPrint("AI ERROR: $e");

      setState(() {
        messages.add(
          ChatMessage(
            text: e.toString(),
            isUser: false,
          ),
        );
      });
    }

    setState(() {
      loading = false;
    });

    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget buildBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EduPath AI Tutor"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (_, index) {
                return buildBubble(messages[index]);
              },
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Ask about your lesson...",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: loading ? null : sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
