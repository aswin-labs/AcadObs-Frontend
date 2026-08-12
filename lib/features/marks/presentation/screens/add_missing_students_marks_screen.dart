import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/marks/presentation/widgets/grade_card.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddMissingStudentMarksScreen extends StatefulWidget {
  final MissingStudentMarksParams params;

  const AddMissingStudentMarksScreen({super.key, required this.params});

  @override
  State<AddMissingStudentMarksScreen> createState() =>
      _AddMissingStudentMarksScreenState();
}

class _AddMissingStudentMarksScreenState
    extends State<AddMissingStudentMarksScreen> {
  late final MarksProvider _marksProvider;

  final Map<int, TextEditingController> _marksControllers = {};
  final Map<int, String> _statusMap = {};

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();

    _marksProvider = context.read<MarksProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMissingStudents();
    });
  }

  Future<void> _loadMissingStudents() async {
    await _marksProvider.fetchMissingStudents(
      classId: widget.params.classId,
      studentIds: widget.params.studentIds,
    );

    if (!mounted) return;

    _initializeControllers();
  }

  void _initializeControllers() {
    if (_controllersInitialized) return;

    for (final student in _marksProvider.missingStudents) {
      _marksControllers[student.id] = TextEditingController();

      _statusMap[student.id] = 'present';
    }

    _controllersInitialized = true;

    setState(() {});
  }

  List<Map<String, dynamic>> _getStudentMarks() {
    return _marksProvider.missingStudents.map((student) {
      final controller = _marksControllers[student.id];

      final text = controller?.text.trim() ?? '';

      final status = _statusMap[student.id] ?? 'present';

      final marks = status == 'absent' ? 0.0 : double.tryParse(text) ?? 0.0;

      return {
        "student_id": student.id,
        "marks_obtained": marks,
        "status": status,
      };
    }).toList();
  }

  Future<void> _submitMarks() async {
    final students = _marksProvider.missingStudents;

    for (final student in students) {
      final status = _statusMap[student.id] ?? 'present';

      final text = _marksControllers[student.id]?.text.trim() ?? '';

      if (status == 'present' && text.isEmpty) {
        CustomSnackbar.show(
          context,
          message: 'Enter marks for ${student.fullName}',
          type: SnackbarType.failure,
        );

        return;
      }

      final enteredMarks = double.tryParse(text);

      if (status == 'present' &&
          enteredMarks != null &&
          enteredMarks > widget.params.totalMarks) {
        CustomSnackbar.show(
          context,
          message: 'Marks cannot exceed ${widget.params.totalMarks}',
          type: SnackbarType.failure,
        );

        return;
      }
    }

    final success = await _marksProvider.createNewMarksByInternalId(
      context: context,
      internalId: widget.params.internalId,
      studentMarks: _getStudentMarks(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    for (final controller in _marksControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Add New Student Marks', isBackButton: true),
      body: Consumer<MarksProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingMissingStudents) {
            return Padding(
              padding: context.paddingHorizontal,
              child: commonShimmerList(),
            );
          }

          if (provider.missingStudents.isEmpty) {
            return emptyScreen(message: 'No new students found.');
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${provider.missingStudents.length} Students',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Total Marks: ${widget.params.totalMarks}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                  itemCount: provider.missingStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final student = provider.missingStudents[index];

                    final controller = _marksControllers[student.id];

                    if (controller == null) {
                      return const SizedBox.shrink();
                    }

                    return GradeCard(
                      key: ValueKey(student.id),
                      totalMarks: widget.params.totalMarks.toInt(),
                      studentId: student.id,
                      marksController: controller,
                      name: student.fullName,
                      rollNumber: student.rollNumber ?? 0,
                      status: _statusMap[student.id] ?? 'present',
                      onStatusChanged: (newStatus) {
                        setState(() {
                          _statusMap[student.id] = newStatus;

                          if (newStatus == 'absent') {
                            controller.clear();
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Consumer<MarksProvider>(
          builder: (context, provider, _) {
            return CommonButton(
              onPressed:
                  provider.isAddingMissingStudentMarks ? null : _submitMarks,
              widget:
                  provider.isAddingMissingStudentMarks
                      ? CircularProgressIndicator(color: Colors.grey)
                      : const Text('Submit Marks'),
            );
          },
        ),
      ),
    );
  }
}
