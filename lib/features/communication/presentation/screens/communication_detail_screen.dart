import 'dart:async';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/communication/data/models/communication_chat_model.dart';
import 'package:acadobs/features/communication/data/models/communication_message_model.dart';
import 'package:acadobs/features/communication/presentation/provider/communication_provider.dart';
import 'package:acadobs/features/communication/presentation/widgets/communication_message_card.dart';
import 'package:acadobs/features/parents/presentation/provider/parent_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class CommunicationDetailScreenArgs {
  final bool forStaff;
  final int? chatId;
  final int? receiverId;
  final String? opponentName;
  final String? opponentPhone;
  final String? opponentDp;
  final int? studentId;
  final String? studentName;
  final String? type;
  final int? typeId;
  final String? contextTitle;

  const CommunicationDetailScreenArgs({
    required this.forStaff,
    this.chatId,
    this.receiverId,
    this.opponentName,
    this.opponentPhone,
    this.opponentDp,
    this.studentId,
    this.studentName,
    this.type,
    this.typeId,
    this.contextTitle,
  });
}

class CommunicationDetailScreen extends StatefulWidget {
  final CommunicationDetailScreenArgs args;

  const CommunicationDetailScreen({
    super.key,
    required this.args,
  });

  @override
  State<CommunicationDetailScreen> createState() =>
      _CommunicationDetailScreenState();
}

class _CommunicationDetailScreenState extends State<CommunicationDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late CommunicationProvider _provider;
  Timer? _searchDebounce;

  int? _currentUserId;
  int? _resolvedChatId;
  int? _selectedStudentId;
  CommunicationMessageModel? _replyingTo;
  bool _isResolvingInitialThread = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _provider = context.read<CommunicationProvider>();
    _resolvedChatId = widget.args.chatId;
    _selectedStudentId = widget.args.studentId;

    _loadCurrentUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initThread();
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

  Future<void> _initThread() async {
    // Default studentId for parent if they have 1 child
    if (!widget.args.forStaff && _selectedStudentId == null) {
      final parentProvider = context.read<ParentProvider>();
      if (parentProvider.students.length == 1) {
        _selectedStudentId = parentProvider.students.first.id;
      }
    }

    _provider.prepareConversation(
      chatId: _resolvedChatId,
      opponent: CommunicationUserModel(
        id: widget.args.receiverId,
        name: widget.args.opponentName,
        phone: widget.args.opponentPhone,
        dp: widget.args.opponentDp,
      ),
    );

    if (_resolvedChatId != null) {
      await _provider.fetchMessagesByChatId(
        forStaff: widget.args.forStaff,
        chatId: _resolvedChatId!,
        forceRefresh: true,
        query: '',
      );
      return;
    }

    if (widget.args.receiverId != null) {
      setState(() {
        _isResolvingInitialThread = true;
      });
      final existingChatId = await _provider.resolveExistingChatId(
        forStaff: widget.args.forStaff,
        receiverId: widget.args.receiverId!,
      );
      if (!mounted) return;
      setState(() {
        _isResolvingInitialThread = false;
        _resolvedChatId = existingChatId;
      });

      if (existingChatId != null) {
        await _provider.fetchMessagesByChatId(
          forStaff: widget.args.forStaff,
          chatId: existingChatId,
          forceRefresh: true,
          query: '',
        );
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _resolvedChatId == null) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_provider.isLoadingMessages &&
        !_provider.isLoadingMoreMessages &&
        _provider.hasMoreMessages) {
      _provider.fetchMessagesByChatId(
        forStaff: widget.args.forStaff,
        chatId: _resolvedChatId!,
        loadMore: true,
      );
    }
  }

  void _checkAndLoadMoreIfScrollable(CommunicationProvider provider) {
    if (_resolvedChatId == null ||
        !provider.hasMoreMessages ||
        provider.isLoadingMessages ||
        provider.isLoadingMoreMessages ||
        provider.messages.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.maxScrollExtent <= 0) {
        provider.fetchMessagesByChatId(
          forStaff: widget.args.forStaff,
          chatId: _resolvedChatId!,
          loadMore: true,
        );
      }
    });
  }

  void _onSearchQueryChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted && _resolvedChatId != null) {
        _provider.fetchMessagesByChatId(
          forStaff: widget.args.forStaff,
          chatId: _resolvedChatId!,
          forceRefresh: true,
          query: value.trim(),
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _provider.isSendingMessage) return;

    final receiverId =
        _provider.activeOpponent?.id ?? widget.args.receiverId;
    if (receiverId == null) return;

    FocusScope.of(context).unfocus();

    final replyId = _replyingTo?.id;
    final newChatId = await _provider.sendMessage(
      context: context,
      forStaff: widget.args.forStaff,
      receiverId: receiverId,
      message: text,
      chatId: _resolvedChatId,
      studentId: _selectedStudentId,
      replyToId: replyId,
      type: widget.args.type,
      typeId: widget.args.typeId,
    );

    if (!mounted) return;
    if (newChatId != null) {
      _messageController.clear();
      setState(() {
        _resolvedChatId = newChatId;
        _replyingTo = null;
      });
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  String _resolveDpUrl(String? dp) {
    if (dp == null || dp.trim().isEmpty) return '';
    if (dp.startsWith('http')) return dp;
    return '${BaseUrls.media}${MediaEndpoints.dp}$dp';
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  String _formatDateHeader(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(local.year, local.month, local.day);
    final diffDays = today.difference(msgDay).inDays;

    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Yesterday';
    if (local.year == now.year) {
      return DateFormat('EEEE, dd MMM').format(local);
    }
    return DateFormat('dd MMM yyyy').format(local);
  }

  Widget _buildDateDivider(String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0).withAlpha(190),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildParentStudentSelector() {
    if (widget.args.forStaff) return const SizedBox.shrink();

    return Consumer<ParentProvider>(
      builder: (context, parentProvider, _) {
        final students = parentProvider.students;
        if (students.length <= 1) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.graduationCap,
                size: 15,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              const Text(
                "Child:",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        students.map((s) {
                          final isSelected = _selectedStudentId == s.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                capitalizeEachWord(s.fullName),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : const Color(0xFF334155),
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFF00AEF0),
                              backgroundColor: Colors.white,
                              showCheckmark: false,
                              visualDensity: VisualDensity.compact,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedStudentId = selected ? s.id : null;
                                });
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunicationProvider>(
      builder: (context, provider, _) {
        final opponent = provider.activeOpponent;
        final displayName = capitalizeEachWord(
          opponent?.name?.trim().isNotEmpty == true
              ? opponent!.name!.trim()
              : (widget.args.opponentName ?? 'Conversation'),
        );
        final displayPhone =
            opponent?.phone?.trim().isNotEmpty == true
                ? opponent!.phone!.trim()
                : (widget.args.opponentPhone ?? '');
        final dpUrl = _resolveDpUrl(opponent?.dp ?? widget.args.opponentDp);

        final messages = provider.messages;
        final isInitialLoading =
            _isResolvingInitialThread ||
            (provider.isLoadingMessages && messages.isEmpty);

        // Map messages by ID for fast reply lookup
        final messageMap = <int, CommunicationMessageModel>{
          for (final m in messages)
            if (m.id != null) m.id!: m,
        };

        if (!isInitialLoading && messages.isNotEmpty) {
          _checkAndLoadMoreIfScrollable(provider);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            surfaceTintColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                LucideIcons.arrowLeft,
                color: Color(0xFF0F172A),
                size: 20,
              ),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF35C2C1), Color(0xFF00AEF0)],
                    ),
                  ),
                  child: ClipOval(
                    child:
                        dpUrl.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: dpUrl,
                              fit: BoxFit.cover,
                              errorWidget:
                                  (_, __, ___) => Center(
                                    child: Text(
                                      displayName.isNotEmpty
                                          ? displayName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            )
                            : Center(
                              child: Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (widget.args.studentName != null &&
                          widget.args.studentName!.trim().isNotEmpty)
                        Text(
                          "Student: ${capitalizeEachWord(widget.args.studentName!)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF0284C7),
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else if (displayPhone.isNotEmpty)
                        Text(
                          displayPhone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (_resolvedChatId != null) ...[
                IconButton(
                  tooltip: _isSearching ? "Close Search" : "Search Messages",
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching && _searchController.text.isNotEmpty) {
                        _searchController.clear();
                        _provider.fetchMessagesByChatId(
                          forStaff: widget.args.forStaff,
                          chatId: _resolvedChatId!,
                          forceRefresh: true,
                          query: '',
                        );
                      }
                    });
                  },
                  icon: Icon(
                    _isSearching ? LucideIcons.x : LucideIcons.search,
                    size: 18,
                    color: const Color(0xFF475569),
                  ),
                ),
                IconButton(
                  tooltip: "Refresh Messages",
                  onPressed:
                      provider.isLoadingMessages
                          ? null
                          : () {
                            provider.fetchMessagesByChatId(
                              forStaff: widget.args.forStaff,
                              chatId: _resolvedChatId!,
                              forceRefresh: true,
                              query: _searchController.text.trim(),
                            );
                          },
                  icon: const Icon(
                    LucideIcons.refreshCw,
                    size: 18,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ],
          ),
          body: Column(
            children: [
              // Collapsible In-Thread Search Bar
              if (_isSearching && _resolvedChatId != null)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _onSearchQueryChanged,
                    decoration: InputDecoration(
                      hintText: "Search messages in this conversation...",
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        LucideIcons.search,
                        size: 17,
                        color: Color(0xFF64748B),
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchQueryChanged('');
                                },
                                icon: const Icon(
                                  LucideIcons.x,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                              )
                              : null,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF00AEF0),
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),

              // Messages Area
              Expanded(
                child:
                    isInitialLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00AEF0),
                          ),
                        )
                        : messages.isEmpty
                        ? Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE0F2FE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _searchController.text.trim().isNotEmpty
                                        ? LucideIcons.searchX
                                        : LucideIcons.messagesSquare,
                                    size: 32,
                                    color: const Color(0xFF0284C7),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.trim().isNotEmpty
                                      ? "No matching messages found"
                                      : "Communicate with $displayName",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _searchController.text.trim().isNotEmpty
                                      ? "Try searching with a different keyword."
                                      : "Send a message below to start the communication thread. Pull down or tap refresh anytime to check for replies.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: () async {
                            if (_resolvedChatId != null) {
                              await provider.fetchMessagesByChatId(
                                forStaff: widget.args.forStaff,
                                chatId: _resolvedChatId!,
                                forceRefresh: true,
                                query: _searchController.text.trim(),
                              );
                            }
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount:
                                messages.length +
                                (provider.isLoadingMoreMessages ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= messages.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF00AEF0),
                                    ),
                                  ),
                                );
                              }

                              final msg = messages[index];
                              final opponentId =
                                  opponent?.id ?? widget.args.receiverId;
                              final senderId = msg.senderId ?? msg.sender?.id;

                              final bool isMe;
                              if (opponentId != null && senderId != null) {
                                isMe = senderId != opponentId;
                              } else if (_currentUserId != null &&
                                  senderId != null) {
                                isMe = senderId == _currentUserId;
                              } else {
                                isMe = false;
                              }

                              final repliedMsg =
                                  msg.replyToId != null
                                      ? messageMap[msg.replyToId!]
                                      : null;

                              // Show date header above the oldest message of each day
                              // Since `reverse: true`, `index + 1` is the older message above this one
                              final bool showDateHeader =
                                  index == messages.length - 1 ||
                                  !_isSameDay(
                                    msg.createdAt,
                                    messages[index + 1].createdAt,
                                  );

                              final card = CommunicationMessageCard(
                                message: msg,
                                isMe: isMe,
                                repliedMessage: repliedMsg,
                                onReplyTap: () {
                                  setState(() {
                                    _replyingTo = msg;
                                  });
                                },
                              );

                              if (!showDateHeader) return card;

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildDateDivider(
                                    _formatDateHeader(msg.createdAt),
                                  ),
                                  card,
                                ],
                              );
                            },
                          ),
                        ),
              ),

              // Optional Reply Banner
              if (_replyingTo != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F9FF),
                    border: Border(top: BorderSide(color: Color(0xFFBAE6FD))),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.reply,
                        size: 16,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Replying to ${capitalizeEachWord(_replyingTo!.sender?.name ?? 'Message')}",
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                            Text(
                              _replyingTo!.message ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() {
                            _replyingTo = null;
                          });
                        },
                        icon: const Icon(
                          LucideIcons.x,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

              // Student selector for parents with multiple children
              _buildParentStudentSelector(),

              // Clean Single-Layer Composer Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    top: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            maxLines: 4,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: "Write your message...",
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00AEF0),
                                  width: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 44,
                          width: 44,
                          child: ElevatedButton(
                            onPressed:
                                provider.isSendingMessage ? null : _handleSend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00AEF0),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                              elevation: 0,
                            ),
                            child:
                                provider.isSendingMessage
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Icon(LucideIcons.send, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
