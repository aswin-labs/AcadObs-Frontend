import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/parent_notes/presentation/provider/parent_notes_provider.dart';
import 'package:acadobs/features/parent_notes/presentation/screens/student_parent_notes_listing_screen.dart';
import 'package:acadobs/features/parents/presentation/provider/parent_provider.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class ParentConnectScreen extends StatefulWidget {
  const ParentConnectScreen({super.key});

  @override
  State<ParentConnectScreen> createState() => _ParentConnectScreenState();
}

class _ParentConnectScreenState extends State<ParentConnectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUnseenCounts();
    });
  }

  Future<void> _refreshUnseenCounts() async {
    if (!mounted) return;
    final parentProvider = context.read<ParentProvider>();
    final notesProvider = context.read<ParentNotesProvider>();

    if (parentProvider.students.isEmpty && !parentProvider.isLoading) {
      await parentProvider.fetchStudentsUnderParentBySchoolId();
    }

    if (!mounted) return;
    final studentIds = parentProvider.students.map((s) => s.id).toList();
    await notesProvider.fetchUnseenCountsForStudents(studentIds);
  }

  Future<void> _onParentNotesTap(BuildContext context) async {
    final parentProvider = context.read<ParentProvider>();

    if (parentProvider.students.isEmpty && !parentProvider.isLoading) {
      await parentProvider.fetchStudentsUnderParentBySchoolId();
    }

    if (!context.mounted) return;

    final students = parentProvider.students;

    if (students.isEmpty) {
      CustomSnackbar.show(
        context,
        message: "No students found under your account.",
        type: SnackbarType.warning,
      );
      return;
    }

    if (students.length == 1) {
      final student = students.first;
      await context.pushNamed(
        RouteConstants.studentParentNotesListingScreen,
        extra: StudentParentNotesScreenArgs(
          studentId: student.id,
          studentName: student.fullName,
        ),
      );
      if (mounted) {
        _refreshUnseenCounts();
      }
      return;
    }

    // More than one student under this parent in the school -> ask which student
    _showStudentSelectionSheet(context, students);
  }

  void _showStudentSelectionSheet(
    BuildContext context,
    List<StudentModel> students,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer<ParentNotesProvider>(
          builder: (context, notesProvider, _) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Select Student",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Choose a child to view their parent notes",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(sheetContext).size.height * 0.5,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (itemContext, index) {
                          final student = students[index];
                          final className = student.classGrade?.classname;
                          final unseenCount = notesProvider.getUnseenNoteCount(
                            student.id,
                          );

                          return Material(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                Navigator.of(sheetContext).pop();
                                await context.pushNamed(
                                  RouteConstants
                                      .studentParentNotesListingScreen,
                                  extra: StudentParentNotesScreenArgs(
                                    studentId: student.id,
                                    studentName: student.fullName,
                                  ),
                                );
                                if (mounted) {
                                  _refreshUnseenCounts();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        unseenCount > 0
                                            ? const Color(
                                              0xFF2EAF3B,
                                            ).withAlpha(90)
                                            : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: const Color(0xFFE8F5E9),
                                      child: Text(
                                        student.fullName.isNotEmpty
                                            ? student.fullName[0].toUpperCase()
                                            : "S",
                                        style: const TextStyle(
                                          color: Color(0xFF2EAF3B),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            capitalizeEachWord(
                                              student.fullName,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          if (className != null &&
                                              className.isNotEmpty) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              "Class: $className",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (unseenCount > 0) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF1F2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFFECDD3),
                                          ),
                                        ),
                                        child: Text(
                                          "$unseenCount new",
                                          style: const TextStyle(
                                            color: Color(0xFFE11D48),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE8F5E9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.chevronRight,
                                        size: 16,
                                        color: Color(0xFF2EAF3B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showComingSoonSheet(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required Color lightBgColor,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: lightBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: accentColor),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Coming Soon",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Got it",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalUnseenNotes =
        context.watch<ParentNotesProvider>().totalUnseenNoteCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonAppBar(title: "Connect"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final horizontalPadding = isTablet ? 32.0 : 16.0;

          final options = [
            _ConnectOptionData(
              title: "Parent Notes",
              subtitle:
                  "Receive important notes, classroom updates, and remarks directly from teachers.",
              icon: LucideIcons.fileText,
              accentColor: const Color(0xFF2EAF3B),
              lightBgColor: const Color(0xFFE8F5E9),
              isComingSoon: false,
              unseenCount: totalUnseenNotes,
              onTap: () => _onParentNotesTap(context),
            ),
            _ConnectOptionData(
              title: "Chat",
              subtitle:
                  "Have real-time conversations with teachers regarding your child's progress.",
              icon: LucideIcons.messageCircle,
              accentColor: const Color(0xFF7C3AED),
              lightBgColor: const Color(0xFFF3E8FF),
              isComingSoon: true,
              onTap: () => _showComingSoonSheet(
                context,
                title: "Direct Chat",
                description:
                    "Real-time messaging with teachers is currently under development and will be available in an upcoming update.",
                icon: LucideIcons.messageCircle,
                accentColor: const Color(0xFF7C3AED),
                lightBgColor: const Color(0xFFF3E8FF),
              ),
            ),
            _ConnectOptionData(
              title: "Teachers",
              subtitle:
                  "Browse faculty profiles, subjects taught, qualifications, and contact details.",
              icon: LucideIcons.users,
              accentColor: const Color(0xFF00AEF0),
              lightBgColor: const Color(0xFFE0F7FA),
              isComingSoon: false,
              onTap: () {
                context.pushNamed(RouteConstants.teachersListingScreen);
              },
            ),
          ];

          return RefreshIndicator(
            onRefresh: _refreshUnseenCounts,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Banner Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 28 : 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00AEF0), Color(0xFF0077A8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00AEF0).withAlpha(55),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(45),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Parent – School Hub",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Stay Connected With Your Child's Educators",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 22 : 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Access teacher directories, classroom notes, and direct communication in one place.",
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(225),
                                      fontSize: isTablet ? 14 : 12.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(38),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withAlpha(70),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.messagesSquare,
                                color: Colors.white,
                                size: isTablet ? 36 : 28,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Responsive.height * 2.8),

                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          "Communication Channels",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      // Options List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _ConnectOptionCard(option: options[index]);
                        },
                      ),

                      SizedBox(height: Responsive.height * 4),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConnectOptionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color lightBgColor;
  final bool isComingSoon;
  final int unseenCount;
  final VoidCallback onTap;

  const _ConnectOptionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.lightBgColor,
    required this.isComingSoon,
    this.unseenCount = 0,
    required this.onTap,
  });
}

class _ConnectOptionCard extends StatelessWidget {
  final _ConnectOptionData option;

  const _ConnectOptionCard({required this.option});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: option.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  option.isComingSoon
                      ? const Color(0xFFE2E8F0)
                      : option.accentColor.withAlpha(75),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container with optional unread dot/badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: option.lightBgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      option.icon,
                      color: option.accentColor,
                      size: 26,
                    ),
                  ),
                  if (option.unseenCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            option.unseenCount > 99
                                ? '99+'
                                : option.unseenCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Title, badge, and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          option.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (option.unseenCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFECDD3),
                              ),
                            ),
                            child: Text(
                              "${option.unseenCount} new",
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        if (option.isComingSoon)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFED7AA),
                              ),
                            ),
                            child: const Text(
                              "Coming Soon",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      option.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Trailing indicator
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      option.isComingSoon
                          ? const Color(0xFFF1F5F9)
                          : option.lightBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.isComingSoon
                      ? LucideIcons.clock
                      : LucideIcons.chevronRight,
                  size: 18,
                  color:
                      option.isComingSoon
                          ? Colors.grey.shade500
                          : option.accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
