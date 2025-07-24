import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/homework/provider/homework_provider.dart';
import 'package:acadobs/features/teacher/presentation/homework/widgets/create_homework_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class HomeworksHomeScreen extends StatefulWidget {
  const HomeworksHomeScreen({super.key});

  @override
  State<HomeworksHomeScreen> createState() => _HomeworksHomeScreenState();
}

class _HomeworksHomeScreenState extends State<HomeworksHomeScreen> {
  late final HomeworkProvider _homeworkProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _homeworkProvider = context.read<HomeworkProvider>();
    _homeworkProvider.fetchHomeworks();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_homeworkProvider.isLoading &&
        _homeworkProvider.hasMore) {
      _homeworkProvider.fetchHomeworks(loadMore: true);
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
      appBar: CommonAppBar(title: "Homeworks", isBackButton: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<HomeworkProvider>().fetchHomeworks(
            forceRefresh: true,
          );
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
                    Consumer<HomeworkProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading && provider.homeworks.isEmpty) {
                          return commonShimmerList();
                        }

                        if (provider.homeworks.isEmpty) {
                          return emptyScreen(message: 'No Homeworks Found.');
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.homeworks.length,
                          itemBuilder: (context, index) {
                            final homework = provider.homeworks[index];

                            return ItemCard(
                              title: homework.title ?? "",
                              description:
                                  "Due: ${DateFormatter.formatDateString(homework.dueDate.toString())}",
                              iconColor: Color(0xFFB14F6F),
                              backgroundColor: Color(0xFFFFCEDE),
                              icon: LucideIcons.clipboardList,
                              onTap:
                                  () => context.pushNamed(
                                    RouteConstants.homeworkDetails,
                                    extra: homework,
                                  ),
                            );
                          },
                        );
                      },
                    ),
                    Consumer<HomeworkProvider>(
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
          onPressed: () => showCreateHomeworkBottomSheet(context: context),
          child: Icon(LucideIcons.plus, weight: 1, color: Colors.grey),
        ),
      ),
    );
  }
}
