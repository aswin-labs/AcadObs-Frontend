import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/chats/presentation/provider/chat_provider.dart';
import 'package:acadobs/features/chats/presentation/widgets/chat_bubble.dart';

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
  final FocusNode _focusNode = FocusNode();
  ChatProvider? _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _initChat();
  }

  Future<void> _initChat() async {
    final token = await AuthStorageService().getToken();
    if (token != null) {
      _chatProvider?.connect(token);
      _chatProvider?.getMessages(widget.chatModel.opponentId);
    } else {
      debugPrint("No token found, cannot connect to chat");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _chatProvider?.disconnect();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      context.read<ChatProvider>().sendMessage(
        receiverId: widget.chatModel.opponentId,
        message: _controller.text.trim(),
        studentId: widget.chatModel.studentId,
        type: widget.chatModel.msgType,
        typeId: widget.chatModel.typeId,
      );
      _controller.clear();

      // Remove context details after sending
      setState(() {
        widget.chatModel.title = null;
        widget.chatModel.subtitle = null;
      });

      // Auto scroll to bottom
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 10,
              bottom: 10,
              right: 10,
            ),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFD9D9D9),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2196F3),
                    Color.fromARGB(255, 80, 159, 238),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.chatModel.opponentName.isNotEmpty
                      ? widget.chatModel.opponentName[0].toUpperCase()
                      : "U",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.chatModel.opponentName,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // appBar: CommonAppBar(
      //   title: widget.chatModel.opponentName,
      //   isBackButton: true,
      // ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/chatWallpaper.png"),
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          Container(
            color: Colors.white.withAlpha(203), // 0.85 → 0.95 recommended
          ),

          Column(
            children: [
              /// Messages
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, provider, _) {
                    final messages = provider.messages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF35C2C1).withAlpha(23),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Color.fromARGB(255, 80, 159, 238),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Start a conversation",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Send a message to get started",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return FutureBuilder<int?>(
                      future: AuthStorageService().getUserId(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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

                            final typeDetails =
                                (msg['typeDetails'] as Map<String, dynamic>?) ??
                                {};

                            // helper to return null for empty/invalid strings
                            String? safeString(dynamic value) {
                              if (value == null) return null;
                              final s = value.toString().trim();
                              return s.isEmpty ? null : s;
                            }

                            // extract dynamic values safely
                            final messageText =
                                safeString(msg['message']) ?? "";

                            String? title;
                            String? subtitle;

                            // handle different typeDetails gracefully
                            if (typeDetails.containsKey('Homework.title')) {
                              title = 'Homework';
                              subtitle = safeString(
                                typeDetails['Homework.title'],
                              );
                            } else if (typeDetails.containsKey('note_title')) {
                              title = safeString(typeDetails['note_title']);
                              subtitle = safeString(
                                typeDetails['note_content'],
                              );
                            }

                            return ChatBubble(
                              text: messageText,
                              isMe: isMe,
                              title: title,
                              subtitle: subtitle,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              /// Input with optional context details
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.chatModel.title != null ||
                          widget.chatModel.subtitle != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.blueGrey,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.chatModel.title != null)
                                      Text(
                                        widget.chatModel.title!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    if (widget.chatModel.subtitle != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          widget.chatModel.subtitle!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Optional close button if user wants to manually remove context
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    widget.chatModel.title = null;
                                    widget.chatModel.subtitle = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                      /// Input Field
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  maxLines: null,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    hintText: "Type a message...",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    // prefixIcon: Padding(
                                    //   padding: const EdgeInsets.only(left: 8),
                                    //   child: Icon(
                                    //     Icons.emoji_emotions_outlined,
                                    //     color: Colors.grey[600],
                                    //     size: 24,
                                    //   ),
                                    // ),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _sendMessage,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2196F3),
                                      Color.fromARGB(255, 80, 159, 238),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF35C2C1,
                                      ).withAlpha(68),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 12),
                      //   child: Row(
                      //     children: [
                      //       Expanded(
                      //         child: TextField(
                      //           controller: _controller,
                      //           decoration: InputDecoration(
                      //             hintText: "Type a message...",
                      //             border: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(20),
                      //             ),
                      //             contentPadding: const EdgeInsets.symmetric(
                      //               horizontal: 12,
                      //               vertical: 8,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       const SizedBox(width: 6),
                      //       IconButton(
                      //         icon: const Icon(Icons.send),
                      //         onPressed: () {
                      //           if (_controller.text.trim().isNotEmpty) {
                      //             context.read<ChatProvider>().sendMessage(
                      //               receiverId: widget.chatModel.opponentId,
                      //               message: _controller.text.trim(),
                      //               studentId: widget.chatModel.studentId,
                      //               type: widget.chatModel.msgType,
                      //               typeId: widget.chatModel.typeId,
                      //             );
                      //             _controller.clear();

                      //             // remove context details after sending
                      //             setState(() {
                      //               widget.chatModel.title = null;
                      //               widget.chatModel.subtitle = null;
                      //             });

                      //             // auto scroll to bottom
                      //             Future.delayed(
                      //               const Duration(milliseconds: 100),
                      //               () {
                      //                 if (_scrollController.hasClients) {
                      //                   _scrollController.animateTo(
                      //                     0.0,
                      //                     duration: const Duration(
                      //                       milliseconds: 300,
                      //                     ),
                      //                     curve: Curves.easeOut,
                      //                   );
                      //                 }
                      //               },
                      //             );
                      //           }
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
