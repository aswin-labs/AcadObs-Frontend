import 'dart:developer';

import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/homeworks/presentation/provider/homeworks_provider.dart';
import 'package:acadobs/features/homeworks/presentation/widgets/selectable_ranking_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddMissingHomeworkStudentRankingScreen extends StatefulWidget {
  final int homeworkId;
  const AddMissingHomeworkStudentRankingScreen({
    super.key,
    required this.homeworkId,
  });

  @override
  State<AddMissingHomeworkStudentRankingScreen> createState() =>
      _AddMissingHomeworkStudentRankingScreenState();
}

class _AddMissingHomeworkStudentRankingScreenState
    extends State<AddMissingHomeworkStudentRankingScreen> {
  final Set<int> _selectedStudentIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeworksProvider>().fetchMissingStudentsByHomeworkId(
        homeworkId: widget.homeworkId,
      );
    });
  }

  void _toggleSelectAll(List missingStudents) {
    setState(() {
      if (_selectedStudentIds.length == missingStudents.length) {
        _selectedStudentIds.clear();
      } else {
        _selectedStudentIds.clear();
        for (var student in missingStudents) {
          _selectedStudentIds.add(student.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> submitNewRankings() async {
      if (_selectedStudentIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one student')),
        );
        return;
      }

      final provider = context.read<HomeworksProvider>();
      final missingStudents = provider.missingStudents;

      final selectedStudents =
          missingStudents
              .where((student) => _selectedStudentIds.contains(student.id))
              .toList();

      final assignments =
          selectedStudents.map((student) {
            final studentId = student.id;
            return {
              "student_id": studentId,
              "points": provider.getPoint(studentId),
            };
          }).toList();

      log("Submitting selected assignments: $assignments");

      await provider.newStudentsHomeworkRanking(
        context: context,
        homeworkId: widget.homeworkId,
        assignments: assignments,
      );
    }

    return Scaffold(
      extendBody: true,
      appBar: const CommonAppBar(
        title: 'Add Missing Students',
        isBackButton: true,
      ),
      body: Consumer<HomeworksProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingMissingStudents) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.grey),
            );
          }

          final missingStudents = provider.missingStudents;

          if (missingStudents.isEmpty) {
            return emptyScreen(message: "No Missig Students Found");
          }

          final bool isAllSelected =
              _selectedStudentIds.isNotEmpty &&
              _selectedStudentIds.length == missingStudents.length;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 18,
                              color: Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedStudentIds.length}/${missingStudents.length} Selected',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _toggleSelectAll(missingStudents),
                        icon: Icon(
                          isAllSelected
                              ? Icons.deselect_outlined
                              : Icons.select_all,
                          color: const Color(0xFF6366F1),
                          size: 20,
                        ),
                        label: Text(
                          isAllSelected ? 'Deselect All' : 'Select All',
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 110,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final student = missingStudents[index];
                    final studentId = student.id;
                    final isSelected = _selectedStudentIds.contains(studentId);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SelectableRankingCard(
                        studentId: studentId,
                        name: student.fullName,
                        number: student.rollNumber?.toString() ?? '',
                        point: provider.getPoint(studentId),
                        homeworkId: widget.homeworkId,
                        isSelected: isSelected,
                        onSelectionChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedStudentIds.add(studentId);
                            } else {
                              _selectedStudentIds.remove(studentId);
                            }
                          });
                        },
                      ),
                    );
                  }, childCount: missingStudents.length),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer<HomeworksProvider>(
            builder: (context, provider, _) {
              if (provider.missingStudents.isEmpty ||
                  provider.isLoadingMissingStudents) {
                return const SizedBox.shrink();
              }
              return CommonButton(
                onPressed:
                    provider.isLoadingNewRanking ? null : submitNewRankings,
                widget:
                    provider.isLoadingNewRanking
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add Students',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
              );
            },
          ),
        ),
      ),
    );
  }
}
