import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/events/presentation/widgets/event_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EventListScreen extends StatefulWidget {
  final bool forStaff;
  const EventListScreen({super.key, this.forStaff = true});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<EventProvider>(
          context,
          listen: false,
        ).fetchLatestEvents(limit: 10, forStaff: widget.forStaff);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Events",
        isBackButton: widget.forStaff ? true : false,
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading && eventProvider.events.isEmpty) {
            return commonShimmerList();
          } else if (eventProvider.events.isEmpty) {
            return emptyScreen(message: "No Events Available");
          } else {
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels >=
                        scrollNotification.metrics.maxScrollExtent - 100 &&
                    !eventProvider.isLoading &&
                    eventProvider.hasMore) {
                  eventProvider.loadMore(forStaff: widget.forStaff);
                }
                return false;
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification &&
                      scrollNotification.metrics.pixels >=
                          scrollNotification.metrics.maxScrollExtent - 100 &&
                      !eventProvider.isLoading &&
                      eventProvider.hasMore) {
                    eventProvider.loadMore(forStaff: widget.forStaff);
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eventProvider.todayEvents.isNotEmpty) ...[
                          const Text("Today", style: TextStyle(fontSize: 15)),
                          const SizedBox(height: 10),
                          ...eventProvider.todayEvents.map(
                            (event) => EventCard(
                              time: TimeFormatter.formatTime(
                                event.createdAt ?? DateTime.now(),
                              ),
                              event: event,
                              onViewTap:
                                  () => context.pushNamed(
                                    RouteConstants.eventlistdetails,
                                    extra: event,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (eventProvider.yesterdayEvents.isNotEmpty) ...[
                          const Text(
                            "Yesterday",
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 10),
                          ...eventProvider.yesterdayEvents.map(
                            (event) => EventCard(
                              time: TimeFormatter.formatTime(
                                event.createdAt ?? DateTime.now(),
                              ),
                              event: event,
                              onViewTap:
                                  () => context.pushNamed(
                                    RouteConstants.eventlistdetails,
                                    extra: event,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (eventProvider.earlierEvents.isNotEmpty) ...[
                          const Text("Earlier", style: TextStyle(fontSize: 15)),
                          const SizedBox(height: 10),
                          ...eventProvider.earlierEvents.map(
                            (event) => EventCard(
                              time: TimeFormatter.formatTime(
                                event.createdAt ?? DateTime.now(),
                              ),
                              event: event,
                              onViewTap:
                                  () => context.pushNamed(
                                    RouteConstants.eventlistdetails,
                                    extra: event,
                                  ),
                            ),
                          ),
                        ],
                        if (eventProvider.hasMore) ...[
                          const SizedBox(height: 20),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
