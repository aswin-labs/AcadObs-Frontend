import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
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
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Events",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                context.pushNamed(RouteConstants.eventListscreen, extra: true);
              },
              child: Text("View", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),

        //listing latest events
        Consumer<EventProvider>(
          builder: (context, provider, _) {
            final events = provider.eventsLatest;
            if (provider.isLoading) {
              return Center(child: CommonShimmerTile());
            } else if (events.isEmpty) {
              return emptyScreen(
                message: "No Events Avaliable",
                heightMultiplier: 5,
              );
            }

            return Column(
              children:
                  events.map((events) {
                    return EventCard(
                      event: events,

                      onViewTap: () {
                        context.pushNamed(
                          RouteConstants.eventlistdetails,
                          extra: events,
                        );
                      },
                      time: TimeFormatter.formatTime(
                        events.createdAt ?? DateTime.now(),
                      ),
                    );
                  }).toList(),
            );
          },
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
