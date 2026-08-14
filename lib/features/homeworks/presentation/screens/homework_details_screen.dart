import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/homeworks/data/models/homework_model.dart';
import 'package:acadobs/features/homeworks/data/models/homework_viewer_type.dart';
import 'package:acadobs/features/homeworks/presentation/provider/homeworks_provider.dart';
import 'package:acadobs/features/homeworks/presentation/widgets/homework_points_view_card.dart';
import 'package:acadobs/features/homeworks/presentation/widgets/homework_submission_dialog.dart';
import 'package:acadobs/features/homeworks/presentation/widgets/remove_student_homework_dialog.dart';
import 'package:acadobs/routes/modules/common_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/download_file_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeworkDetailsScreen extends StatefulWidget {
  final HomeworkParameters homeworkParams;
  const HomeworkDetailsScreen({super.key, required this.homeworkParams});

  @override
  State<HomeworkDetailsScreen> createState() => _HomeworkDetailsScreenState();
}

class _HomeworkDetailsScreenState extends State<HomeworkDetailsScreen> {
  late HomeworksProvider homeworkProvider;

  @override
  void initState() {
    homeworkProvider = context.read<HomeworksProvider>();
    homeworkProvider.fetchSingleHomework(
      viewerType: widget.homeworkParams.viewerType,
      homeworkId: widget.homeworkParams.homeworkId!,
      studentId: widget.homeworkParams.studentId,
    );
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
      body: Consumer<HomeworksProvider>(
        builder: (context, provider, _) {
          final homework = provider.singleHomework;
          final dueDate = provider.singleHomework?.dueDate;

          return provider.isLoadingSingleHomework
              ? Center(child: CircularProgressIndicator(color: Colors.grey))
              : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: context.paddingHorizontal.add(
                      EdgeInsets.only(top: Responsive.height * 2),
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // _iconHeader(),
                          _gap(1),
                          _title(homework?.title),
                          _gap(2),
                          _decorativeDivider(),
                          _gap(2),
                          _description(homework?.description),
                          _gap(1),
                          if (homework?.file != null)
                            DownloadFileCard(
                              fileName: homework?.file ?? "",
                              small: true,
                            ),
                          _gap(1),
                          widget.homeworkParams.viewerType ==
                                  HomeworkViewerType.teacherView
                              ? SizedBox.shrink()
                              : _assignedBy(homework?.user?.name ?? ""),
                          _gap(1),

                          Row(
                            children: [
                              Expanded(
                                child: _infoCard(
                                  icon: Icons.calendar_today,
                                  title: "Due Date",
                                  value: DateFormatter.formatDateTime(
                                    dueDate ?? DateTime.now(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _infoCard(
                                  icon: Icons.book_outlined,
                                  title: "Class",
                                  value:
                                      homework?.subject?.subjectName ??
                                      "Not Available",
                                ),
                              ),
                            ],
                          ),
                          _gap(1),
                          Row(
                            children: [
                              Expanded(
                                child: _infoCard(
                                  icon: Icons.class_outlined,
                                  title: "Class",
                                  value:
                                      homework?.classGrade?.classname ??
                                      "Not Available",
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Consumer<HomeworksProvider>(
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

                          if (widget.homeworkParams.viewerType ==
                                  HomeworkViewerType.teacherStudentView ||
                              widget.homeworkParams.viewerType ==
                                  HomeworkViewerType.guardianStudentView)
                            HomeworkPointsViewCard(
                              studentName:
                                  homework
                                      ?.studentHomeworkStatus?[0]
                                      .student
                                      ?.fullName ??
                                  "",
                              rollNumber:
                                  homework
                                      ?.studentHomeworkStatus?[0]
                                      .student
                                      ?.rollNumber
                                      .toString() ??
                                  "",
                              points:
                                  homework?.studentHomeworkStatus?[0].points ??
                                  0,
                              remarks:
                                  homework?.studentHomeworkStatus?[0].remark ??
                                  "",
                              fileName:
                                  homework
                                      ?.studentHomeworkStatus?[0]
                                      .solvedFile,
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _studentPointsButton(homework),
                                _gap(2),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount:
                                      homework?.studentHomeworkStatus?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final studentHomework =
                                        homework?.studentHomeworkStatus?[index];
                                    return HomeworkPointsViewCard(
                                      studentName:
                                          studentHomework?.student?.fullName ??
                                          "",
                                      rollNumber:
                                          studentHomework?.student?.rollNumber
                                              ?.toString() ??
                                          "",
                                      points: studentHomework?.points ?? 0,
                                      fileName: studentHomework?.solvedFile,
                                      remarks: studentHomework?.remark,
                                    );
                                  },
                                ),
                                if (widget.homeworkParams.viewerType ==
                                    HomeworkViewerType.teacherView) ...[
                                  _gap(2),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        context.pushNamed(
                                          RouteConstants
                                              .addMissingHomeworkStudentRanking,
                                          queryParameters: {
                                            'homeworkId':
                                                (homework?.id ?? 0).toString(),
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text("Add More Students"),
                                    ),
                                  ),
                                  _gap(1),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) =>
                                              RemoveStudentHomeworkDialog(
                                            homeworkId: homework?.id ?? 0,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        "Remove Option",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          _gap(2),
                          if (widget.homeworkParams.viewerType ==
                                  HomeworkViewerType.guardianStudentView &&
                              homework?.type == "online")
                            CommonButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  builder: (_) {
                                    return HomeworkSubmissionDialog(
                                      studentId:
                                          widget.homeworkParams.studentId ?? 0,
                                      homeworkId:
                                          widget.homeworkParams.homeworkId ?? 0,
                                      homeworkTitle:
                                          homework?.title ?? "Homework",
                                      studentHomeworkId:
                                          homework
                                              ?.studentHomeworkStatus?[0]
                                              .id ??
                                          0,
                                    );
                                  },
                                );
                              },
                              widget: Text("Upload Assignment"),
                            ),
                          _gap(10),
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
    if (widget.homeworkParams.viewerType == HomeworkViewerType.teacherView) {
      return Consumer<HomeworksProvider>(
        builder: (context, provider, _) {
          return CustomPopupMenu(
            onEdit: () {
              context.pushNamed(
                RouteConstants.editHomeWork,
                extra: provider.singleHomework,
              );
            },
            onDelete: () {
              showConfirmationDialog(
                context: context,
                title: 'Delete Homework',
                content: 'Are you want to delete the homework',
                onConfirm: () {
                  provider.deleteHomeWork(context: context);
                },
              );
            },
          );
        },
      );
    }
    return Padding(padding: const EdgeInsets.only(right: 16));
  }

  // ----------------------------------------------------------
  // UI SECTION WIDGETS
  // ----------------------------------------------------------

  Widget _title(String? title) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE9ECEF)),
    ),
    child: Text(
      capitalizeEachWord(title ?? ""),
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: Color(0xFF1A1A1A),
        height: 1.3,
      ),
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
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE9ECEF)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Text(
      text ?? "",
      style: const TextStyle(
        color: Color(0xFF606060),
        fontSize: 15,
        height: 1.6,
      ),
    ),
  );

  Widget _assignedBy(String name) =>
      _infoCard(icon: Icons.person_outline, title: "Assigned By", value: name);

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
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
            child: Icon(icon, color: Colors.grey.shade700, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _studentPointsButton(HomeworkModel? homework) {
    final isButton =
        widget.homeworkParams.viewerType == HomeworkViewerType.teacherView;

    return GestureDetector(
      onTap:
          isButton
              ? () {
                context.pushNamed(
                  RouteConstants.homeworkRankingScreen,
                  extra: homework,
                );
              }
              : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: isButton ? 11 : 8,
        ),
        decoration: BoxDecoration(
          color:
              isButton
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF6366F1).withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              isButton
                  ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withAlpha(60),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 18,
              color: isButton ? Colors.white : const Color(0xFF6366F1),
            ),
            const SizedBox(width: 6),
            Text(
              isButton ? 'Add / Edit Student Points' : 'Student Points',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isButton ? Colors.white : const Color(0xFF6366F1),
              ),
            ),

            if (isButton) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _gap(double h) => SizedBox(height: Responsive.height * h);
}
