// import 'package:acadobs/shared/providers/shared_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// Future<void> showStudentSelectionPopup(
//   BuildContext context,
//   int classId,
// ) async {
//   final provider = context.read<SharedProvider>();

//   // Fetch students if not already done
//   await provider.fetchStudentsByClassId(classId: classId, forceRefresh: true);
//   if (!context.mounted) return;
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Consumer<SharedProvider>(
//         builder: (context, provider, _) {
//           final students = provider.students;

//           return AlertDialog(
//             title: const Text("Select Students"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: provider.isAllSelected,
//                       onChanged: (_) {
//                         if (provider.isAllSelected) {
//                           provider.deselectAllStudents();
//                         } else {
//                           provider.selectAllStudents();
//                         }
//                       },
//                     ),
//                     const Text("Select All"),
//                   ],
//                 ),
//                 const Divider(),
//                 SizedBox(
//                   height: 300, // scrollable height
//                   width: 300,
//                   child: ListView.builder(
//                     itemCount: students.length,
//                     itemBuilder: (context, index) {
//                       final student = students[index];
//                       final isSelected = provider.selectedStudentIds.contains(
//                         student.id,
//                       );

//                       return CheckboxListTile(
//                         title: Text(student.fullName), // or roll no etc.
//                         value: isSelected,
//                         onChanged:
//                             (_) => provider.toggleStudentSelection(student.id),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Cancel"),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text("Done"),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }
