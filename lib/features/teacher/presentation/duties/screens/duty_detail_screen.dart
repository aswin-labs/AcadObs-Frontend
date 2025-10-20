import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/duty_status_style.dart';

import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/data/models/staff_duty_model.dart';
import 'package:acadobs/features/teacher/presentation/duties/provider/duty_provider.dart';
import 'package:acadobs/features/teacher/presentation/duties/widgets/add_remarks_and_file_bottomsheet.dart';

import 'package:acadobs/features/teacher/presentation/duties/widgets/date_label_container.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/item_detail_screen_container.dart';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:provider/provider.dart';

class DutyDetailScreen extends StatefulWidget {
  final Request staffDuty;
  const DutyDetailScreen({super.key, required this.staffDuty});

  @override
  State<DutyDetailScreen> createState() => _DutyDetailScreenState();
}

class _DutyDetailScreenState extends State<DutyDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DutyProvider>().clearUpdatedDutyResponse();
      context.read<DutyProvider>().fetchSingleDuties(
        dutyId: widget.staffDuty.id ?? 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.staffDuty.status ?? 'pending';
    final style = getDutyStatusStyle(status);
    return Scaffold(
      appBar: CommonAppBar(title: "Duty Details", isBackButton: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: context.paddingHorizontal,
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Responsive.height * 2),
                  ItemDetailScreenContainer(
                    backgroundColor: style.backgroundColor,
                    iconColor: style.iconColor,
                    icon: style.icon,
                  ),

                  SizedBox(height: Responsive.height * 3),
                  Text(
                    widget.staffDuty.duty?.title ?? "",
                    style: context.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 1),
                  Text(
                    widget.staffDuty.duty?.description ?? "",
                    style: context.textTheme.bodySmall!.copyWith(
                      color: Color(0xFF949494),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 4),
                  Row(
                    children: [
                      DateLabelContainer(
                        label: "Start date",
                        dateText:
                            widget.staffDuty.duty?.startDate != null
                                ? DateFormatter.formatDateTime(
                                  widget.staffDuty.duty!.startDate!,
                                )
                                : 'N/A',
                      ),
                      SizedBox(width: Responsive.width * 5),
                      DateLabelContainer(
                        label: "End date",
                        dateText:
                            widget.staffDuty.duty?.deadline != null
                                ? DateFormatter.formatDateTime(
                                  widget.staffDuty.duty!.deadline!,
                                )
                                : 'N/A',
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.height * 2),
                  Consumer<DutyProvider>(
                    builder: (context, provider, _) {
                      final updated = provider.updatedDutyResponse;

                      final displayStatus = updated?.status ?? status;
                      final displayRemarks =
                          updated?.remarks ?? (widget.staffDuty.remarks ?? '');
                      final displayDutyId =
                          updated?.id ?? (widget.staffDuty.id ?? 0);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remarks added by you: ',
                            style: context.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: Responsive.height * 1),
                          Text(
                            capitalizeFirstLetter(displayRemarks),
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: Responsive.height * 6),

                          if (displayStatus != "in_progress" &&
                              displayStatus != "completed")
                            CommonButton(
                              onPressed:
                                  () => provider.updateDutyStatusInProgress(
                                    context: context,
                                    dutyId: displayDutyId,
                                  ),
                              widget: Text("Mark In Progress"),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          SizedBox(height: Responsive.height * 2),

                          if (displayStatus == "completed")
                            CommonButton(
                              onPressed: () {},
                              widget: Text("Completed"),
                              backgroundColor: Color.fromARGB(255, 60, 73, 61),
                            )
                          else
                            CommonButton(
                              onPressed:
                                  () => provider.updateDutyStatusToCompleted(
                                    context: context,
                                    dutyId: displayDutyId,
                                  ),
                              widget: Text("Mark As Completed"),
                              backgroundColor: Color(0xFF14601C),
                            ),
                          SizedBox(height: Responsive.height * 10),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => showAddRemarksAndFileBottomSheet(
              context,
              dutyId: widget.staffDuty.duty?.id ?? 0,
            ),
        child: Icon(LucideIcons.filePlus2, weight: 1, color: Colors.grey),
      ),
    );
  }
}
