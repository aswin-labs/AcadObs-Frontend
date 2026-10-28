import 'dart:math';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class StudentsPicker extends StatelessWidget {
  final int classId;
  const StudentsPicker({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, _) {
        final selectedCount = studentProvider.selectedStudentIds.length;
        final hasSelection = selectedCount > 0;

        return GestureDetector(
          onTap: () {
            // Dismiss keyboard from any active text field
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();

            if (classId <= 0) {
              CustomSnackbar.show(
                context,
                message: 'Please select a class standard and class first',
                type: SnackbarType.warning,
              );
              return;
            }

            showStudentSelectionPopup(context, classId, selectAllNeeded: true);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: hasSelection ? const Color(0xFFF1FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasSelection ? const Color(0xFF2EAF3B) : Colors.black26,
                width: hasSelection ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasSelection ? LucideIcons.userCheck : LucideIcons.users,
                  color:
                      hasSelection ? const Color(0xFF2EAF3B) : Colors.black54,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasSelection
                        ? 'Manage Students ($selectedCount Selected)*'
                        : 'Manage Students*',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          hasSelection ? FontWeight.w600 : FontWeight.normal,
                      color:
                          hasSelection
                              ? const Color(0xFF1B5E20)
                              : Colors.black87,
                    ),
                  ),
                ),
                if (studentProvider.isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2EAF3B),
                    ),
                  )
                else
                  Icon(
                    LucideIcons.chevronRight,
                    color:
                        hasSelection ? const Color(0xFF2EAF3B) : Colors.black38,
                    size: 18,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> showStudentSelectionPopup(
  BuildContext context,
  int classId, {
  bool selectAllNeeded = true,
}) async {
  // Dismiss keyboard
  FocusScope.of(context).unfocus();
  FocusManager.instance.primaryFocus?.unfocus();

  final provider = context.read<StudentProvider>();

  // Trigger fetch immediately so isLoading becomes true
  provider.fetchStudentsByClassId(context: context, classId: classId);

  // Open dialog immediately to show the loader to the user right away
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _StudentSelectionDialog(
        classId: classId,
        selectAllNeeded: selectAllNeeded,
      );
    },
  );
}

class _StudentSelectionDialog extends StatefulWidget {
  final int classId;
  final bool selectAllNeeded;

  const _StudentSelectionDialog({
    required this.classId,
    required this.selectAllNeeded,
  });

  @override
  State<_StudentSelectionDialog> createState() =>
      _StudentSelectionDialogState();
}

class _StudentSelectionDialogState extends State<_StudentSelectionDialog> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final students = provider.students;
        final filteredStudents =
            _searchQuery.isEmpty
                ? students
                : students.where((s) {
                  final query = _searchQuery.toLowerCase();
                  final nameMatches = s.fullName.toLowerCase().contains(query);
                  final rollMatches =
                      s.rollNumber?.toString().contains(query) ?? false;
                  final regMatches =
                      s.regNo?.toLowerCase().contains(query) ?? false;
                  return nameMatches || rollMatches || regMatches;
                }).toList();

        final selectedCount = provider.selectedStudentIds.length;
        final isAllSelected = provider.isAllSelected;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Dialog already subtracts insetPadding + keyboard insets,
              // so constraints here are the real space available.
              final double dialogWidth = min<double>(
                constraints.maxWidth,
                400.0,
              );
              final double dialogHeight = min<double>(
                constraints.maxHeight,
                560.0,
              );

              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: dialogWidth,
                  height: dialogHeight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Select Students",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (provider.isLoading)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Color(0xFF2EAF3B),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    "Loading students...",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (students.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text(
                                "No students available in this class.",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          )
                        else ...[
                          // Search bar
                          if (students.length > 5) ...[
                            SizedBox(
                              height: 40,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: "Search student...",
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  suffixIcon:
                                      _searchQuery.isNotEmpty
                                          ? IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 16,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() => _searchQuery = '');
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
                                onChanged:
                                    (val) => setState(
                                      () => _searchQuery = val.trim(),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Select All
                          if (widget.selectAllNeeded &&
                              students.isNotEmpty) ...[
                            Row(
                              children: [
                                Checkbox(
                                  value: isAllSelected,
                                  activeColor: const Color(0xFF2EAF3B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (_) {
                                    if (isAllSelected) {
                                      provider.deselectAllStudents();
                                    } else {
                                      provider.selectAllStudents();
                                    }
                                  },
                                ),
                                Text(
                                  isAllSelected ? "Deselect All" : "Select All",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "$selectedCount/${students.length} selected",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        selectedCount > 0
                                            ? const Color(0xFF2EAF3B)
                                            : Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1),
                          ],

                          // Student List
                          Expanded(
                            child:
                                filteredStudents.isEmpty
                                    ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24.0,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "No students match '$_searchQuery'",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    )
                                    : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: filteredStudents.length,
                                      separatorBuilder:
                                          (_, __) => Divider(
                                            height: 1,
                                            color: Colors.grey.shade100,
                                          ),
                                      itemBuilder: (context, index) {
                                        final StudentModel student =
                                            filteredStudents[index];
                                        final isSelected = provider
                                            .selectedStudentIds
                                            .contains(student.id);

                                        return CheckboxListTile(
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                          activeColor: const Color(0xFF2EAF3B),
                                          checkboxShape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          title: Text(
                                            student.fullName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          subtitle:
                                              student.rollNumber != null
                                                  ? Text(
                                                    "Roll No: ${student.rollNumber}",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  )
                                                  : null,
                                          value: isSelected,
                                          onChanged:
                                              (_) => provider
                                                  .toggleStudentSelection(
                                                    student.id,
                                                  ),
                                        );
                                      },
                                    ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                              ),
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2EAF3B),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(80, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                selectedCount > 0
                                    ? "Done ($selectedCount)"
                                    : "Done",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
