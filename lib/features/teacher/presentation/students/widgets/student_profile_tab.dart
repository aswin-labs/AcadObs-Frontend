import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/shared/models/student_model.dart';
import 'package:flutter/material.dart';

class StudentProfileTab extends StatelessWidget {
  final StudentModel student;

  const StudentProfileTab({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 55),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Responsive.height * 2),
            sectionTitle("Personal Information"),
            _infoTile("Full Name", student.fullName),
            _infoTile(
              "Date of Birth",
              student.dateOfBirth?.toLocal().toString().split(' ')[0],
            ),
            _infoTile("Gender", student.gender),
            _infoTile("Contact Number", student.user?.phone),
            _infoTile("Email", student.user?.email),
            _infoTile("Residential Address", student.address),
            const SizedBox(height: 24),
            sectionTitle("Academic Details"),
            _infoTile("Class", student.classGrade?.classname),
            _infoTile("Roll Number", student.rollNumber?.toString()),
            _infoTile("Admission Number", student.regNo),
            const SizedBox(height: 24),
            sectionTitle("Parent/Guardian Details"),
            _infoTile("Father's Name", student.user?.name),
            _infoTile("Guardian's Name", student.user?.name),
            _infoTile("Father Contact", student.user?.phone),
            _infoTile("Parent Email", student.user?.email),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // const Divider(thickness: 2),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _infoTile(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value?.isNotEmpty == true ? value! : "-"),
          ),
        ],
      ),
    );
  }
}
