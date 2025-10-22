import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/leave_status_style.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
import 'package:acadobs/features/teacher/presentation/duties/widgets/date_label_container.dart';
import 'package:acadobs/shared/providers/file_download_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/download_button.dart';
import 'package:acadobs/shared/widgets/item_detail_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                    capitalizeEachWord("${leave.leaveDuration} Day"),
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

                  SizedBox(height: 20),
                  if (leave.attachment != null && leave.attachment!.isNotEmpty)
                    Text(
                      "Attachment:",
                      style: context.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  SizedBox(height: 10),

                  Container(
                    width: 300,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: context.colorScheme.outline.withAlpha(102),
                        width: 1.0,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.insert_drive_file_rounded,
                              size: 36,
                              color: Colors.red,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              leave.attachment ?? "No Attachment",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: context.textTheme.bodyLarge!.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Consumer<FileDownloadProvider>(
                    builder: (context, provider, _) {
                      return DownloadButton(
                        onTap:
                            () => provider.downloadFile(
                              fileName:
                                  "${MediaEndpoints.leaveRequests}${leave.attachment}",
                            ),
                        isDownloading: provider.isDownloading,
                        progress: provider.progress,
                      );
                    },
                  ),

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
