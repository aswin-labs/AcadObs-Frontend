import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/features/homework/presentation/widgets/create_homework_bottomsheet.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class HomeworksHomeScreen extends StatefulWidget {
  final bool forClassTeacher;
  const HomeworksHomeScreen({super.key, required this.forClassTeacher});

  @override
  State<HomeworksHomeScreen> createState() => _HomeworksHomeScreenState();
}

class _HomeworksHomeScreenState extends State<HomeworksHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  late final HomeworkProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<HomeworkProvider>();
    _provider.fetchHomeworks(
      forceRefresh: true,
      forClassTeacher: widget.forClassTeacher,
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_provider.isLoading &&
          _provider.hasMore) {
        _provider.fetchHomeworks(
          loadMore: true,
          forClassTeacher: widget.forClassTeacher,
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
              forClassTeacher: widget.forClassTeacher,
            ),
        child: Consumer<HomeworkProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.homeworks.isEmpty) {
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
                            widget.forClassTeacher
                                ? "${hw.subject?.subjectName ?? "Subject Not Mentioned"} - ${hw.user?.name ?? " "}"
                                : hw.classGrade?.classname ?? "",
                        iconColor: const Color(0xFFB14F6F),
                        status:
                            widget.forClassTeacher
                                ? ""
                                : "Due: ${DateFormatter.formatDateTime(hw.dueDate ?? DateTime.now())}",
                        backgroundColor: const Color(0xFFFFCEDE),
                        icon: LucideIcons.clipboardList,

                        onTap:
                            () =>
                                widget.forClassTeacher
                                    ? context.pushNamed(
                                      RouteConstants.homeworkRankingScreen,
                                      extra: HomeworkRankScreenParameters(
                                        homework: hw,
                                        forClassTeacher: widget.forClassTeacher,
                                      ),
                                    )
                                    : context.pushNamed(
                                      RouteConstants.homeworkDetails,
                                      extra: hw,
                                    ),
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
          widget.forClassTeacher
              ? null
              : Padding(
                padding: const EdgeInsets.all(16),
                child: CommonFloatingButton(
                  onPressed:
                      () => showCreateHomeworkBottomSheet(context: context),
                ),
              ),
    );
  }
}
