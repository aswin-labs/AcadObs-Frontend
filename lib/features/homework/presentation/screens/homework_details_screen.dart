import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/homework/data/models/homework_model.dart';
import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_detail_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class HomeworkDetailsScreen extends StatefulWidget {
  final HomeworkModel homework;
  const HomeworkDetailsScreen({super.key, required this.homework});

  @override
  State<HomeworkDetailsScreen> createState() => _HomeworkDetailsScreenState();
}

class _HomeworkDetailsScreenState extends State<HomeworkDetailsScreen> {
  late HomeworkProvider homeworkProvider;
  @override
  void initState() {
    homeworkProvider = context.read<HomeworkProvider>();
    homeworkProvider.fetchSingleHomework(homeworkId: widget.homework.id ?? 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Homework",
        isBackButton: true,
        actions: [
          widget.homework.forStudent == true
              ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      RouteConstants.chatScreen,
                      extra: ChatModel(
                        opponentId:
                            widget.homework.forParent == true
                                ? widget.homework.user?.id ?? 0
                                : widget.homework.guardianIdForChat ?? 0,
                        opponentName:
                            widget.homework.forParent == true
                                ? widget.homework.user?.name ?? ""
                                : widget.homework.guardianNameForChat ?? "",
                        title: widget.homework.title ?? "",
                        subtitle: widget.homework.description ?? "",
                        msgType: "homeworks",
                        typeId: widget.homework.studentHomeworkId,
                      ),
                    );
                  },
                  child: Icon(Icons.chat),
                ),
              )
              : Consumer<HomeworkProvider>(
                builder: (context, provider, _) {
                  return CustomPopupMenu(
                    onEdit: () {
                      context.pushNamed(
                        RouteConstants.editHomeWork,
                        extra: widget.homework,
                      );
                    },
                    onDelete: () {
                      showConfirmationDialog(
                        context: context,
                        title: 'Delete Homework',
                        content: 'Are you want to delete the homework',
                        onConfirm: () {
                          provider.deleteHomeWork(context);
                        },
                      );
                    },
                  );
                },
              ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemDetailScreenContainer(
                    iconColor: Color(0xFFB14F6F),
                    backgroundColor: Color(0xFFFFCEDE),
                    icon: LucideIcons.clipboardList,
                  ),
                  SizedBox(height: Responsive.height * 3),
                  Text(
                    capitalizeEachWord(widget.homework.title ?? ""),
                    style: context.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 1),
                  Text(
                    widget.homework.description ?? "",
                    style: context.textTheme.bodySmall!.copyWith(
                      color: Color(0xFF949494),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 1),
                  Text(
                    "Due: ${DateFormatter.formatDateString(widget.homework.dueDate.toString())}",

                    style: context.textTheme.bodySmall!.copyWith(
                      color: Color(0xFF949494),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 3),
                  Text(
                    'Assigned by: ${widget.homework.user?.name ?? ""}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: Responsive.height * 3),

                  widget.homework.forStudent == true
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Homework Status:",
                            style: context.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Responsive.height * 2),
                          Row(
                            children: List.generate(5, (index) {
                              final points = widget.homework.studentPoints ?? 0;
                              return Icon(
                                index < points ? Icons.star : Icons.star_border,
                                color:
                                    index < points
                                        ? Colors.amber
                                        : Colors.grey.shade400,
                                size: 30,
                              );
                            }),
                          ),
                        ],
                      )
                      : Consumer<HomeworkProvider>(
                        builder: (context, provider, _) {
                          return GestureDetector(
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.homeworkRankingScreen,
                                extra: provider.singleHomework,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: Responsive.radius * 6,
                                    backgroundColor: const Color(0xffF4F4F4),
                                    child: const Icon(
                                      Icons.fact_check_outlined,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: Responsive.width * 20),

                                  Text(
                                    'Mark Homework',
                                    style: context.textTheme.bodyMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                  SizedBox(height: Responsive.height * 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
