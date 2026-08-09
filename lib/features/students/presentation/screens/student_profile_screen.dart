import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudentProfileScreen extends StatelessWidget {
  final StudentModel student;
  final bool forStaff;

  const StudentProfileScreen({
    super.key,
    required this.student,
    required this.forStaff,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Student Profile', isBackButton: true),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            _buildProfileHeader(),

            const SizedBox(height: 10),

            // Personal Information Section
            _buildSection(
              icon: Icons.person_outline,
              iconColor: Colors.blue,
              title: "Personal Information",
              children: [
                _buildInfoRow(Icons.badge, "Full Name", student.fullName),
                _buildInfoRow(
                  Icons.cake_outlined,
                  "Date of Birth",
                  student.dateOfBirth != null
                      ? DateFormat('dd MMM yyyy').format(student.dateOfBirth!)
                      : null,
                ),
                _buildInfoRow(
                  Icons.wc,
                  "Gender",
                  student.gender != null
                      ? student.gender![0].toUpperCase() +
                          student.gender!.substring(1)
                      : null,
                ),
                _buildInfoRow(
                  Icons.phone_outlined,
                  "Contact Number",
                  student.user?.phone,
                ),
                _buildInfoRow(
                  Icons.email_outlined,
                  "Email",
                  student.user?.email,
                ),
                // _buildInfoRow(
                //   Icons.home_outlined,
                //   "Address",
                //   student.address,
                //   isAddress: true,
                //   forStaff: forStaff,
                // ),
              ],
            ),

            const SizedBox(height: 16),

            // Academic Details Section
            _buildSection(
              icon: Icons.school_outlined,
              iconColor: Colors.purple,
              title: "Academic Details",
              children: [
                _buildInfoRow(
                  Icons.class_,
                  "Class",
                  student.classGrade?.classname,
                ),
                _buildInfoRow(
                  Icons.numbers,
                  "Roll Number",
                  student.rollNumber?.toString(),
                ),
                _buildInfoRow(
                  Icons.confirmation_number_outlined,
                  "Admission Number",
                  student.regNo,
                ),
                _buildInfoRow(
                  Icons.calendar_month_outlined,
                  "Admission Date",
                  student.admissionDate != null
                      ? DateFormat('dd MMM yyyy').format(student.admissionDate!)
                      : null,
                ),
                _buildInfoRow(
                  Icons.info_outline,
                  "Status",
                  student.status != null && student.status!.isNotEmpty
                      ? student.status![0].toUpperCase() +
                          student.status!.substring(1)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Parent / Guardian Details
            _buildSection(
              icon: Icons.family_restroom,
              iconColor: Colors.green,
              title: "Parent/Guardian Details",
              children: [
                _buildInfoRow(
                  Icons.person_outline,
                  "Father's Name",
                  student.user?.guardian?.fatherName,
                ),
                _buildInfoRow(
                  Icons.person_outline,
                  "Mother's Name",
                  student.user?.guardian?.motherName,
                ),

                // Primary Guardian
                _buildInfoRow(
                  Icons.person,
                  "Guardian Name",
                  student.user?.guardian?.guardianName,
                ),
                _buildInfoRow(
                  Icons.family_restroom,
                  "Relation",
                  student.user?.guardian?.guardianRelation,
                ),
                _buildInfoRow(
                  Icons.phone_outlined,
                  "Guardian Contact",
                  student.user?.guardian?.guardianContact,
                ),
                _buildInfoRow(
                  Icons.email_outlined,
                  "Guardian Email",
                  student.user?.guardian?.guardianEmail,
                ),
                _buildInfoRow(
                  Icons.work_outline,
                  "Guardian Job",
                  student.user?.guardian?.guardianJob,
                ),

                // Secondary Guardian
                _buildInfoRow(
                  Icons.person_outline,
                  "Second Guardian Name",
                  student.user?.guardian?.guardian2Name,
                ),
                _buildInfoRow(
                  Icons.family_restroom,
                  "Second Guardian Relation",
                  student.user?.guardian?.guardian2Relation,
                ),
                _buildInfoRow(
                  Icons.phone_outlined,
                  "Second Guardian Contact",
                  student.user?.guardian?.guardian2Contact,
                ),
                _buildInfoRow(
                  Icons.work_outline,
                  "Second Guardian Job",
                  student.user?.guardian?.guardian2Job,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Address Details
            _buildSection(
              icon: Icons.location_on_outlined,
              iconColor: Colors.orange,
              title: "Address Details",
              children: [
                _buildInfoRow(
                  Icons.home_outlined,
                  "House Name",
                  student.user?.guardian?.houseName,
                ),
                _buildInfoRow(
                  Icons.add_road_outlined,
                  "Street",
                  student.user?.guardian?.street,
                ),
                _buildInfoRow(
                  Icons.location_city_outlined,
                  "City",
                  student.user?.guardian?.city,
                ),
                _buildInfoRow(
                  Icons.place_outlined,
                  "Landmark",
                  student.user?.guardian?.landmark,
                ),
                _buildInfoRow(
                  Icons.map_outlined,
                  "District",
                  student.user?.guardian?.district,
                ),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  "State",
                  student.user?.guardian?.state,
                ),
                _buildInfoRow(
                  Icons.public,
                  "Country",
                  student.user?.guardian?.country,
                ),
                _buildInfoRow(
                  Icons.local_post_office_outlined,
                  "Post",
                  student.user?.guardian?.post,
                ),
                _buildInfoRow(
                  Icons.pin_drop_outlined,
                  "Pincode",
                  student.user?.guardian?.pincode,
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF35C2C1), Color(0xFF00AEF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF35C2C1).withAlpha(68),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(23),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                student.fullName.isNotEmpty == true
                    ? student.fullName[0].toUpperCase()
                    : "S",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF35C2C1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if (student.classGrade?.classname != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      student.classGrade!.classname,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (student.rollNumber != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Roll No: ${student.rollNumber}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withAlpha(203),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(9),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(23),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String? value, {
    bool isAddress = false,
    bool forStaff = false,
  }) {
    final hasValue = value?.isNotEmpty == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment:
            isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),

          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasValue ? value! : "Not provided",
                  style: TextStyle(
                    fontSize: 15,
                    color: hasValue ? Colors.grey[800] : Colors.grey[400],
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                    fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (isAddress && !forStaff) ...[
            Builder(
              builder:
                  (context) => IconButton(
                    onPressed: () {
                      _showEditAddressDialog(context);
                    },
                    icon: Icon(Icons.edit),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditAddressDialog(BuildContext context) {
    final TextEditingController addressController = TextEditingController(
      text: student.address,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Address"),
          content: TextField(
            controller: addressController,
            decoration: const InputDecoration(
              hintText: "Enter address",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<StudentProvider>(
                  context,
                  listen: false,
                ).updateStudentAddress(
                  studentId: student.id,
                  address: addressController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
