import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';

import 'package:acadobs/features/teacher/presentation/notes/provider/parent_note_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_action_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NoteListingScreen extends StatefulWidget {
  const NoteListingScreen({super.key});

  @override
  State<NoteListingScreen> createState() => _NoteListingScreenState();
}

class _NoteListingScreenState extends State<NoteListingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ParentNoteProvider>(
          context,
          listen: false,
        ).fetchAllNotes(limit: AppConstants.paginationLimit, isRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'My Notes', isBackButton: true),
      body: Consumer<ParentNoteProvider>(
        builder: (context, noteProvider, _) {
          if (noteProvider.isLoading && noteProvider.note.isEmpty) {
            return commonShimmerList();
          } else if (noteProvider.error != null) {
            return Center(child: Text(noteProvider.error!));
          } else if (noteProvider.note.isEmpty) {
            return Center(child: emptyScreen(message: 'No Notes avaliable'));
          } else {
            final todayNote = noteProvider.todayNote;
            final yesterdayNote = noteProvider.yesterdayNote;
            final earlierNote = noteProvider.earlierNote;

            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels >=
                        scrollNotification.metrics.maxScrollExtent - 100 &&
                    !noteProvider.isLoading &&
                    noteProvider.hasMore) {
                  noteProvider.loadMore();
                }
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 60),
                physics: const BouncingScrollPhysics(),
                children: [
                  if (todayNote.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text("Today", style: TextStyle(fontSize: 15)),
                    ),
                    ...todayNote.map(
                      (note) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ItemCard(
                          title: note.noteTitle ?? "",
                          description: note.noteContent ?? '',
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.noteDetailScreen,
                              extra: note,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  if (yesterdayNote.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text("Yesterday", style: TextStyle(fontSize: 16)),
                    ),
                    ...yesterdayNote.map(
                      (note) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ItemCard(
                          title: note.noteTitle ?? "",
                          description: note.noteContent ?? "",
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.noteDetailScreen,
                              extra: note,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  if (earlierNote.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text("Earlier", style: TextStyle(fontSize: 16)),
                    ),
                    ...earlierNote.map(
                      (note) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ItemCard(
                          title: note.noteTitle ?? "",
                          description: note.noteContent ?? "",
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.noteDetailScreen,
                              extra: note,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  if (noteProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  SizedBox(height: 60),
                ],
              ),
            );
          }
        },
      ),

      floatingActionButton: CommonFloatingActionButton(
        onPressed: () {
          context.pushNamed(RouteConstants.addTeacherNoteSection);
        },
        text: "Add New Parent Note",
      ),
    );
  }
}
