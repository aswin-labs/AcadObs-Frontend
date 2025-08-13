// import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/events/data/models/event_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatelessWidget {
  final Events events;
  const EventDetailScreen({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        events.date != null
            ? DateFormat('dd - MM - yy').format(events.date!)
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 226,
              decoration: BoxDecoration(
                color: Color(0xFFFFDFCE),
                borderRadius: BorderRadius.circular(16),
              ),

              //need to place the image
              child: Container(
                width: double.infinity,
                height: 226,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDFCE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl:
                        BaseUrls.media +
                        MediaEndpoints.eventImages +
                        events.file.toString(),
                    placeholder:
                        (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (context, url, error) => const Center(
                          child: Icon(
                            Icons.event,
                            size: 85,
                            color: Colors.black,
                          ),
                        ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                capitalizeEachWord(events.title.toString()),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                capitalizeEachWord(
                  events.description ?? "No description found",
                ),
                style: TextStyle(color: const Color(0xFF949494)),
              ),
            ),
            SizedBox(height: 10),

            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFDFCE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          color: Color(0xFFC56F41),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),

                Text(
                  isYesterday
                      ? 'Created: Yesterday at $formattedCreatedTime'
                      : formattedCreatedTime,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
