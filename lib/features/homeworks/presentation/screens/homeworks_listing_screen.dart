import 'dart:developer';

import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/homeworks/data/models/homework_viewer_type.dart';
import 'package:acadobs/features/homeworks/presentation/provider/homeworks_provider.dart';
import 'package:acadobs/features/homeworks/presentation/widgets/create_homework_bottomsheet.dart';
import 'package:acadobs/routes/modules/common_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class HomeworksListingScreen extends StatefulWidget {
  final HomeworkParameters homeworkParams;
  const HomeworksListingScreen({super.key, required this.homeworkParams});

  @override
  State<HomeworksListingScreen> createState() => _HomeworksListingScreenState();
}

class _HomeworksListingScreenState extends State<HomeworksListingScreen> {
  final ScrollController _scrollController = ScrollController();
  late HomeworksProvider _provider;
  @override
  void initState() {
    log("Studentid------------ ${widget.homeworkParams.studentId}");
    super.initState();
    _provider = context.read<HomeworksProvider>();
    _provider.fetchHomeworks(
      forceRefresh: true,
      viewerType: widget.homeworkParams.viewerType,
      studentId: widget.homeworkParams.studentId,
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_provider.isLoadingHomeworks &&
          _provider.hasMore) {
        _provider.fetchHomeworks(
          loadMore: true,
          viewerType: widget.homeworkParams.viewerType,
          studentId: widget.homeworkParams.studentId,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Homeworks", isBackButton: true),
      body: RefreshIndicator(
        onRefresh:
            () => _provider.fetchHomeworks(
              forceRefresh: true,
              viewerType: widget.homeworkParams.viewerType,
              studentId: widget.homeworkParams.studentId,
            ),
        child: Consumer<HomeworksProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingHomeworks && provider.homeworks.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: commonShimmerList(),
              );
            }

            if (provider.homeworks.isEmpty) {
              return emptyScreen(message: 'No Homeworks Found.');
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: provider.homeworks.length + (provider.hasMore ? 2 : 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(height: Responsive.height * 3);
                }

                if (index == provider.homeworks.length + 1) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final grouped = provider.homeworks[index - 1];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatDateTime(
                        grouped.date ?? DateTime.now(),
                      ),
                      style: context.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: Responsive.height * 1),
                    ...grouped.homeworks!.map(
                      (hw) => ItemCard(
                        title: hw.title ?? "",
                        description:
                            widget.homeworkParams.viewerType ==
                                    HomeworkViewerType.teacherView
                                ? "Class: ${hw.classGrade?.classname ?? " "}"
                                : "${hw.subject?.subjectName ?? "Subject Not Mentioned"} - ${hw.user?.name ?? " "}",
                        iconColor: const Color(0xFFB14F6F),
                        backgroundColor: const Color(0xFFFFCEDE),
                        icon: LucideIcons.clipboardList,

                        onTap: () {
                          context.pushNamed(
                            RouteConstants.homeworkDetailsScreen,
                            queryParameters: {
                              'viewerType':
                                  widget.homeworkParams.viewerType.name,
                              'homeworkId': hw.id.toString(),
                              if (widget.homeworkParams.studentId != null)
                                'studentId':
                                    widget.homeworkParams.studentId.toString(),
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: Responsive.height * 2),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton:
          widget.homeworkParams.viewerType == HomeworkViewerType.teacherView
              ? Padding(
                padding: const EdgeInsets.all(16),
                child: CommonFloatingButton(
                  onPressed:
                      () => showCreateHomeworkBottomSheet(context: context),
                ),
              )
              : null,
    );
  }
}
