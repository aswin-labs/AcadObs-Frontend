import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/chats/presentation/provider/chat_provider.dart';
import 'package:acadobs/features/chats/presentation/widgets/chat_shimmer.dart';
import 'package:acadobs/features/chats/presentation/widgets/common_chat_tile.dart';
import 'package:acadobs/features/chats/presentation/widgets/share_bottom_sheet.dart';
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
  String searchQuery = "";

  late ChatProvider _chatProvider;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider = context.read<ChatProvider>();
      _getUsersList();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200 &&
            !_chatProvider.isLoadingUsers) {
          _chatProvider.loadUsersList();
        }
      });
    });
  }

  Future<void> _getUsersList() async {
    final token = await AuthStorageService().getToken();
    if (token != null) {
      _chatProvider.connect(token);
      _chatProvider.loadUsersList(reset: true);
    } else {
      debugPrint("No token found, cannot connect to chat");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatProvider.disconnect();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Chats"),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final users = chatProvider.usersList;

          final filtered =
              users.where((u) {
                final name = (u["opponent"]["name"] ?? "").toLowerCase();
                return name.contains(searchQuery.toLowerCase());
              }).toList();

          if (chatProvider.isLoadingUsers && users.isEmpty) {
            return const Center(child: ChatShimmer());
          }

          if (users.isEmpty) {
            return const Center(child: Text("No conversations yet"));
          }

          return Column(
            children: [
              //  Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: "Search for Chats",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon:
                        searchQuery.isNotEmpty
                            ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchQuery = "";
                                });
                              },
                              icon: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.grey.shade300,
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              //     Expanded(
              //       child:
              //           filtered.isEmpty
              //               ? const Center(child: Text("No chats found"))
              //               : ListView.separated(
              //                 controller: _scrollController,
              //                 physics: const BouncingScrollPhysics(),
              // itemCount: filtered.length,
              //                 separatorBuilder: (context, index) {
              //                   if (index == users.length - 1) {
              //                     return const SizedBox.shrink();
              //                   }
              //                   return Padding(
              //                     padding: const EdgeInsets.symmetric(
              //                       horizontal: 16,
              //                     ),
              //                     child: Divider(
              //                       height: 1,
              //                       thickness: 1,
              //                       color: Colors.grey.shade300,
              //                     ),
              //                   );
              //                 },

              //                 // itemCount: users.length + 1,
              //                 itemBuilder: (context, index) {
              //                   if (index == users.length) {
              //                     return chatProvider.isLoadingUsers
              //                         ? const Padding(
              //                           padding: EdgeInsets.all(16),
              //                           child: Center(
              //                             child: CircularProgressIndicator(),
              //                           ),
              //                         )
              //                         : const SizedBox.shrink();
              //                   }

              //                   final convo = users[index];
              //                   final opponent = convo["opponent"];

              //                   return CommonChatTile(
              //                     name: opponent["name"] ?? "Unknown",
              //                     subject: convo["last_message"] ?? "",
              //                     imageUrl: opponent["dp"] ?? "",
              //                     onTap: () {
              //                       context
              //                           .pushNamed(
              //                             RouteConstants.chatScreen,
              //                             extra: ChatModel(
              //                               opponentId: opponent["id"],
              //                               opponentName: opponent["name"],
              //                             ),
              //                           )
              //                           .then((_) {
              //                             if (!mounted) return;
              //                             _chatProvider.loadUsersList(reset: true);
              //                           });
              //                     },
              //                   );
              //                 },
              //               ),
              //     ),
              Expanded(
                child:
                    filtered.isEmpty
                        ? const Center(child: Text("No chats found"))
                        : ListView.separated(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder:
                              (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                          itemBuilder: (context, index) {
                            final convo = filtered[index];
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
                                      _chatProvider.loadUsersList(reset: true);
                                    });
                              },
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
      floatingActionButton:
          widget.forParent
              ? FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    isDismissible: true,
                    enableDrag: true,
                    backgroundColor: Colors.transparent,
                    barrierColor: Colors.black.withAlpha(50),
                    context: context,
                    builder: (_) => ShareBottomSheet(),
                  );
                },
                child: Icon(Icons.chat),
              )
              : CommonFloatingActionButton(
                onPressed: () {
                  context.pushNamed(RouteConstants.noteListingScreen);
                },
                text: "Add New Parent Note",
              ),
    );
  }
}
