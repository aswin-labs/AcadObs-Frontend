import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/events/data/models/event_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onViewTap;
  final String time;

  const EventCard({
    super.key,
    required this.event,
    required this.onViewTap,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        event.date != null
            ? DateFormat('dd MMM yyyy').format(event.date!)
            : 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onViewTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(38),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width < 400 ? 90 : 105,
                height: MediaQuery.of(context).size.width < 400 ? 90 : 105,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(25),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl:
                        BaseUrls.media +
                        MediaEndpoints.eventImages +
                        event.file.toString(),
                    placeholder:
                        (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Icon(
                          Icons.image_outlined,
                          color: Colors.grey.withAlpha(153),
                          size: 40,
                        ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        capitalizeEachWord(event.title ?? 'Not Available'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),

                      // Description
                      Text(
                        capitalizeEachWord(
                          event.description ?? "No description found",
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 6),

                      // Date pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFFE6F3FF),
                                border: Border.all(
                                  color: const Color(0xFF1E88E5).withAlpha(77),
                                ),
                              ),
                              child: Text(
                                formattedDate,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF1E88E5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          // const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              time,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
