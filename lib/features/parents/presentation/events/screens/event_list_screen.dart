import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
// import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/features/parents/presentation/events/widgets/event_card.dart';
import 'package:acadobs/features/parents/presentation/events/provider/event_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
// import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<EventProvider>(context, listen: false).fetchEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Events"),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading && eventProvider.events.isEmpty) {
            return commonShimmerList();
          } else if (eventProvider.error != null) {
            return Center(child: Text(eventProvider.error!));
          } else if (eventProvider.events.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, color: Colors.grey, size: 35),
                  SizedBox(height: 20),
                  Text(
                    "No events avaliable",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels >=
                        scrollNotification.metrics.maxScrollExtent - 100 &&
                    !eventProvider.isLoading &&
                    eventProvider.hasMore) {
                  eventProvider.loadMore();
                }
                return false;
              },
              child: ListView.builder(
                // itemCount: 5,
                physics: const BouncingScrollPhysics(),
                itemCount:
                    eventProvider.events.length +
                    (eventProvider.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == eventProvider.events.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),

                        // padding: EdgeInsets.zero,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final event = eventProvider.events[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
//time: TimeFormatter.formatTime(notice.createdAt),
                    child: EventCard(time: TimeFormatter.formatTime(event.createdAt??DateTime.now()),
                      event: event,
                      onViewTap:
                          () => context.pushNamed(
                            RouteConstants.eventlistdetails,
                            extra: event,
                          ),
                    ),
                  );
                 
                },
              ),
            );
          }
        },
      ),
    );
  }
}
