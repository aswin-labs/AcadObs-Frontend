import 'dart:io';

import 'package:acadobs/core/utils/common_shimmer_tile.dart';

import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/students/data/models/student_profile_args.dart';
import 'package:acadobs/features/students/data/models/student_screen_args.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';

import 'package:acadobs/features/students/presentation/widgets/student_attendence_tab.dart';

import 'package:acadobs/features/students/presentation/widgets/student_feature_card.dart';

import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;
  final bool forStaff;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
    required this.forStaff,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late StudentProvider studentProvider;
  @override
  void initState() {
    studentProvider = context.read<StudentProvider>();
    studentProvider.fetchStudentDetails(
      studentId: widget.studentId,
      forStaff: widget.forStaff,
    );
    super.initState();
  }

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      if (mounted && _selectedImage != null) {
        await studentProvider.updateProfilePhoto(
          image: _selectedImage!,
          forStaff: widget.forStaff,
          studentId: widget.studentId,
        );
        if (mounted) {
          await studentProvider.fetchStudentDetails(
            studentId: widget.studentId,
            forStaff: widget.forStaff,
          );
        }
      }
    }
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose Photo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.photo_library,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    title: const Text(
                      'Choose from Gallery',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.green.shade700,
                      ),
                    ),
                    title: const Text(
                      'Take a Photo',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              CommonAppBar(title: 'Student Profile', isBackButton: true),
              Row(
                children: [
                  Expanded(
                    child: Consumer<StudentProvider>(
                      builder: (context, provider, _) {
                        final student = provider.individualStudent;

                        if (provider.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: CommonShimmerTile(),
                          );
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(9),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Profile Image & Name
                              Stack(
                                children: [
                                  Container(
                                    width: 75,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF35C2C1),
                                          Color(0xFF00AEF0),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF35C2C1,
                                          ).withAlpha(68),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child:
                                        student?.image?.isNotEmpty == true
                                            ? ClipOval(
                                              child: Image.network(
                                                "${BaseUrls.media}${MediaEndpoints.studentDp}${student!.image}",
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Center(
                                                    child: Text(
                                                      student
                                                                  .fullName
                                                                  .isNotEmpty ==
                                                              true
                                                          ? student.fullName[0]
                                                              .toUpperCase()
                                                          : "S",
                                                      style: const TextStyle(
                                                        fontSize: 40,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                            : Center(
                                              child: Text(
                                                student?.fullName.isNotEmpty ==
                                                        true
                                                    ? student!.fullName[0]
                                                        .toUpperCase()
                                                    : "S",
                                                style: const TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                  ),

                                  if (!widget.forStaff) ...[
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _showPickOptions,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  45,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(width: 10),
                              Column(
                                children: [
                                  // Student Name
                                  Text(
                                    student?.fullName ?? "Student Name",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Class Badge
                                  if (student?.classGrade?.classname != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF35C2C1),
                                            Color(0xFF00AEF0),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        student!.classGrade!.classname,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StudentFeatureCard(
                    icon: Icons.assignment,
                    title: "Homework",
                    onTap: () {
                      context.pushNamed(
                        RouteConstants.studentHomeworkScreen,
                        extra: StudentScreenArgs(
                          studentId: widget.studentId,
                          forStaff: widget.forStaff,
                        ),
                      );
                    },
                  ),
                  StudentFeatureCard(
                    icon: Icons.edit_note,
                    title: "Exam",
                    onTap: () {
                      context.pushNamed(
                        RouteConstants.studentExamScreen,
                        extra: StudentScreenArgs(
                          studentId: widget.studentId,
                          forStaff: widget.forStaff,
                        ),
                      );
                    },
                  ),
                  StudentFeatureCard(
                    icon: Icons.emoji_events,
                    title: "Achievement",
                    onTap: () {
                      context.pushNamed(
                        RouteConstants.studentAchievementScreen,
                        extra: StudentScreenArgs(
                          studentId: widget.studentId,
                          forStaff: widget.forStaff,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StudentFeatureCard(
                    icon: Icons.notifications,
                    title: "Notice",
                    onTap: () {
                      context.pushNamed(
                        RouteConstants.studentNoticeScreen,
                        extra: StudentScreenArgs(
                          studentId: widget.studentId,
                          forStaff: widget.forStaff,
                        ),
                      );
                    },
                  ),
                  StudentFeatureCard(
                    icon: Icons.request_page,
                    title: "Leave Request",
                    onTap: () {
                      context.pushNamed(
                        RouteConstants.studentLeaveScreen,
                        extra: StudentScreenArgs(
                          studentId: widget.studentId,
                          forStaff: widget.forStaff,
                        ),
                      );
                    },
                  ),
                  Consumer<StudentProvider>(
                    builder: (context, provider, _) {
                      final student = provider.individualStudent;
                      return StudentFeatureCard(
                        icon: Icons.person,
                        title: "Profile",
                        onTap: () {
                          context.pushNamed(
                            RouteConstants.studentProfileScreen,
                            extra: StudentProfileArgs(
                              student: student!,
                              forStaff: widget.forStaff,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StudentAttendenceTab(
                studentId: widget.studentId,
                date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                forStaff: widget.forStaff,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
