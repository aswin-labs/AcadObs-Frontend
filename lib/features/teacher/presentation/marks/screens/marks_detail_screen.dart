import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/detail_section.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/data/models/marks/marks_model.dart';
import 'package:acadobs/features/teacher/presentation/marks/provider/marks_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MarksDetailScreen extends StatefulWidget {
  final MarksModel marks;
  const MarksDetailScreen({super.key, required this.marks});

  @override
  State<MarksDetailScreen> createState() => _MarksDetailScreenState();
}

class _MarksDetailScreenState extends State<MarksDetailScreen> {
  late MarksProvider marksProvider;
  @override
  void initState() {
    super.initState();
    marksProvider = context.read<MarksProvider>();
    marksProvider.fetchSingleMarks(marksId: widget.marks.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Marks",
        isBackButton: true,
        actions: [
          CustomPopupMenu(
            showDelete: false,
            onEdit:
                () => context.pushNamed(
                  RouteConstants.marksEdit,
                  extra: widget.marks,
                ),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                      "Title": widget.marks.internalName,
                      "Class": widget.marks.classGrade?.classname ?? "",
                      "Total Marks": widget.marks.maxMarks,
                      "Date": DateFormatter.formatDateTime(
                        widget.marks.date ?? DateTime.now(),
                      ),
                      "Subject":
                          widget.marks.subject?.subjectName ?? "Not Specified",
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
