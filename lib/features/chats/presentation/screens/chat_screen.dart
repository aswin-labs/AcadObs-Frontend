import 'dart:developer';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/chats/presentation/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chatModel;
  const ChatScreen({super.key, required this.chatModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final chat = Provider.of<ChatProvider>(context, listen: false);

    final token = await AuthStorageService().getToken();

    if (token != null) {
      chat.connect(token);
      chat.getMessages(widget.chatModel.opponentId);
    } else {
      debugPrint("No token found, cannot connect to chat");
    }
  }

  @override
  void dispose() {
    Provider.of<ChatProvider>(context, listen: false).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(chat.isConnected ? "Chat Connected" : "Connecting..."),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                log(chat.messages.length.toString());
                final msg = chat.messages[index];
                return buildMessage(msg);
              },
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: _controller)),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    chat.sendMessage(receiverId: 4, message: _controller.text);
                    _controller.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    final text = msg["message"] ?? "";
    final mediaUrl = msg["mediaUrl"];

    if (mediaUrl != null && mediaUrl.toString().isNotEmpty) {
      return Image.network(
        mediaUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    }
    return Text(text);
  }
}
