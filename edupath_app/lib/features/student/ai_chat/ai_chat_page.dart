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

  Future<void> sendMessage([String? preset]) async {
    final question = (preset ?? _controller.text).trim();
    if (question.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: question, isUser: true));
      loading = true;
    });

    _controller.clear();
    scrollToBottom();

    try {
      final answer =
          await _aiService.ask(question: question, courseId: widget.course.id);
      setState(() {
        messages.add(ChatMessage(text: answer, isUser: false));
      });
    } catch (e) {
      debugPrint('AI ERROR: $e');
      setState(() {
        messages
            .add(ChatMessage(text: 'Error: ${e.toString()}', isUser: false));
      });
    }

    setState(() => loading = false);
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget buildBubble(ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(isUser ? 12 : 2),
      bottomRight: Radius.circular(isUser ? 2 : 12),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? theme.colorScheme.primary : theme.cardColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DefaultTextStyle(
              style: TextStyle(
                  color:
                      isUser ? Colors.white : theme.textTheme.bodyLarge?.color),
              child: SelectableText(
                message.text,
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.course.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text('AI Tutor',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() => messages.clear());
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Ask a question about this course to get started.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 16, bottom: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) =>
                          buildBubble(messages[index]),
                    ),
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(minHeight: 3),
              ),
          ],
        ),
      ),
      // Pin the composer to bottom to avoid it being hidden or removed when body changes
      bottomSheet: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    hintText: "Ask about your lesson...",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: loading ? null : sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
