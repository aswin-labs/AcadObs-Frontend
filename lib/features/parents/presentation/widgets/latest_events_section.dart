import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/events/presentation/widgets/event_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LatestEventsSection extends StatelessWidget {
  const LatestEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final events = provider.eventsLatest;
        final isLoading = provider.isLatestLoading && events.isEmpty;

        if (!provider.isLatestLoading && events.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Latest Events",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(
                        RouteConstants.eventListscreen,
                        extra: false,
                      );
                    },
                    child: const Text("View", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (isLoading)
                commonShimmerList(height: 100, itemCount: 3)
              else
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventCard(
                      event: event,
                      onViewTap:
                          () => context.pushNamed(
                            RouteConstants.eventlistdetails,
                            extra: event,
                          ),
                      time: TimeFormatter.formatTime(
                        event.createdAt ?? DateTime.now(),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
