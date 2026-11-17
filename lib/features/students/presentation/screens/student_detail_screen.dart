import 'dart:io';

import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/communication/presentation/screens/communication_detail_screen.dart';
import 'package:acadobs/features/homeworks/data/models/homework_viewer_type.dart';
import 'package:acadobs/features/homeworks/presentation/provider/homeworks_provider.dart';
import 'package:acadobs/features/students/data/models/student_profile_args.dart';
import 'package:acadobs/features/students/data/models/student_screen_args.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/students/presentation/widgets/student_attendence_tab.dart';
import 'package:acadobs/features/students/presentation/widgets/student_feature_card.dart';
import 'package:acadobs/features/timetables/data/models/timetable_type.dart';
import 'package:acadobs/features/timetables/presentation/provider/timetables_provider.dart';
import 'package:acadobs/features/timetables/presentation/widgets/today_timetable_widget.dart';
import 'package:acadobs/routes/modules/common_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/profile_photo_crop_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
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
    super.initState();
    studentProvider = context.read<StudentProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      studentProvider.fetchStudentDetails(
        studentId: widget.studentId,
        forStaff: widget.forStaff,
      );
      studentProvider.fetchCompetencyAssessment(
        studentId: widget.studentId,
        forStaff: widget.forStaff,
      );
      if (!widget.forStaff) {
        context.read<HomeworksProvider>().getUnseenHomeworkCountByStudentId(
          studentId: widget.studentId,
        );
      }
    });
  }

  Future<void> _onRefresh() async {
    final futures = <Future>[
      studentProvider.fetchStudentDetails(
        studentId: widget.studentId,
        forStaff: widget.forStaff,
      ),
      studentProvider.fetchAttendanceByDate(
        studentId: widget.studentId,
        date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
        forStaff: widget.forStaff,
      ),
      studentProvider.fetchCompetencyAssessment(
        studentId: widget.studentId,
        forStaff: widget.forStaff,
      ),
      studentProvider.fetchCoScholasticAssessment(
        studentId: widget.studentId,
        forStaff: widget.forStaff,
      ),
    ];

    if (!widget.forStaff) {
      futures.add(
        context.read<TimetablesProvider>().fetchTodayTimetable(
          type: TimetableType.student,
          studentId: widget.studentId,
          forceRefresh: true,
        ),
      );
      futures.add(
        context.read<HomeworksProvider>().getUnseenHomeworkCountByStudentId(
          studentId: widget.studentId,
        ),
      );
    }

    await Future.wait(futures);
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 95,
      );
      if (pickedFile != null && mounted) {
        final bytes = await pickedFile.readAsBytes();
        final original = kIsWeb ? null : File(pickedFile.path);
        if (!mounted) return;
        final cropResult = await ProfilePhotoCropScreen.cropImage(
          context,
          imageFile: original,
          imageBytes: bytes,
          title: 'Crop Student Profile Photo',
        );

        if (cropResult != null && mounted) {
          await studentProvider.updateProfilePhoto(
            image: cropResult.file,
            imageBytes: cropResult.bytes,
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not access ${source == ImageSource.camera ? "camera" : "gallery"}.',
          ),
          backgroundColor: Colors.red,
        ),
      );
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

  void _showInvoiceRestrictionDialog({
    required String featureTitle,
    String? studentName,
    required bool forStaff,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final name =
            (studentName != null && studentName.trim().isNotEmpty)
                ? studentName.trim()
                : "the student";

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFED7AA),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      color: Color(0xFFEA580C),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Access Restricted",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Access to $name's $featureTitle is currently restricted due to pending fee invoices.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    forStaff
                        ? SizedBox.shrink()
                        : Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.pushNamed(
                                RouteConstants.paymentsScreen,
                                extra: widget.studentId,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA580C),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "View Invoices",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiAnalyticsTab(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF355872), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355872).withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.pushNamed(
              RouteConstants.aiInsightsHome,
              extra: widget.studentId,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.sparkles,
                    color: Color(0xFFFDE68A),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 3,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'AI Analytics & Career Path',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFDE68A,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(
                                  0xFFFDE68A,
                                ).withValues(alpha: 0.45),
                              ),
                            ),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                color: Color(0xFFFDE68A),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Academic profile, skill scores & career predictions',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.arrowRight,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Student Profile', isBackButton: true),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Consumer<StudentProvider>(
                        builder: (context, provider, _) {
                          final student = provider.individualStudent;

                          if (provider.isLoading ||
                              student == null ||
                              student.id != widget.studentId) {
                            return const CommonShimmerTile(height: 100);
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
                                          student.image?.isNotEmpty == true
                                              ? ClipOval(
                                                child: Image.network(
                                                  "${BaseUrls.media}${MediaEndpoints.studentDp}${student.image}",
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
                                                            ? student
                                                                .fullName[0]
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
                                                  student.fullName.isNotEmpty ==
                                                          true
                                                      ? student.fullName[0]
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
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Student Name
                                      Text(
                                        student.fullName.isNotEmpty
                                            ? student.fullName
                                            : "Student Name",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // Class Badge
                                      if (student.classGrade?.classname != null)
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            student.classGrade!.classname,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Dedicated Unique AI Analytics Tab
                _buildAiAnalyticsTab(context),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Attendance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 10),

                StudentAttendenceTab(
                  studentId: widget.studentId,
                  date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                  forStaff: widget.forStaff,
                ),

                const SizedBox(height: 10),
                Consumer<StudentProvider>(
                  builder: (context, studentProvider, _) {
                    final student = studentProvider.individualStudent;
                    final bool isInvoiceRestricted =
                        // !widget.forStaff &&
                        (student?.hasPendingInvoices ?? false);

                    return GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 4 : 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                      children: [
                        StudentFeatureCard(
                          icon: Icons.edit_note,
                          title: "Exam",
                          color: Colors.green,
                          isLocked: isInvoiceRestricted,
                          onTap: () {
                            if (isInvoiceRestricted) {
                              _showInvoiceRestrictionDialog(
                                featureTitle: "Exam",
                                studentName: student?.fullName,
                                forStaff: widget.forStaff,
                              );
                              return;
                            }
                            context.pushNamed(
                              RouteConstants.studentExamScreen,
                              extra: StudentScreenArgs(
                                studentId: widget.studentId,
                                forStaff: widget.forStaff,
                              ),
                            );
                          },
                        ),
                        Consumer<HomeworksProvider>(
                          builder: (context, homeworkProvider, _) {
                            final unseenCount =
                                widget.forStaff
                                    ? 0
                                    : homeworkProvider.getUnseenHomeworkCount(
                                      widget.studentId,
                                    );

                            return StudentFeatureCard(
                              icon: Icons.assignment,
                              color: Colors.brown,
                              title: "Homework",
                              badgeText:
                                  unseenCount > 0 ? "$unseenCount new" : null,
                              badgeColor: const Color(0xFFE11D48),
                              onTap: () async {
                                final params = HomeworkParameters(
                                  viewerType:
                                      widget.forStaff
                                          ? HomeworkViewerType
                                              .teacherStudentView
                                          : HomeworkViewerType
                                              .guardianStudentView,
                                  studentId: widget.studentId,
                                );
                                await context.pushNamed(
                                  RouteConstants.homeworkLisitingScreen,
                                  extra: params,
                                  queryParameters: params.toQueryParameters(),
                                );
                                if (!widget.forStaff && context.mounted) {
                                  context
                                      .read<HomeworksProvider>()
                                      .getUnseenHomeworkCountByStudentId(
                                        studentId: widget.studentId,
                                      );
                                }
                              },
                            );
                          },
                        ),
                        StudentFeatureCard(
                          icon: Icons.emoji_events,
                          color: Colors.amber,
                          title: "Awards",
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
                        if (widget.forStaff)
                          StudentFeatureCard(
                            icon: LucideIcons.messageCircle,
                            color: const Color(0xFF7C3AED),
                            title: "Message Parent",
                            onTap: () {
                              if (student == null ||
                                  student.id != widget.studentId) {
                                return;
                              }
                              final parentUserId =
                                  student.user?.id ?? student.guardianId;
                              if (parentUserId == null) {
                                CustomSnackbar.show(
                                  context,
                                  message:
                                      "Parent account details are not available for this student.",
                                  type: SnackbarType.warning,
                                );
                                return;
                              }
                              final parentName =
                                  (student.user?.name != null &&
                                          student.user!.name!.isNotEmpty)
                                      ? student.user!.name
                                      : "${student.fullName}'s Parent";
                              context.pushNamed(
                                RouteConstants.communicationDetailScreen,
                                extra: CommunicationDetailScreenArgs(
                                  forStaff: true,
                                  receiverId: parentUserId,
                                  opponentName: parentName,
                                  opponentPhone: student.user?.phone,
                                  opponentDp: student.user?.dp,
                                  studentId: student.id,
                                  studentName: student.fullName,
                                ),
                              );
                            },
                          ),
                        if (!widget.forStaff)
                          StudentFeatureCard(
                            icon: LucideIcons.calendarClock,
                            title: "Exam Timetable",
                            color: const Color(0xFF7E57C2),
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.studentExamTimetableScreen,
                                extra: StudentScreenArgs(
                                  studentId: widget.studentId,
                                  forStaff: false,
                                ),
                              );
                            },
                          ),
                        if (!widget.forStaff)
                          StudentFeatureCard(
                            icon: Icons.notifications,
                            title: "Notice",
                            color: Colors.amberAccent,
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
                          icon: Icons.description_outlined,
                          color: Colors.redAccent,
                          title: "Leaves",
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
                        if (studentProvider.hasCompetencyAssessment)
                          StudentFeatureCard(
                            icon: LucideIcons.sparkles,
                            color: const Color(0xFF4834D4),
                            title: "Competency",
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.studentCompetencyScreen,
                                extra: StudentScreenArgs(
                                  studentId: widget.studentId,
                                  forStaff: widget.forStaff,
                                ),
                              );
                            },
                          ),
                        StudentFeatureCard(
                          icon: LucideIcons.shapes,
                          color: const Color(0xFF0077B6),
                          title: "Co-Scholastic",
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.studentCoScholasticScreen,
                              extra: StudentScreenArgs(
                                studentId: widget.studentId,
                                forStaff: widget.forStaff,
                              ),
                            );
                          },
                        ),
                        StudentFeatureCard(
                          icon: LucideIcons.fileSpreadsheet,
                          color: const Color(0xFF0D9488),
                          title: "Progress report",
                          isLocked: isInvoiceRestricted,
                          onTap: () {
                            if (isInvoiceRestricted) {
                              _showInvoiceRestrictionDialog(
                                featureTitle: "Progress report",
                                studentName: student?.fullName,
                                forStaff: widget.forStaff,
                              );
                              return;
                            }
                            context.pushNamed(
                              RouteConstants.studentProgressCardScreen,
                              extra: StudentScreenArgs(
                                studentId: widget.studentId,
                                forStaff: widget.forStaff,
                              ),
                            );
                          },
                        ),
                        StudentFeatureCard(
                          icon: Icons.person,
                          color: Colors.blueGrey,
                          title: "Profile",
                          onTap: () {
                            if (student == null ||
                                student.id != widget.studentId) {
                              return;
                            }
                            context.pushNamed(
                              RouteConstants.studentProfileScreen,
                              extra: StudentProfileArgs(
                                student: student,
                                forStaff: widget.forStaff,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),
                widget.forStaff
                    ? const SizedBox.shrink()
                    : TodayTimetableWidget(
                      type: TimetableType.student,
                      studentId: widget.studentId,
                      forStudent: true,
                    ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
