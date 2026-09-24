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

  final _formKey = GlobalKey<FormState>();

  void _resetControllers(StaffModelProfile profile) {
    setState(() {
      nameController.text = profile.user?.name ?? '';
      qualificationController.text = profile.qualification ?? '';
      addressController.text = profile.address ?? '';
      emailController.text = profile.user?.email ?? '';
      phoneController.text = profile.user?.phone ?? '';
    });
  }

  void _onCancelEdit() {
    final profile = provider.staffProfile;
    if (profile != null) {
      _resetControllers(profile);
    }
    provider.disableEditProfile();
  }

  void _saveProfile() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }
    final updatedStaff = StaffModelProfile(
      user: UserModel(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        role: 'teacher',
      ),
      qualification: qualificationController.text.trim(),
      address: addressController.text.trim(),
    );
    await context.read<ProfileProvider>().saveProfileDetailsStaff(
      context: context,
      staff: updatedStaff,
    );
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
                return TextButton.icon(
                  onPressed: _onCancelEdit,
                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                  label: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                );
              }

              return GestureDetector(
                onTap: () {
                  context.read<ProfileProvider>().enableEditProfile();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 5),
                      Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
              : Form(
                  key: _formKey,
                  child: CustomScrollView(
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
                                    const EditingEnableMode(),

                                  _buildSectionTitle("Teacher"),
                                  const SizedBox(height: 10),

                                  CustomTextfield(
                                    iconData: const Icon(LucideIcons.user),
                                    controller: nameController,
                                    label: "Full Name",
                                    hintText: 'Enter name',
                                    enabled: enabled,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextfield(
                                    iconData: const Icon(LucideIcons.home),
                                    controller: addressController,
                                    label: "Address",
                                    hintText: 'Enter address',
                                    enabled: enabled,
                                  ),
                                  const SizedBox(height: 16),

                                  CustomTextfield(
                                    iconData: const Icon(LucideIcons.school),
                                    controller: qualificationController,
                                    label: "Qualification",
                                    hintText: 'Enter qualification',
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
                                    label: "Phone Number",
                                    hintText: 'Enter mobile',
                                    keyBoardtype: TextInputType.phone,
                                    enabled: enabled,
                                    validator: (value) {
                                      if (value != null && value.trim().isNotEmpty) {
                                        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                                        if (digits.length < 7 || digits.length > 15) {
                                          return 'Please enter a valid phone number (7-15 digits)';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 40),

                                  if (provider.editProfileEnabled) ...[
                                    CommonButton(
                                      onPressed:
                                          provider.isLoadingTwo
                                              ? () {}
                                              : _saveProfile,
                                      widget:
                                          provider.isLoadingTwo
                                              ? const ButtonLoading()
                                              : const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.check_rounded,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "Save Changes",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed:
                                            provider.isLoadingTwo
                                                ? null
                                                : _onCancelEdit,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey.shade700,
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          "Discard Changes",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 50),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
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
