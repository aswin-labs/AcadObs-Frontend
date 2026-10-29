import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/communication/data/models/communication_chat_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CommunicationThreadTile extends StatelessWidget {
  final CommunicationChatModel chat;
  final int? currentUserId;
  final VoidCallback onTap;

  const CommunicationThreadTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  String _resolveDpUrl(String? dp) {
    if (dp == null || dp.trim().isEmpty) return '';
    if (dp.startsWith('http')) return dp;
    return '${BaseUrls.media}${MediaEndpoints.dp}$dp';
  }

  String _formatChatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(local.year, local.month, local.day);
    final diffDays = today.difference(msgDay).inDays;

    if (diffDays == 0) {
      return DateFormat('hh:mm a').format(local);
    } else if (diffDays == 1) {
      return 'Yesterday';
    } else if (diffDays > 1 && diffDays < 7) {
      return DateFormat('EEE').format(local);
    } else if (local.year == now.year) {
      return DateFormat('dd MMM').format(local);
    }
    return DateFormat('dd MMM yyyy').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final opponent = chat.user;
    final name =
        (opponent?.name != null && opponent!.name!.trim().isNotEmpty)
            ? capitalizeEachWord(opponent.name!.trim())
            : 'User';
    final phone = opponent?.phone?.trim() ?? '';
    final dpUrl = _resolveDpUrl(opponent?.dp);
    final lastMsg = chat.message;
    final hasUnseen = chat.unseenCount > 0;

    // Determine whether the last message was sent by the opponent or by the current user
    final opponentId = opponent?.id;
    final lastSenderId = lastMsg?.senderId ?? lastMsg?.sender?.id;
    final isLastFromOpponent =
        lastSenderId != null &&
        ((opponentId != null && lastSenderId == opponentId) ||
            (currentUserId != null && lastSenderId != currentUserId));
    final isLastFromMe =
        lastSenderId != null &&
        ((currentUserId != null && lastSenderId == currentUserId) ||
            (opponentId != null && lastSenderId != opponentId));

    final timestamp = chat.updatedAt ?? lastMsg?.createdAt;
    final formattedTime = _formatChatTimestamp(timestamp);

    final rawMessageText = lastMsg?.message?.trim() ?? '';
    final previewText =
        rawMessageText.isNotEmpty
            ? (isLastFromMe ? 'You: $rawMessageText' : rawMessageText)
            : (lastMsg?.contextTitle != null
                ? 'Shared ${lastMsg!.contextTitle}'
                : 'Tap to view conversation');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: hasUnseen ? const Color(0xFFF8FCFF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    hasUnseen
                        ? const Color(0xFF00AEF0).withAlpha(110)
                        : const Color(0xFFE2E8F0),
                width: hasUnseen ? 1.4 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      hasUnseen
                          ? const Color(0xFF00AEF0).withAlpha(18)
                          : Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with optional unread indicator ring
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF35C2C1), Color(0xFF00AEF0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color:
                              hasUnseen
                                  ? const Color(0xFF00AEF0)
                                  : Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00AEF0).withAlpha(40),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            dpUrl.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: dpUrl,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (_, __) => Center(
                                        child: Text(
                                          name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (_, __, ___) => Center(
                                        child: Text(
                                          name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                          ),
                                        ),
                                      ),
                                )
                                : Center(
                                  child: Text(
                                    name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                    if (hasUnseen)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Name + Timestamp
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight:
                                    hasUnseen
                                        ? FontWeight.w800
                                        : FontWeight.w700,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          if (formattedTime.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight:
                                    hasUnseen
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                color:
                                    hasUnseen
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.phone,
                              size: 11,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 6),

                      // Bottom row: Status icon + Last message + Unseen count pill
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isLastFromMe && !isLastFromOpponent) ...[
                            Icon(
                              (lastMsg?.status ?? '').toLowerCase() == 'read'
                                  ? LucideIcons.checkCheck
                                  : (lastMsg?.status ?? '').toLowerCase() ==
                                      'received'
                                  ? LucideIcons.checkCheck
                                  : LucideIcons.check,
                              size: 15,
                              color:
                                  (lastMsg?.status ?? '').toLowerCase() ==
                                          'read'
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 5),
                          ],
                          if (lastMsg?.contextTitle != null) ...[
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                lastMsg!.contextTitle!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              previewText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.3,
                                fontWeight:
                                    hasUnseen
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                color:
                                    hasUnseen
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          if (hasUnseen) ...[
                            const SizedBox(width: 8),
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 22,
                                minHeight: 22,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00AEF0),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00AEF0,
                                    ).withAlpha(60),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                chat.unseenCount > 99
                                    ? '99+'
                                    : '${chat.unseenCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
