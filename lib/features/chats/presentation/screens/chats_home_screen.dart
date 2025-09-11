import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/chats/presentation/provider/chat_provider.dart';
import 'package:acadobs/features/chats/presentation/widgets/common_chat_tile.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChatsHomeScreen extends StatefulWidget {
  final bool forParent;
  const ChatsHomeScreen({super.key, this.forParent = false});

  @override
  State<ChatsHomeScreen> createState() => _ChatsHomeScreenState();
}

class _ChatsHomeScreenState extends State<ChatsHomeScreen> {
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _getUsersList();
  }

  Future<void> _getUsersList() async {
    final token = await AuthStorageService().getToken();
    if (token != null) {
      _chatProvider.connect(token);
      _chatProvider.loadUsersList();
    } else {
      debugPrint("No token found, cannot connect to chat");
    }
  }

  @override
  void dispose() {
    _chatProvider.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Chats"),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final users = chatProvider.usersList;

          if (chatProvider.isLoadingUsers) {
            return const Center(child: CircularProgressIndicator());
          }

          if (users.isEmpty) {
            return const Center(child: Text("No conversations yet"));
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final convo = users[index];
              final opponent = convo["opponent"];

              return CommonChatTile(
                name: opponent["name"] ?? "Unknown",
                subject: convo["last_message"] ?? "",
                imageUrl: opponent["dp"] ?? "",
                onTap: () {
                  context
                      .pushNamed(
                        RouteConstants.chatScreen,
                        extra: ChatModel(
                          opponentId: opponent["id"],
                          opponentName: opponent["name"],
                        ),
                      )
                      .then((_) {
                        if (!mounted) return;
                        _chatProvider.loadUsersList();
                      });
                },
              );
            },
          );
        },
      ),
      floatingActionButton:
          widget.forParent
              ? FloatingActionButton(onPressed: () {}, child: Icon(Icons.chat))
              : CommonFloatingActionButton(
                onPressed: () {
                  context.pushNamed(RouteConstants.addTeacherNoteSection);
                },
                text: "Add New Parent Note",
              ),
    );
  }
}
