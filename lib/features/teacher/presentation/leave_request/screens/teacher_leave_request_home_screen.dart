import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/leave_status_style.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/provider/teacher_leave_request_provider.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/widgets/create_leave_request_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class TeacherLeaveRequestHomeScreen extends StatefulWidget {
  const TeacherLeaveRequestHomeScreen({super.key});

  @override
  State<TeacherLeaveRequestHomeScreen> createState() =>
      _TeacherLeaveRequestHomeScreenState();
}

class _TeacherLeaveRequestHomeScreenState
    extends State<TeacherLeaveRequestHomeScreen> {
  late final TeacherLeaveRequestProvider _teacherLeaveProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _teacherLeaveProvider = context.read<TeacherLeaveRequestProvider>();
    _teacherLeaveProvider.fetchAllLeaveRequests();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_teacherLeaveProvider.isLoading &&
        _teacherLeaveProvider.hasMore) {
      _teacherLeaveProvider.fetchAllLeaveRequests(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "My Leave Requests", isBackButton: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await context
              .read<TeacherLeaveRequestProvider>()
              .fetchAllLeaveRequests(forceRefresh: true);
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: context.paddingHorizontal.add(
                  EdgeInsets.only(top: Responsive.height * 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<TeacherLeaveRequestProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading &&
                            provider.leaveRequests.isEmpty) {
                          return commonShimmerList();
                        }

                        if (provider.leaveRequests.isEmpty) {
                          return emptyScreen(
                            message: 'No Leave Requests Found.',
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.leaveRequests.length,
                          itemBuilder: (context, index) {
                            final leaveRequest = provider.leaveRequests[index];
                            final leaveStatusStyle = getLeaveStatusStyle(
                              leaveRequest.status ?? "",
                            );
                            return ItemCard(
                              title: "${leaveRequest.leaveType} Leave",
                              description: DateFormatter.formatDateString(
                                leaveRequest.fromDate,
                              ),
                              status: leaveRequest.status ?? "",
                              backgroundColor: leaveStatusStyle.backgroundColor,
                              icon: leaveStatusStyle.icon,
                              iconColor: leaveStatusStyle.iconColor,
                              onTap:
                                  () => context.pushNamed(
                                    RouteConstants.staffLeaveRequestDetails,
                                    extra: leaveRequest,
                                  ),
                            );
                          },
                        );
                      },
                    ),
                    Consumer<TeacherLeaveRequestProvider>(
                      builder: (context, provider, _) {
                        return provider.isLoading && provider.hasMore
                            ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox();
                      },
                    ),

                    SizedBox(height: Responsive.height * 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: FloatingActionButton(
          onPressed: () => showCreateLeaveRequesBottomSheet(context, fromTeacherScreen: true),
          child: Icon(LucideIcons.plus, weight: 1, color: Colors.grey),
        ),
      ),
    );
  }
}
