import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/events/presentation/widgets/event_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EventListingScreen extends StatefulWidget {
  final bool forStaff;
  const EventListingScreen({super.key, required this.forStaff});

  @override
  State<EventListingScreen> createState() => _EventListingScreenState();
}

class _EventListingScreenState extends State<EventListingScreen> {
  late final EventProvider _provider;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _provider = context.read<EventProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchEvents(forStaff: widget.forStaff);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_provider.isLoading &&
          _provider.hasMore) {
        _provider.fetchEvents(loadMore: true, forStaff: widget.forStaff);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Events', isBackButton: widget.forStaff),
      body: RefreshIndicator(
        onRefresh: () => _provider.fetchEvents(forStaff: widget.forStaff),
        child: Consumer<EventProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.eventsAll.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: commonShimmerList(),
              );
            }

            if (provider.eventsAll.isEmpty) {
              return emptyScreen(message: 'No Events Found.');
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: provider.eventsAll.length + (provider.hasMore ? 2 : 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(height: Responsive.height * 3);
                }

                if (index == provider.eventsAll.length + 1) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final event = provider.eventsAll[index - 1];

                return EventCard(
                  time: TimeFormatter.formatTime(
                    event.createdAt ?? DateTime.now(),
                  ),
                  event: event,
                  onViewTap:
                      () => context.pushNamed(
                        RouteConstants.eventlistdetails,
                        extra: event,
                      ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
