import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/parent_notes/data/models/parent_note_model.dart';
import 'package:acadobs/features/parent_notes/presentation/provider/parent_notes_provider.dart';
import 'package:acadobs/features/parent_notes/presentation/widgets/create_parent_note_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class ParentNotesListingScreen extends StatefulWidget {
  const ParentNotesListingScreen({super.key});

  @override
  State<ParentNotesListingScreen> createState() =>
      _ParentNotesListingScreenState();
}

class _ParentNotesListingScreenState extends State<ParentNotesListingScreen> {
  final ScrollController _scrollController = ScrollController();
  late ParentNotesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ParentNotesProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _provider.fetchParentNotes(forceRefresh: true);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_provider.isLoadingNotes &&
          _provider.hasMore) {
        _provider.fetchParentNotes(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildNoteCard(ParentNoteModel note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ItemCard(
        title: note.noteTitle ?? "Parent Note",
        description: note.noteContent ?? "",
        icon: LucideIcons.fileText,
        backgroundColor: const Color(0xFFCEFFD3),
        iconColor: const Color(0xFF2EAF3B),
        date:
            note.createdAt != null
                ? DateFormatter.formatDateTime(note.createdAt!)
                : "",
        onTap: () {
          context.pushNamed(
            RouteConstants.parentNoteDetailsScreen,
            extra: note,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Parent Notes", isBackButton: true),
      body: Consumer<ParentNotesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingNotes && provider.notes.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: commonShimmerList(),
            );
          }

          if (provider.notes.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchParentNotes(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: Responsive.height * 20),
                  emptyScreen(message: "No Parent Notes Available"),
                ],
              ),
            );
          }

          final todayNotes = provider.todayNotes;
          final yesterdayNotes = provider.yesterdayNotes;
          final earlierNotes = provider.earlierNotes;

          final hasGrouped =
              todayNotes.isNotEmpty ||
              yesterdayNotes.isNotEmpty ||
              earlierNotes.isNotEmpty;

          return RefreshIndicator(
            onRefresh: () => provider.fetchParentNotes(forceRefresh: true),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 80, top: 12),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                if (hasGrouped) ...[
                  if (todayNotes.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "Today",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...todayNotes.map(_buildNoteCard),
                  ],
                  if (yesterdayNotes.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "Yesterday",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...yesterdayNotes.map(_buildNoteCard),
                  ],
                  if (earlierNotes.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "Earlier",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...earlierNotes.map(_buildNoteCard),
                  ],
                ] else ...[
                  ...provider.notes.map(_buildNoteCard),
                ],
                if (provider.isLoadingNotes)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: CommonFloatingButton(
          onPressed: () => showCreateParentNoteBottomSheet(context: context),
        ),
      ),
    );
  }
}
