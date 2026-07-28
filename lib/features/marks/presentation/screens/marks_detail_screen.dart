import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/detail_section.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MarksDetailScreen extends StatefulWidget {
  final MarkDetailParameters marksParams;
  const MarksDetailScreen({super.key, required this.marksParams});

  @override
  State<MarksDetailScreen> createState() => _MarksDetailScreenState();
}

class _MarksDetailScreenState extends State<MarksDetailScreen> {
  late MarksProvider marksProvider;
  @override
  void initState() {
    super.initState();
    marksProvider = context.read<MarksProvider>();
    marksProvider.fetchSingleMarks(marksId: widget.marksParams.mark.id);
  }

  @override
  Widget build(BuildContext context) {
    final mark = widget.marksParams.mark;
    final title =
        mark.termExam?.examName == null
            ? capitali(mark.internalName)
            : capitali(
              "${mark.termExam?.examName ?? ''} - ${mark.internalName} (${mark.termExam?.educationYear ?? ''}) ",
            );
    return HeroMode(
      enabled: false,
      child: Scaffold(
        appBar: CommonAppBar(
          title: "Marks",
          isBackButton: true,
          actions: [
            widget.marksParams.isEditNeeded
                ? Consumer<TermExamProvider>(
                  builder: (context, provider, _) {
                    return CustomPopupMenu(
                      onEdit:
                          () => context.pushNamed(
                            RouteConstants.marksEdit,
                            extra: widget.marksParams.mark,
                          ),
                      onDelete:
                          () => showConfirmationDialog(
                            context: context,
                            title: 'Delete Marks',
                            content:
                                'Are you sure you want to delete this marks entry?',
                            onConfirm: () {
                              provider.deleteTermExamMarks(
                                context: context,
                                marksId: mark.id,
                              );
                            },
                          ),
                    );
                  },
                )
                : SizedBox.shrink(),
          ],
        ),
        body: CustomScrollView(
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: context.paddingHorizontal.add(
                  EdgeInsets.only(top: Responsive.height * 2),
                ),
                child: Column(
                  children: [
                    DetailSection(
                      title: "Details",
                      details: {
                        "Title": title,
                        "Class": mark.classGrade?.classname ?? "",
                        "Total Marks": mark.maxMarks,
                        "Date": DateFormatter.formatDateTime(
                          mark.date ?? DateTime.now(),
                        ),
                        "Subject": mark.subject?.subjectName ?? "Not Specified",
                      },
                    ),
                    SizedBox(height: Responsive.height * 2),
                    Consumer<MarksProvider>(
                      builder: (context, provider, _) {
                        if (provider.singleMarks?.studentMarks == null) {
                          return commonShimmerList();
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: provider.singleMarks?.studentMarks!.length,
                          itemBuilder: (context, index) {
                            final studentMark =
                                provider.singleMarks?.studentMarks?[index];
                            return _gradeCard(
                              name: studentMark?.student?.fullName ?? "",
                              rollNumber: studentMark?.student?.rollNumber ?? 0,
                              isAbsent: studentMark?.status == "absent",
                              mark: studentMark?.marksObtained ?? "0",
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: Responsive.height * 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradeCard({
    required int rollNumber,
    required String name,
    required String mark,
    required bool isAbsent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 1,
              color: Colors.grey.withAlpha(80),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 60,
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF4F4F4),
                child: Text(
                  rollNumber.toString(),
                  style: const TextStyle(
                    color: Color(0xFF7C7C7C),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white,
                height: 60,
                child: Text(
                  capitalizeEachWord(name),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Container(color: Colors.grey[200], width: 2, height: 60),

            // --- Marks TextField ---
            Container(
              width: 60,
              height: 60,
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(mark.toString()),
            ),

            // --- Attendance Toggle ---
            Container(
              width: 40,
              height: 60,
              alignment: Alignment.center,
              color: isAbsent ? Colors.red : Colors.grey[200],
              child: Text(
                isAbsent ? "A" : "P",
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
