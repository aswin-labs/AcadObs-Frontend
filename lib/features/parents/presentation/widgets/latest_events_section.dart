import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/events/presentation/widgets/event_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LatestEventsSection extends StatelessWidget {
  const LatestEventsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                color: Color(0xFF00AEF0),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                "Latest Events",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Consumer<EventProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return commonShimmerList();
              }
    
              final events = provider.eventsLatest;
              if (events.isEmpty) {
                return emptyScreen(
                  message: "No Events Available",
                );
              }
    
              return ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: events.length,
                separatorBuilder:
                    (context, index) => SizedBox(height: 2),
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
              );
            },
          ),
        ],
      ),
    );
  }
}