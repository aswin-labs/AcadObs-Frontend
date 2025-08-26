import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/chats/presentation/widgets/common_chat_tile.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_action_button.dart';
import 'package:acadobs/shared/widgets/common_search_box.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatsHomeScreen extends StatefulWidget {
  const ChatsHomeScreen({super.key});

  @override
  State<ChatsHomeScreen> createState() => _ChatsHomeScreenState();
}

class _ChatsHomeScreenState extends State<ChatsHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Chats"),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonSearchBox(),
                  SizedBox(height: 20),
                  CommonChatTile(
                    name: "April Curtis",
                    subject: "Maths",
                    imageUrl: "",
                    onTap:
                        () => context.pushNamed(
                          RouteConstants.chatScreen,
                          extra: ChatModel(
                            opponentId: 2,
                            opponentName: "April Curtis",
                          ),
                        ),
                  ),
                  CommonChatTile(
                    name: "Dori Doreau",
                    subject: "Science",
                    imageUrl: "",
                    onTap: () {},
                  ),
                  CommonChatTile(
                    name: "Angus MacGyver",
                    subject: "English",
                    imageUrl: "",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: CommonFloatingActionButton(
        onPressed: () {
          context.pushNamed(RouteConstants.addTeacherNoteSection);
        },
        text: "Add New Parent Note",
      ),
    );
  }
}
