import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/features/communication/data/models/communication_message_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CommunicationMessageCard extends StatelessWidget {
  final CommunicationMessageModel message;
  final bool isMe;
  final CommunicationMessageModel? repliedMessage;
  final VoidCallback? onReplyTap;

  const CommunicationMessageCard({
    super.key,
    required this.message,
    required this.isMe,
    this.repliedMessage,
    this.onReplyTap,
  });

  String _formatMessageTime(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('hh:mm a').format(dt.toLocal());
  }

  Widget _buildStatusBadge(String? status) {
    final normalized = (status ?? 'sent').toLowerCase();
    final isRead = normalized == 'read';
    final isReceived = normalized == 'received';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isRead || isReceived ? LucideIcons.checkCheck : LucideIcons.check,
          size: 13.5,
          color: isRead ? const Color(0xFF0284C7) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 3),
        Text(
          isRead
              ? 'Read'
              : isReceived
              ? 'Delivered'
              : 'Sent',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: isRead ? const Color(0xFF0284C7) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final senderName =
        isMe
            ? 'You'
            : capitalizeEachWord(message.sender?.name?.trim() ?? 'Sender');
    final formattedTime = _formatMessageTime(message.createdAt);
    final contextTitle = message.contextTitle;
    final contextSubtitle = message.contextSubtitle;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
          minWidth: 130,
        ),
        child: Container(
          margin: EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: isMe ? 48 : 14,
            right: isMe ? 14 : 48,
          ),
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 9),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFFE0F2FE) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            border: Border.all(
              color:
                  isMe ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Sender Name & Reply button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      senderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            isMe
                                ? const Color(0xFF0369A1)
                                : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (onReplyTap != null)
                    InkWell(
                      onTap: onReplyTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.reply,
                              size: 12.5,
                              color:
                                  isMe
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Reply',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color:
                                    isMe
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Replied message quote if present
              if (repliedMessage != null) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(200),
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF00AEF0), width: 3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizeEachWord(
                          repliedMessage!.sender?.name ?? 'Previous Message',
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        repliedMessage!.message ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Attached Module Reference (Homework, ParentNote, Invoice, etc.)
              if (contextTitle != null) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(210),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.paperclip,
                        size: 13.5,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ref: $contextTitle",
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (contextSubtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                contextSubtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 6),

              // Message Body
              Text(
                message.message ?? '',
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 5),

              // Footer: Timestamp + Status for sender
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (formattedTime.isNotEmpty)
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (isMe) ...[
                    const SizedBox(width: 8),
                    _buildStatusBadge(message.status),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
