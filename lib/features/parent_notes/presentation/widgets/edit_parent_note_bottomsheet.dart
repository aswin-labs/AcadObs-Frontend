import 'dart:developer';

import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/parent_notes/data/models/parent_note_model.dart';
import 'package:acadobs/features/parent_notes/data/services/parent_note_services.dart';
import 'package:acadobs/features/parent_notes/presentation/provider/parent_notes_provider.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/students/data/services/student_services.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

void showEditParentNoteBottomSheet({
  required BuildContext context,
  required ParentNoteModel note,
}) {
  context.read<FilePickerProvider>().clearFile('parentNoteFile');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => _EditParentNoteBottomSheetContent(note: note),
  );
}

class _EditParentNoteBottomSheetContent extends StatefulWidget {
  final ParentNoteModel note;
  const _EditParentNoteBottomSheetContent({required this.note});

  @override
  State<_EditParentNoteBottomSheetContent> createState() =>
      _EditParentNoteBottomSheetContentState();
}

class _EditParentNoteBottomSheetContentState
    extends State<_EditParentNoteBottomSheetContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _searchRemainingController;

  final Set<int> _selectedStudentIds = {};
  final Map<int, StudentModel> _studentMap = {};
  List<StudentModel> _allClassStudents = [];
  bool _isLoadingStudents = false;
  String _searchRemainingQuery = '';
  int? _classId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.noteTitle ?? "");
    _contentController = TextEditingController(
      text: widget.note.noteContent ?? "",
    );
    _searchRemainingController = TextEditingController();

    _initializeStudents();
  }

  void _initializeStudents() {
    // 1. Populate already added students from widget.note.parentNoteStudents
    final noteStudents = widget.note.parentNoteStudents ?? [];
    for (final pns in noteStudents) {
      if (pns.studentId != null) {
        _selectedStudentIds.add(pns.studentId!);
        _studentMap[pns.studentId!] = StudentModel(
          id: pns.studentId!,
          fullName: pns.student?.fullName ?? "Student #${pns.studentId}",
          regNo: pns.student?.regNo,
          classId: pns.student?.classId,
        );
      }
      if (_classId == null &&
          pns.student?.classId != null &&
          pns.student!.classId! > 0) {
        _classId = pns.student!.classId;
      }
    }

    // 2. Fetch all class students if classId is known or fetch details first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadClassStudents();
      }
    });
  }

  Future<void> _loadClassStudents() async {
    setState(() {
      _isLoadingStudents = true;
    });

    try {
      // If classId wasn't found in widget.note, fetch single note to get ParentNoteStudents with class_id
      if (_classId == null && widget.note.id != null) {
        final noteRes = await ParentNoteServices().fetchSingleParentNote(
          noteId: widget.note.id!,
        );
        if (noteRes.statusCode == 200 && noteRes.data != null) {
          final dynamic raw = noteRes.data;
          final data =
              raw is Map<String, dynamic>
                  ? (raw['note'] ?? raw['data'] ?? raw)
                  : raw;
          if (data is Map<String, dynamic>) {
            final fetchedNote = ParentNoteModel.fromJson(data);
            for (final pns in fetchedNote.parentNoteStudents ?? []) {
              if (pns.studentId != null) {
                _selectedStudentIds.add(pns.studentId!);
                _studentMap[pns.studentId!] = StudentModel(
                  id: pns.studentId!,
                  fullName:
                      pns.student?.fullName ?? "Student #${pns.studentId}",
                  regNo: pns.student?.regNo,
                  classId: pns.student?.classId,
                );
              }
              if (_classId == null &&
                  pns.student?.classId != null &&
                  pns.student!.classId! > 0) {
                _classId = pns.student!.classId;
              }
            }
          }
        }
      }

      // If classId is available, fetch all students for this class
      if (_classId != null) {
        final response = await StudentServices().fetchStudentsByClassId(
          classId: _classId!,
        );
        if (response.statusCode == 200 && response.data != null) {
          final List studentsJson = response.data['students'] ?? [];
          final List<StudentModel> fetchedList =
              studentsJson.map((j) => StudentModel.fromJson(j)).toList();

          for (final s in fetchedList) {
            _studentMap[s.id] = s;
          }

          if (mounted) {
            setState(() {
              _allClassStudents = fetchedList;
            });
          }
        }
      }
    } catch (e) {
      log("Error loading class students in edit bottomsheet: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
        });
      }
    }
  }

  void _removeStudent(int studentId) {
    setState(() {
      _selectedStudentIds.remove(studentId);
    });
  }

  void _addStudent(int studentId) {
    setState(() {
      _selectedStudentIds.add(studentId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchRemainingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List of currently added students
    final addedStudents =
        _selectedStudentIds
            .map(
              (id) =>
                  _studentMap[id] ??
                  StudentModel(id: id, fullName: "Student #$id"),
            )
            .toList();

    // List of remaining students in the class
    final remainingStudents =
        _allClassStudents.where((s) {
          final notSelected = !_selectedStudentIds.contains(s.id);
          if (!notSelected) return false;
          if (_searchRemainingQuery.isEmpty) return true;
          final q = _searchRemainingQuery.toLowerCase();
          final nameMatches = s.fullName.toLowerCase().contains(q);
          final rollMatches = s.rollNumber?.toString().contains(q) ?? false;
          final regMatches = s.regNo?.toLowerCase().contains(q) ?? false;
          return nameMatches || rollMatches || regMatches;
        }).toList();

    final mediaQuery = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.90),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: mediaQuery.viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Parent Note",
                      style: context.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.height * 2),

                // Note Title
                CustomTextfield(
                  iconData: const Icon(LucideIcons.fileText),
                  controller: _titleController,
                  hintText: 'Note Title*',
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 1.5),

                // Note Content
                CustomTextfield(
                  iconData: const Icon(LucideIcons.fileText),
                  maxLines: 4,
                  controller: _contentController,
                  hintText: 'Note Content*',
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 1.5),

                // Existing Attachment indicator if present
                if (widget.note.noteAttachment != null &&
                    widget.note.noteAttachment!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.paperclip,
                          size: 16,
                          color: Color(0xFF2EAF3B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Current: ${widget.note.noteAttachment!.split('/').last}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.height * 1.5),
                ],

                // Attachment File Picker to replace/upload
                CustomFilePicker(
                  label:
                      widget.note.noteAttachment != null &&
                              widget.note.noteAttachment!.isNotEmpty
                          ? "Replace Attachment (Optional, Max 5 mb):"
                          : "Upload Attachment (Optional, Max 5 mb):",
                  fieldName: "parentNoteFile",
                  validator: (value) {
                    final error = context.read<FilePickerProvider>().getError(
                      "parentNoteFile",
                    );
                    return error;
                  },
                ),
                SizedBox(height: Responsive.height * 2.5),

                // ==========================================
                // STUDENTS MANAGEMENT SECTION
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Assigned Students",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _selectedStudentIds.isNotEmpty
                                ? const Color(0xFFE8F5E9)
                                : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_selectedStudentIds.length} Selected",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              _selectedStudentIds.isNotEmpty
                                  ? const Color(0xFF2EAF3B)
                                  : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Sub-section 1: Already Added Students
                if (addedStudents.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.alertCircle,
                          size: 18,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "No students assigned. Please add at least one student below.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addedStudents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final student = addedStudents[index];
                      final name = student.fullName.trim();
                      final initial =
                          name.isNotEmpty ? name[0].toUpperCase() : "S";

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2EAF3B).withAlpha(80),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF2EAF3B),
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (student.regNo != null &&
                                      student.regNo!.isNotEmpty)
                                    Text(
                                      "Reg No: ${student.regNo}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                LucideIcons.x,
                                size: 16,
                                color: Colors.red,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: "Remove student",
                              onPressed: () => _removeStudent(student.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                SizedBox(height: Responsive.height * 2.5),

                // Sub-section 2: Remaining Students in that Class
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Remaining Students in Class",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (!_isLoadingStudents && remainingStudents.isNotEmpty)
                      Text(
                        "${remainingStudents.length} available",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_isLoadingStudents)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF2EAF3B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Loading class students...",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_allClassStudents.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _classId == null
                            ? "No class information found for this note."
                            : "No other students found in this class.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                else if (remainingStudents.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _searchRemainingQuery.isNotEmpty
                            ? "No remaining students match '$_searchRemainingQuery'"
                            : "All students from this class are currently assigned.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                else ...[
                  // Optional search bar if more than 5 remaining students
                  if (_allClassStudents.length > 5) ...[
                    SizedBox(
                      height: 38,
                      child: TextField(
                        controller: _searchRemainingController,
                        decoration: InputDecoration(
                          hintText: "Search remaining students...",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 16,
                            color: Colors.grey,
                          ),
                          suffixIcon:
                              _searchRemainingQuery.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear, size: 14),
                                    onPressed: () {
                                      _searchRemainingController.clear();
                                      setState(() {
                                        _searchRemainingQuery = '';
                                      });
                                    },
                                  )
                                  : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchRemainingQuery = val.trim();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Remaining students list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: remainingStudents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final student = remainingStudents[index];
                      final name = student.fullName.trim();
                      final initial =
                          name.isNotEmpty ? name[0].toUpperCase() : "S";

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (student.regNo != null &&
                                      student.regNo!.isNotEmpty)
                                    Text(
                                      "Reg No: ${student.regNo}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _addStudent(student.id),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFE8F5E9),
                                foregroundColor: const Color(0xFF2EAF3B),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(LucideIcons.plus, size: 14),
                              label: const Text(
                                "Add",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],

                SizedBox(height: Responsive.height * 3.5),

                // Submit Button
                Consumer<ParentNotesProvider>(
                  builder: (context, provider, _) {
                    return CommonButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (widget.note.id == null) return;

                          if (_selectedStudentIds.isEmpty) {
                            CustomSnackbar.show(
                              context,
                              message:
                                  "Please assign at least one student to this note",
                              type: SnackbarType.warning,
                            );
                            return;
                          }

                          final success = await context
                              .read<ParentNotesProvider>()
                              .updateParentNote(
                                context: context,
                                noteId: widget.note.id!,
                                title: _titleController.text.trim(),
                                content: _contentController.text.trim(),
                                studentIds: _selectedStudentIds.toList(),
                              );
                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      widget:
                          provider.isLoading
                              ? const ButtonLoading()
                              : const Text('Update Note'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
