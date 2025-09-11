import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/chats/presentation/provider/chat_provider.dart';
import 'package:acadobs/features/parents/presentation/widgets/staff_details_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeachersListingScreen extends StatefulWidget {
  const TeachersListingScreen({super.key});

  @override
  State<TeachersListingScreen> createState() => _TeachersListingScreenState();
}

class _TeachersListingScreenState extends State<TeachersListingScreen> {
  late final ChatProvider _chatProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _chatProvider.fetchStaffsUnderSchool();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom && !_chatProvider.isLoading && _chatProvider.hasMore) {
      _chatProvider.fetchStaffsUnderSchool(loadMore: true);
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
      appBar: CommonAppBar(title: "Teachers"),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ChatProvider>().fetchStaffsUnderSchool(
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
                    Consumer<ChatProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading && provider.staffs.isEmpty) {
                          return commonShimmerList();
                        }

                        if (provider.staffs.isEmpty) {
                          return emptyScreen(message: 'No Duties Found.');
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.staffs.length,
                          itemBuilder: (context, index) {
                            final staff = provider.staffs[index];
                            return StaffDetailsCard(
                              name: staff.name ?? "",
                              designation: staff.email ?? "",
                              email: staff.email ?? "",
                              phone: staff.phone ?? "",
                              department: "",
                              backgroundColor: Colors.white,
                              borderColor: Colors.blueGrey.shade100,
                            );
                          },
                        );
                      },
                    ),
                    Consumer<ChatProvider>(
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
    );
  }
}
