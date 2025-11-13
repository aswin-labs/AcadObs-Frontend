import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/events/data/models/event_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel events;
  const EventDetailScreen({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        events.date != null
            ? DateFormat('dd MMM yyyy').format(events.date!)
            : 'N/A';

    final String formattedCreatedTime = DateFormat(
      'hh:mm a',
    ).format(events.createdAt!.toLocal());

    final bool isYesterday =
        events.createdAt != null &&
        DateTime.now().difference(events.createdAt!).inDays == 1 &&
        DateTime.now().day != events.createdAt!.day;

    return Scaffold(
      appBar: CommonAppBar(
        title: capitalizeEachWord(events.title.toString()),
        isBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Image Container with Gradient Overlay
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 280,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFDFCE)..withAlpha(102),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              BaseUrls.media +
                              MediaEndpoints.eventImages +
                              events.file.toString(),
                          placeholder:
                              (context, url) => Container(
                                color: const Color(0xFFFFDFCE),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFC56F41),
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFFDFCE),
                                      Color(0xFFFFCEB8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(77),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.event_outlined,
                                      size: 70,
                                      color: Color(0xFFC56F41),
                                    ),
                                  ),
                                ),
                              ),
                          fit: BoxFit.cover,
                        ),
                        // Subtle gradient overlay for better text readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(25),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Date Badge Overlay
                Positioned(
                  top: 32,
                  right: 32,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFFC56F41),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Color(0xFFC56F41),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Title with better styling
                  Text(
                    capitalizeEachWord(events.title.toString()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Decorative Divider
                  Container(
                    height: 3,
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC56F41), Colors.transparent],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description with enhanced styling
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Text(
                      capitalizeEachWord(
                        events.description ?? "No description available",
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Created Time Info Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDFCE).withAlpha(77),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFC56F41).withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDFCE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            size: 18,
                            color: Color(0xFFC56F41),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isYesterday ? 'Created Yesterday' : 'Created',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formattedCreatedTime,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFC56F41),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
