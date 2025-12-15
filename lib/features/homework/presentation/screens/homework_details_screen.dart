import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/homework/data/models/homework_model.dart';
import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/download_file_card.dart';
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
        actions: [buildActions()],
      ),
      body: Consumer<HomeworkProvider>(
        builder: (context, provider, _) {
          final data = provider.singleHomework;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: context.paddingHorizontal.add(
                  EdgeInsets.only(top: Responsive.height * 2),
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _iconHeader(),
                      _gap(3),
                      _title(widget.homework.title),
                      _gap(2),
                      _decorativeDivider(),
                      _gap(2),
                      _description(widget.homework.description),
                      _gap(2),
                      Row(
                        children: [
                          Expanded(child: _dueDate(widget.homework.dueDate)),
                          SizedBox(width: 10),
                          Expanded(
                            child: _subjectCard(
                              widget.homework.forStudent == true
                                  ? widget.homework.subject?.subjectName
                                  : data?.subject?.subjectName,
                            ),
                          ),
                        ],
                      ),
                      _gap(2),
                      Row(
                        children: [
                          Expanded(
                            child: _infoCard(
                              icon: Icons.class_outlined,
                              title: "Class",
                              value:
                                  widget.homework.classGrade?.classname ??
                                  "Not Available",
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Consumer<HomeworkProvider>(
                              builder: (context, provider, _) {
                                return _infoCard(
                                  icon: Icons.upload_file,
                                  title: "Type",
                                  value:
                                      provider.singleHomework?.type ??
                                      "Not Mentioned",
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      _gap(2),

                      if (widget.homework.forStudent == true) ...[
                        _gap(2),
                        _assignedBy(widget.homework.user?.name ?? ""),
                      ],

                      _gap(2),
                      widget.homework.forStudent == true
                          ? _studentStatus(widget.homework.studentPoints)
                          : _markHomeworkButton(provider.singleHomework),

                      _gap(2),

                      Consumer<HomeworkProvider>(
                        builder: (context, provider, _) {
                          final homework = provider.singleHomework;
                          return homework?.file == null
                              ? SizedBox.shrink()
                              : DownloadFileCard(
                                fileName:
                                    "${MediaEndpoints.homeworks}${homework?.file}",
                              );
                        },
                      ),
                      const SizedBox(height: 16),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // APPBAR ACTIONS
  // ----------------------------------------------------------
  Widget buildActions() {
    if (widget.homework.forStudent == true) {
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () {
            context.pushNamed(
              RouteConstants.chatScreen,
              extra: ChatModel(
                opponentId:
                    widget.homework.forStaff == false
                        ? widget.homework.user?.id ?? 0
                        : widget.homework.guardianIdForChat ?? 0,
                opponentName:
                    widget.homework.forStaff == false
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
      );
    }

    return Consumer<HomeworkProvider>(
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
    );
  }

  // ----------------------------------------------------------
  // UI SECTION WIDGETS
  // ----------------------------------------------------------

  Widget _iconHeader() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFFCEDE).withAlpha(100),
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
  );

  Widget _title(String? title) => Text(
    capitalizeEachWord(title ?? ""),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 26,
      color: Color(0xFF1A1A1A),
      height: 1.3,
      letterSpacing: -0.5,
    ),
  );

  Widget _decorativeDivider() => Container(
    height: 3,
    width: 60,
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFFB14F6F), Colors.transparent]),
    ),
  );

  Widget _description(String? text) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Text(
      text ?? "",
      style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 15, height: 1.5),
    ),
  );

  Widget _dueDate(dynamic date) => _infoRowCard(
    icon: Icons.calendar_today,
    title: "Due Date",
    value: DateFormatter.formatDateString(date.toString()),
  );

  Widget _subjectCard(String? name) => _infoRowCard(
    icon: Icons.book_outlined,
    title: "Subject",
    value: capitalizeEachWord(name ?? ""),
  );

  Widget _assignedBy(String name) =>
      _infoCard(icon: Icons.person_outline, title: "Assigned By", value: name);

  Widget _infoRowCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCEDE).withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB14F6F).withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCEDE).withAlpha(100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Color(0xFFB14F6F)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFB14F6F),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentStatus(int? points) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFCEDE).withAlpha(80),
            const Color(0xFFFFCEDE).withAlpha(40),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB14F6F).withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < (points ?? 0) ? Icons.star : Icons.star_border,
                  color:
                      index < (points ?? 0)
                          ? Colors.amber
                          : Colors.grey.shade400,
                  size: 36,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _markHomeworkButton(HomeworkModel? homework) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouteConstants.homeworkRankingScreen,
          extra: homework,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB14F6F), Color(0xFFD17091)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB14F6F).withAlpha(80),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mark Homework',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Tap to evaluate students',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _gap(double h) => SizedBox(height: Responsive.height * h);
}
