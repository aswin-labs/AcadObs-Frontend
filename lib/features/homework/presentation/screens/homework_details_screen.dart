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
              child: Consumer<HomeworkProvider>(
                builder: (context, provider, _) {
                  final singleHomework = provider.singleHomework;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Hero Container with Shadow
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFCEDE).withAlpha(100),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ItemDetailScreenContainer(
                          iconColor: Color(0xFFB14F6F),
                          backgroundColor: Color(0xFFFFCEDE),
                          icon: LucideIcons.clipboardList,
                        ),
                      ),

                      SizedBox(height: Responsive.height * 3),

                      // Title with better styling
                      Text(
                        capitalizeEachWord(widget.homework.title ?? ""),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                          letterSpacing: -0.5,
                        ),
                      ),

                      SizedBox(height: Responsive.height * 2),

                      // Decorative Divider
                      Container(
                        height: 3,
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB14F6F), Colors.transparent],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      SizedBox(height: Responsive.height * 2),

                      // Description Container
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.homework.description ?? "",
                          style: TextStyle(
                            color: Color(0xFF6B6B6B),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),

                      SizedBox(height: Responsive.height * 2),

                      // Due Date Card
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFCEDE).withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFFB14F6F).withAlpha(60),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFCEDE).withAlpha(100),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Color(0xFFB14F6F),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Due Date",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  DateFormatter.formatDateString(
                                    widget.homework.dueDate.toString(),
                                  ),
                                  style: TextStyle(
                                    color: Color(0xFFB14F6F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Responsive.height * 3),

                      // Subject Info Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Color(0xFFB14F6F).withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFFB14F6F).withAlpha(50),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFCEDE).withAlpha(100),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.book_outlined,
                                color: Color(0xFFB14F6F),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Subject",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    widget.homework.forStudent == true
                                        ? widget
                                                .homework
                                                .subject
                                                ?.subjectName ??
                                            ""
                                        : singleHomework
                                                ?.subject
                                                ?.subjectName ??
                                            "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFFB14F6F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Responsive.height * 2),

                      // Assigned By (for students only)
                      if (widget.homework.forStudent == true) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.grey.shade700,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Assigned By",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      widget.homework.user?.name ?? "",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.height * 3),
                      ],

                      // Student Status or Mark Homework
                      widget.homework.forStudent == true
                          ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFFCEDE).withAlpha(80),
                                  Color(0xFFFFCEDE).withAlpha(40),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Color(0xFFB14F6F).withAlpha(60),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.emoji_events_outlined,
                                      color: Color(0xFFB14F6F),
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Homework Status",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB14F6F),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (index) {
                                    final points =
                                        widget.homework.studentPoints ?? 0;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Icon(
                                        index < points
                                            ? Icons.star
                                            : Icons.star_border,
                                        color:
                                            index < points
                                                ? Colors.amber
                                                : Colors.grey.shade400,
                                        size: 36,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
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
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFB14F6F),
                                        Color(0xFFD17091),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFB14F6F).withAlpha(80),
                                        blurRadius: 15,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(50),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.fact_check_outlined,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Mark Homework',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Tap to evaluate students',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withAlpha(
                                                  200,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                      SizedBox(height: Responsive.height * 4),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:acadobs/core/extensions/context_extensions.dart';
// import 'package:acadobs/core/utils/custom_popup_menu.dart';
// import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
// import 'package:acadobs/core/utils/helpers/date_formatter.dart';
// import 'package:acadobs/core/utils/responsive.dart';
// import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
// import 'package:acadobs/features/chats/data/models/chat_model.dart';
// import 'package:acadobs/features/homework/data/models/homework_model.dart';
// import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
// import 'package:acadobs/routes/router_constants.dart';
// import 'package:acadobs/shared/widgets/common_appbar.dart';
// import 'package:acadobs/shared/widgets/item_detail_screen_container.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lucide_icons/lucide_icons.dart';
// import 'package:provider/provider.dart';

// class HomeworkDetailsScreen extends StatefulWidget {
//   final HomeworkModel homework;
//   const HomeworkDetailsScreen({super.key, required this.homework});

//   @override
//   State<HomeworkDetailsScreen> createState() => _HomeworkDetailsScreenState();
// }

// class _HomeworkDetailsScreenState extends State<HomeworkDetailsScreen> {
//   late HomeworkProvider homeworkProvider;
//   @override
//   void initState() {
//     homeworkProvider = context.read<HomeworkProvider>();
//     homeworkProvider.fetchSingleHomework(homeworkId: widget.homework.id ?? 0);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(
//         title: "Homework",
//         isBackButton: true,
//         actions: [
//           widget.homework.forStudent == true
//               ? Padding(
//                 padding: const EdgeInsets.only(right: 16),
//                 child: GestureDetector(
//                   onTap: () {
//                     context.pushNamed(
//                       RouteConstants.chatScreen,
//                       extra: ChatModel(
//                         opponentId:
//                             widget.homework.forParent == true
//                                 ? widget.homework.user?.id ?? 0
//                                 : widget.homework.guardianIdForChat ?? 0,
//                         opponentName:
//                             widget.homework.forParent == true
//                                 ? widget.homework.user?.name ?? ""
//                                 : widget.homework.guardianNameForChat ?? "",
//                         title: widget.homework.title ?? "",
//                         subtitle: widget.homework.description ?? "",
//                         msgType: "homeworks",
//                         typeId: widget.homework.studentHomeworkId,
//                       ),
//                     );
//                   },
//                   child: Icon(Icons.chat),
//                 ),
//               )
//               : Consumer<HomeworkProvider>(
//                 builder: (context, provider, _) {
//                   return CustomPopupMenu(
//                     onEdit: () {
//                       context.pushNamed(
//                         RouteConstants.editHomeWork,
//                         extra: widget.homework,
//                       );
//                     },
//                     onDelete: () {
//                       showConfirmationDialog(
//                         context: context,
//                         title: 'Delete Homework',
//                         content: 'Are you want to delete the homework',
//                         onConfirm: () {
//                           provider.deleteHomeWork(context);
//                         },
//                       );
//                     },
//                   );
//                 },
//               ),
//         ],
//       ),
//       body: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: context.paddingHorizontal.add(
//                 EdgeInsets.only(top: Responsive.height * 2),
//               ),
//               child: Consumer<HomeworkProvider>(
//                 builder: (context, provider, _) {
//                   final singleHomework = provider.singleHomework;
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ItemDetailScreenContainer(
//                         iconColor: Color(0xFFB14F6F),
//                         backgroundColor: Color(0xFFFFCEDE),
//                         icon: LucideIcons.clipboardList,
//                       ),
//                       SizedBox(height: Responsive.height * 3),
//                       Text(
//                         capitalizeEachWord(widget.homework.title ?? ""),
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                           color: Color(0xFF1A1A1A),
//                           height: 1.3,
//                           letterSpacing: -0.5,
//                         ),
//                         // style: context.textTheme.titleLarge!.copyWith(
//                         //   fontWeight: FontWeight.bold,
//                         // ),
//                       ),
//                       SizedBox(height: Responsive.height * 1),
//                       Container(
//                         padding: EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFFFCEDE).withAlpha(25),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: const Color(0xFFFFCEDE).withAlpha(51),
//                             width: 1,
//                           ),
//                         ),
//                         child: Text(
//                           widget.homework.description ?? "",
//                           style: context.textTheme.bodySmall!.copyWith(
//                             color: Color(0xFF949494),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: Responsive.height * 1),
//                       Text(
//                         "Due: ${DateFormatter.formatDateString(widget.homework.dueDate.toString())}",

//                         style: context.textTheme.bodySmall!.copyWith(
//                           color: Color(0xFF949494),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: Responsive.height * 3),

//                       // Decorative Divider
//                       Container(
//                         height: 3,
//                         width: 60,
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFFB14F6F), Color(0xFFFFCEDE)],
//                           ),
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       widget.homework.forStudent == true
//                           ? Text(
//                             'Subject: ${widget.homework.subject?.subjectName ?? ""}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           )
//                           : Text(
//                             'Subject ${singleHomework?.subject?.subjectName ?? ""}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                       SizedBox(height: Responsive.height * 3),
//                       widget.homework.forStudent == true
//                           ? Text(
//                             'Assigned by: ${widget.homework.user?.name ?? ""}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           )
//                           : SizedBox.shrink(),
//                       SizedBox(height: Responsive.height * 3),

//                       widget.homework.forStudent == true
//                           ? Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Homework Status:",
//                                 style: context.textTheme.titleMedium!.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: Responsive.height * 2),
//                               Row(
//                                 children: List.generate(5, (index) {
//                                   final points =
//                                       widget.homework.studentPoints ?? 0;
//                                   return Icon(
//                                     index < points
//                                         ? Icons.star
//                                         : Icons.star_border,
//                                     color:
//                                         index < points
//                                             ? Colors.amber
//                                             : Colors.grey.shade400,
//                                     size: 30,
//                                   );
//                                 }),
//                               ),
//                             ],
//                           )
//                           : Consumer<HomeworkProvider>(
//                             builder: (context, provider, _) {
//                               return GestureDetector(
//                                 onTap: () {
//                                   context.pushNamed(
//                                     RouteConstants.homeworkRankingScreen,
//                                     extra: provider.singleHomework,
//                                   );
//                                 },
//                                 child: Container(
//                                   padding: EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(8),
//                                     gradient: const LinearGradient(
//                                       colors: [
//                                         Color(0xFFB14F6F),
//                                         Color(0xFFFFCEDE),
//                                       ],
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       CircleAvatar(
//                                         radius: Responsive.radius * 6,
//                                         backgroundColor: const Color(
//                                           0xffF4F4F4,
//                                         ),
//                                         child: const Icon(
//                                           Icons.fact_check_outlined,
//                                           size: 25,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       SizedBox(width: Responsive.width * 20),

//                                       Text(
//                                         'Mark Homework',
//                                         style: context.textTheme.bodyMedium!
//                                             .copyWith(
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),

//                       SizedBox(height: Responsive.height * 4),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
