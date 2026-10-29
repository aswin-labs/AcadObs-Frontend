import 'dart:async';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/communication/presentation/provider/communication_provider.dart';
import 'package:acadobs/features/communication/presentation/screens/communication_detail_screen.dart';
import 'package:acadobs/features/communication/presentation/widgets/communication_thread_tile.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class CommunicationListingScreen extends StatefulWidget {
  final bool forStaff;

  const CommunicationListingScreen({super.key, required this.forStaff});

  @override
  State<CommunicationListingScreen> createState() =>
      _CommunicationListingScreenState();
}

class _CommunicationListingScreenState
    extends State<CommunicationListingScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late CommunicationProvider _provider;
  Timer? _debounceTimer;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _provider = context.read<CommunicationProvider>();
    _loadCurrentUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _provider.fetchMyChats(
          forStaff: widget.forStaff,
          forceRefresh: true,
          query: '',
        );
      }
    });

    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadCurrentUser() async {
    final uid = await AuthStorageService().getUserId();
    if (mounted) {
      setState(() {
        _currentUserId = uid;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_provider.isLoadingChats &&
        !_provider.isLoadingMoreChats &&
        _provider.hasMoreChats) {
      _provider.fetchMyChats(forStaff: widget.forStaff, loadMore: true);
    }
  }

  void _checkAndLoadMoreIfScrollable(CommunicationProvider provider) {
    if (!provider.hasMoreChats ||
        provider.isLoadingChats ||
        provider.isLoadingMoreChats ||
        provider.chats.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.maxScrollExtent <= 0) {
        provider.fetchMyChats(forStaff: widget.forStaff, loadMore: true);
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _provider.searchChats(forStaff: widget.forStaff, query: value.trim());
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CommonAppBar(
        title: "Communication",
        isBackButton: true,
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: () {
              _provider.fetchMyChats(
                forStaff: widget.forStaff,
                forceRefresh: true,
                query: _searchController.text.trim(),
              );
            },
            icon: const Icon(LucideIcons.refreshCw, size: 19),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText:
                      widget.forStaff
                          ? "Search parents by name or phone..."
                          : "Search teachers by name or phone...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: Color(0xFF64748B),
                    size: 19,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(
                              LucideIcons.x,
                              size: 17,
                              color: Color(0xFF64748B),
                            ),
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF00AEF0),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Threads List
          Expanded(
            child: Consumer<CommunicationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingChats && provider.chats.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00AEF0)),
                  );
                }

                if (provider.chats.isEmpty) {
                  return RefreshIndicator(
                    onRefresh:
                        () => provider.fetchMyChats(
                          forStaff: widget.forStaff,
                          forceRefresh: true,
                          query: _searchController.text.trim(),
                        ),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: Responsive.height * 16),
                        emptyScreen(
                          message:
                              widget.forStaff
                                  ? "No parent communications yet.\nYou can message a parent from any Student Profile."
                                  : "No teacher communications yet.\nTap below or open Teachers to send a message.",
                        ),
                        if (!widget.forStaff) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.pushNamed(
                                    RouteConstants.teachersListingScreen,
                                  );
                                },
                                icon: const Icon(LucideIcons.users, size: 17),
                                label: const Text("Browse Teachers"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00AEF0),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                _checkAndLoadMoreIfScrollable(provider);

                return RefreshIndicator(
                  onRefresh:
                      () => provider.fetchMyChats(
                        forStaff: widget.forStaff,
                        forceRefresh: true,
                        query: _searchController.text.trim(),
                      ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 4, bottom: 90),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount:
                        provider.chats.length +
                        (provider.isLoadingMoreChats ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.chats.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00AEF0),
                            ),
                          ),
                        );
                      }

                      final chat = provider.chats[index];
                      return CommunicationThreadTile(
                        chat: chat,
                        currentUserId: _currentUserId,
                        onTap: () async {
                          await context.pushNamed(
                            RouteConstants.communicationDetailScreen,
                            extra: CommunicationDetailScreenArgs(
                              forStaff: widget.forStaff,
                              chatId: chat.id,
                              receiverId: chat.user?.id,
                              opponentName: chat.user?.name,
                              opponentPhone: chat.user?.phone,
                              opponentDp: chat.user?.dp,
                            ),
                          );
                          if (mounted) {
                            _provider.fetchMyChats(
                              forStaff: widget.forStaff,
                              forceRefresh: true,
                              silent: true,
                              query: _searchController.text.trim(),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          !widget.forStaff
              ? FloatingActionButton.extended(
                onPressed: () {
                  context.pushNamed(RouteConstants.teachersListingScreen);
                },
                backgroundColor: const Color(0xFF00AEF0),
                foregroundColor: Colors.white,
                icon: const Icon(LucideIcons.messageSquarePlus, size: 19),
                label: const Text(
                  "New Message",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
              : null,
    );
  }
}
