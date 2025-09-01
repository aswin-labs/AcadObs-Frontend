import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/chats/presentation/provider/chat_provider.dart';
import 'package:acadobs/features/chats/presentation/widgets/chat_bubble.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
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
  final ScrollController _scrollController = ScrollController();

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
    return Scaffold(
      appBar: CommonAppBar(
        title: widget.chatModel.opponentName,
        isBackButton: true,
      ),
      body: Padding(
        padding: context.paddingHorizontal,
        child: Column(
          children: [
            /// Messages
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, _) {
                  final messages = provider.messages;

                  return FutureBuilder<int?>(
                    future: AuthStorageService().getUserId(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final currentUserId = snapshot.data;

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.only(top: 12, bottom: 20),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          // since reverse:true, take from the end
                          final msg = messages[messages.length - 1 - index];
                          final isMe = msg['sender_id'] == currentUserId;
                          return ChatBubble(
                            text: msg['message'] ?? "",
                            isMe: isMe,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            /// Input field
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          context.read<ChatProvider>().sendMessage(
                            receiverId: widget.chatModel.opponentId,
                            message: _controller.text.trim(),
                          );
                          _controller.clear();

                          // auto scroll to bottom
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
