import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/events/presentation/widgets/event_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EventSection extends StatelessWidget {
  const EventSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final events = provider.eventsLatest;
        final isLoading = provider.isLatestLoading && events.isEmpty;

        if (!provider.isLatestLoading && events.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Row(
              children: [
                const Text(
                  "Events",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.pushNamed(RouteConstants.eventListscreen, extra: true);
                  },
                  child: const Text("View", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            if (isLoading)
              commonShimmerList(height: 100, itemCount: 3)
            else
              Column(
                children:
                    events.map((event) {
                      return EventCard(
                        event: event,
                        onViewTap: () {
                          context.pushNamed(
                            RouteConstants.eventlistdetails,
                            extra: event,
                          );
                        },
                        time: TimeFormatter.formatTime(
                          event.createdAt ?? DateTime.now(),
                        ),
                      );
                    }).toList(),
              ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
