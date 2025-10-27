import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/leave_status_style.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
import 'package:acadobs/features/teacher/presentation/duties/widgets/date_label_container.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/provider/teacher_leave_request_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/download_file_card.dart';
import 'package:acadobs/shared/widgets/item_detail_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentLeaveRequestDetailsScreen extends StatelessWidget {
  final LeaveModel leave;
  const StudentLeaveRequestDetailsScreen({super.key, required this.leave});

  @override
  Widget build(BuildContext context) {
    final leaveStatusStyle = getLeaveStatusStyle(leave.status ?? "");
    return Scaffold(
      appBar: CommonAppBar(title: "Leave Request", isBackButton: true),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemDetailScreenContainer(
                    backgroundColor: leaveStatusStyle.backgroundColor,
                    icon: leaveStatusStyle.icon,
                    iconColor: leaveStatusStyle.iconColor,
                  ),
                  SizedBox(height: Responsive.height * 3),
                  Text(
                    capitalizeEachWord("${leave.leaveType} Leave"),
                    style: context.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 1),
                  Text(
                    leave.reason ?? "",
                    style: context.textTheme.bodySmall!.copyWith(
                      color: Color(0xFF949494),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 2),
                  Text(
                    "Leave Duration: ",
                    style: context.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    leave.leaveDuration == "full"
                        ? capitalizeEachWord("${leave.leaveDuration} Day")
                        : capitalizeEachWord(
                          "${leave.leaveDuration} Day - (${leave.halfSection})",
                        ),
                    style: context.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 4),
                  Row(
                    children: [
                      DateLabelContainer(
                        label: "Start date",
                        dateText: DateFormatter.formatDateString(
                          leave.fromDate.toString(),
                        ),
                      ),
                      SizedBox(width: Responsive.width * 5),
                      DateLabelContainer(
                        label: "End date",
                        dateText: DateFormatter.formatDateString(
                          leave.toDate.toString(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.height * 4),
                  Text(
                    "Status: ",
                    style: context.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    capitalizeEachWord("${leave.status}"),
                    style: context.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: leaveStatusStyle.iconColor,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 4),

                  if (leave.attachment != null && leave.attachment!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Attachment:",
                          style: context.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        DownloadFileCard(
                          fileName:
                              "${MediaEndpoints.leaveRequests}${leave.attachment}",
                        ),
                      ],
                    ),
                  leave.forStudentLeavePermission == true
                      ? Consumer<TeacherLeaveRequestProvider>(
                        builder: (context, provider, _) {
                          return Column(
                            children: [
                              SizedBox(height: Responsive.height * 4),
                              leave.status == 'approved'
                                  ? SizedBox.shrink()
                                  : CommonButton(
                                    onPressed: () {
                                      provider.studentLeavePermission(
                                        context: context,
                                        leaveRequestId: leave.id ?? 0,
                                        status: "approved",
                                      );
                                    },
                                    widget: Text("Approve"),
                                    backgroundColor: Color(0xFF14601C),
                                  ),
                              SizedBox(height: Responsive.height * 2),
                              leave.status == 'rejected'
                                  ? SizedBox.shrink()
                                  : CommonButton(
                                    onPressed: () {
                                      provider.studentLeavePermission(
                                        context: context,
                                        leaveRequestId: leave.id ?? 0,
                                        status: "rejected",
                                      );
                                    },
                                    widget: Text("Reject"),
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      231,
                                      42,
                                      42,
                                    ),
                                  ),
                            ],
                          );
                        },
                      )
                      : SizedBox.shrink(),
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
