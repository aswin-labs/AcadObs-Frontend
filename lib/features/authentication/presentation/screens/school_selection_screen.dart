import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/presentation/provider/auth_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class SchoolSelectionScreen extends StatefulWidget {
  const SchoolSelectionScreen({super.key});

  @override
  State<SchoolSelectionScreen> createState() => _SchoolSelectionScreenState();
}

class _SchoolSelectionScreenState extends State<SchoolSelectionScreen> {
  late AuthProvider authProvider;

  @override
  void initState() {
    authProvider = context.read<AuthProvider>();
    authProvider.fetchSchoolsByParent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: context.paddingHorizontal.add(
          EdgeInsets.only(top: Responsive.height * 14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose a school to continue",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: Responsive.height * 4),
            Consumer<AuthProvider>(
              builder: (context, provider, _) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.schools.length,
                  itemBuilder: (context, index) {
                    final school = provider.schools[index];
                    final isSelected =
                        provider.selectedSchool?.schoolId == school.schoolId;

                    return _SchoolCard(
                      isSelected: isSelected,
                      name: school.school?.name ?? "N/A",
                      onTap: () {
                        provider.selectSchool(school);
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: Responsive.height * 8),
            Consumer<AuthProvider>(
              builder: (context, provider, _) {
                return CommonButton(
                  onPressed: () {
                    provider.saveSchoolIdAndContinue();
                    context.pushReplacementNamed(
                      RouteConstants.bottomNavScreen,
                      extra: UserType.parent,
                    );
                  },
                  widget: Text("Continue"),
                  buttonHeight: Responsive.height * 7,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _SchoolCard({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue.shade100,
          child: Icon(LucideIcons.school),
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing:
            isSelected
                ? const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white, size: 18),
                )
                : const Icon(
                  Icons.circle_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
        onTap: onTap,
      ),
    );
  }
}
