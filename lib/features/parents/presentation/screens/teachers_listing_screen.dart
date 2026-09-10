import 'dart:async';

import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider.fetchStaffsUnderSchool(forceRefresh: true);
    });
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_chatProvider.isLoadingStaffs &&
        _chatProvider.hasMoreStaffs) {
      _chatProvider.fetchStaffsUnderSchool(loadMore: true);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {});
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      _chatProvider.fetchStaffsUnderSchool(
        forceRefresh: true,
        query: trimmed.isEmpty ? null : trimmed,
      );
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Teachers"),
      body: RefreshIndicator(
        onRefresh: () async {
          final query = _searchController.text.trim();
          await context.read<ChatProvider>().fetchStaffsUnderSchool(
            forceRefresh: true,
            query: query.isEmpty ? null : query,
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
                    // Search Bar
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.04),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search teachers...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.blueGrey,
                            size: 22,
                          ),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                  : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blueGrey.shade100,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blueGrey.shade100,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blueGrey,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    Consumer<ChatProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingStaffs &&
                            provider.staffs.isEmpty) {
                          return commonShimmerList();
                        }

                        if (provider.staffs.isEmpty) {
                          return emptyScreen(message: 'No Teachers Found.');
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.staffs.length,
                          itemBuilder: (context, index) {
                            final staff = provider.staffs[index];
                            final subjects = (staff.staff?.staffSubjects ?? [])
                                .map(
                                  (subject) =>
                                      subject.subject?.subjectName ?? '',
                                )
                                .where((name) => name.isNotEmpty)
                                .join(', ');

                            final dp = staff.dp ?? '';
                            final profileImageUrl =
                                dp.isNotEmpty
                                    ? (dp.startsWith('http')
                                        ? dp
                                        : '${BaseUrls.media}${MediaEndpoints.dp}$dp')
                                    : '';

                            return StaffDetailsCard(
                              name: staff.name ?? "",
                              subjects: subjects,
                              email: staff.email ?? "",
                              phone: staff.phone ?? "",
                              qualifications: staff.staff?.qualification ?? "",
                              profileImageUrl: profileImageUrl,
                              backgroundColor: Colors.white,
                              borderColor: Colors.blueGrey.shade100,
                            );
                          },
                        );
                      },
                    ),
                    Consumer<ChatProvider>(
                      builder: (context, provider, _) {
                        return provider.isLoadingStaffs &&
                                provider.hasMoreStaffs
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
