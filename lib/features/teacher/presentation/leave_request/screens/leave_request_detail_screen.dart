import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/leave_status_style.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
import 'package:acadobs/features/teacher/presentation/duties/widgets/date_label_container.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/download_file_card.dart';
import 'package:acadobs/shared/widgets/item_detail_screen_container.dart';
import 'package:flutter/material.dart';

class LeaveRequestDetailScreen extends StatelessWidget {
  final LeaveModel leave;
  const LeaveRequestDetailScreen({super.key, required this.leave});

  @override
  Widget build(BuildContext context) {
    final leaveStatusStyle = getLeaveStatusStyle(leave.status ?? "");
    return Scaffold(
      appBar: CommonAppBar(title: "My Leave Requests", isBackButton: true),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Hero Container with Shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: leaveStatusStyle.backgroundColor.withAlpha(
                            100,
                          ),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ItemDetailScreenContainer(
                      backgroundColor: leaveStatusStyle.backgroundColor,
                      icon: leaveStatusStyle.icon,
                      iconColor: leaveStatusStyle.iconColor,
                    ),
                  ),

                  SizedBox(height: Responsive.height * 3),

                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: leaveStatusStyle.iconColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: leaveStatusStyle.iconColor.withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          leaveStatusStyle.icon,
                          size: 16,
                          color: leaveStatusStyle.iconColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          capitalizeEachWord("${leave.status}"),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: leaveStatusStyle.iconColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.height * 2),

                  // Title with better styling
                  Text(
                    capitalizeEachWord("${leave.leaveType} Leave"),
                    style: context.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      letterSpacing: -0.5,
                    ),
                  ),

                  SizedBox(height: Responsive.height * 1.5),

                  // Decorative Divider
                  Container(
                    height: 3,
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          leaveStatusStyle.iconColor,
                          leaveStatusStyle.iconColor.withAlpha(0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  SizedBox(height: Responsive.height * 2),

                  // Reason Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reason",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          leave.reason ?? "",
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: Color(0xFF949494),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.height * 3),

                  // Duration Info Card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: leaveStatusStyle.iconColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: leaveStatusStyle.iconColor.withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: leaveStatusStyle.iconColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.event_available,
                            color: leaveStatusStyle.iconColor,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Leave Duration",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              capitalizeEachWord("${leave.leaveDuration} Day"),
                              style: context.textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: leaveStatusStyle.iconColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.height * 3),

                  // Date Range Section Header
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Date Range",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: DateLabelContainer(
                          label: "Start date",
                          dateText: DateFormatter.formatDateString(
                            leave.fromDate.toString(),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: DateLabelContainer(
                          label: "End date",
                          dateText: DateFormatter.formatDateString(
                            leave.toDate.toString(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Responsive.height * 3),

                  if (leave.attachment != null &&
                      leave.attachment!.isNotEmpty) ...[
                    // Attachment Section Header
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Attachment",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DownloadFileCard(
                      fileName:
                          "${MediaEndpoints.leaveRequests}${leave.attachment}",
                    ),
                    SizedBox(height: Responsive.height * 2),
                  ],

                  SizedBox(height: Responsive.height * 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:acadobs/core/extensions/context_extensions.dart';
// import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
// import 'package:acadobs/core/utils/helpers/date_formatter.dart';
// import 'package:acadobs/core/utils/helpers/leave_status_style.dart';
// import 'package:acadobs/core/utils/responsive.dart';
// import 'package:acadobs/core/utils/urls/media_end_points.dart';
// import 'package:acadobs/features/teacher/data/models/leave_model.dart';
// import 'package:acadobs/features/teacher/presentation/duties/widgets/date_label_container.dart';
// import 'package:acadobs/shared/widgets/common_appbar.dart';
// import 'package:acadobs/shared/widgets/download_file_card.dart';
// import 'package:acadobs/shared/widgets/item_detail_screen_container.dart';
// import 'package:flutter/material.dart';

// class LeaveRequestDetailScreen extends StatelessWidget {
//   final LeaveModel leave;
//   const LeaveRequestDetailScreen({super.key, required this.leave});

//   @override
//   Widget build(BuildContext context) {
//     final leaveStatusStyle = getLeaveStatusStyle(leave.status ?? "");
//     return Scaffold(
//       appBar: CommonAppBar(title: "My Leave Requests", isBackButton: true),
//       body: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: context.paddingHorizontal.add(
//                 EdgeInsets.only(top: Responsive.height * 3),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ItemDetailScreenContainer(
//                     backgroundColor: leaveStatusStyle.backgroundColor,
//                     icon: leaveStatusStyle.icon,
//                     iconColor: leaveStatusStyle.iconColor,
//                   ),
//                   SizedBox(height: Responsive.height * 3),
//                   Text(
//                     capitalizeEachWord("${leave.leaveType} Leave"),
//                     style: context.textTheme.titleLarge!.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: Responsive.height * 1),
//                   Text(
//                     leave.reason ?? "",
//                     style: context.textTheme.bodySmall!.copyWith(
//                       color: Color(0xFF949494),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: Responsive.height * 2),
//                   Text(
//                     "Leave Duration: ",
//                     style: context.textTheme.bodyMedium!.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Text(
//                     capitalizeEachWord("${leave.leaveDuration} Day"),
//                     style: context.textTheme.bodyLarge!.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(height: Responsive.height * 4),
//                   Row(
//                     children: [
//                       DateLabelContainer(
//                         label: "Start date",
//                         dateText: DateFormatter.formatDateString(
//                           leave.fromDate.toString(),
//                         ),
//                       ),
//                       SizedBox(width: Responsive.width * 5),
//                       DateLabelContainer(
//                         label: "End date",
//                         dateText: DateFormatter.formatDateString(
//                           leave.toDate.toString(),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.height * 4),
//                   Text(
//                     "Status: ",
//                     style: context.textTheme.bodyMedium!.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Text(
//                     capitalizeEachWord("${leave.status}"),
//                     style: context.textTheme.bodyLarge!.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: leaveStatusStyle.iconColor,
//                     ),
//                   ),
//                   SizedBox(height: Responsive.height * 3),

//                   if (leave.attachment != null && leave.attachment!.isNotEmpty)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Attachment:",
//                           style: context.textTheme.bodyMedium!.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         DownloadFileCard(
//                           fileName:
//                               "${MediaEndpoints.leaveRequests}${leave.attachment}",
//                         ),
//                       ],
//                     ),

//                   SizedBox(height: Responsive.height * 2),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
