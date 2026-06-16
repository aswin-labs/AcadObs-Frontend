import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/features/profile/presentation/provider/profile_provider.dart';
import 'package:acadobs/features/profile/presentation/widgets/editing_enable_mode.dart';
import 'package:acadobs/features/teacher/data/models/staff_model.dart';
import 'package:acadobs/shared/models/user_model.dart';

import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class EditProfileStaff extends StatefulWidget {
  const EditProfileStaff({super.key});

  @override
  State<EditProfileStaff> createState() => _EditProfileStaffState();
}

class _EditProfileStaffState extends State<EditProfileStaff> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  late ProfileProvider provider;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    qualificationController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  @override
  void initState() {
    super.initState();

    provider = context.read<ProfileProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.disableEditProfile();

      await provider.fetchProfileStaff();

      final profile = provider.staffProfile;
      if (profile != null) {
        setState(() {
          nameController.text = profile.user?.name ?? '';
          qualificationController.text = profile.qualification ?? '';
          addressController.text = profile.address ?? '';
          emailController.text = profile.user?.email ?? '';
          phoneController.text = profile.user?.phone ?? '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: CommonAppBar(
        title: "My Profile",
        isBackButton: true,
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              if (provider.editProfileEnabled) {
                return SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  context.read<ProfileProvider>().enableEditProfile();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 5),
                      Text(
                        "Edit",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body:
          profileProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: context.paddingHorizontal,
                      child: Consumer<ProfileProvider>(
                        builder: (context, provider, _) {
                          final enabled = provider.editProfileEnabled;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              if (provider.editProfileEnabled)
                                EditingEnableMode(),

                              _buildSectionTitle("Teacher"),
                              SizedBox(height: 10),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.user),
                                controller: nameController,
                                label: " Name",
                                hintText: 'Enter name',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),
                              CustomTextfield(
                                iconData: const Icon(LucideIcons.home),
                                controller: addressController,
                                label: " Address",
                                hintText: 'Enter address',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.school),
                                controller: qualificationController,
                                label: "qualification",
                                hintText: 'qualification',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.mail),
                                controller: emailController,
                                label: "Email",
                                hintText: 'Enter email address',
                                enabled: false,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.phone),
                                controller: phoneController,
                                label: "phone",
                                hintText: 'Enter mobile',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              const SizedBox(height: 50),
                              provider.editProfileEnabled
                                  ? CommonButton(
                                    onPressed: () {
                                      final updatedStaff = StaffModelProfile(
                                        user: UserModel(
                                          name: nameController.text.trim(),
                                          phone: phoneController.text.trim(),
                                          role: 'teacher',
                                        ),
                                        qualification:
                                            qualificationController.text.trim(),
                                        address: addressController.text.trim(),
                                      );
                                      context
                                          .read<ProfileProvider>()
                                          .saveProfileDetailsStaff(
                                            context: context,
                                            staff: updatedStaff,
                                          );
                                    },
                                    widget:
                                        provider.isLoading
                                            ? ButtonLoading()
                                            : Text("Save Changes"),
                                  )
                                  : SizedBox.shrink(),
                              const SizedBox(height: 50),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withAlpha(68),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(45),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.verified, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
