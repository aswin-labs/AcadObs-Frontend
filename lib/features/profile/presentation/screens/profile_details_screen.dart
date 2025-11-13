import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/features/profile/data/models/guardian_model.dart';
import 'package:acadobs/features/profile/presentation/provider/profile_provider.dart';
import 'package:acadobs/features/profile/presentation/widgets/editing_enable_mode.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  // Controllers
  final TextEditingController guardianNameController = TextEditingController();
  final TextEditingController guardianContactController =
      TextEditingController();
  final TextEditingController guardianEmailController = TextEditingController();
  final TextEditingController guardianJobController = TextEditingController();
  final TextEditingController guardianRelationController =
      TextEditingController();

  final TextEditingController guardian2NameController = TextEditingController();
  final TextEditingController guardian2ContactController =
      TextEditingController();
  final TextEditingController guardian2JobController = TextEditingController();
  final TextEditingController guardian2RelationController =
      TextEditingController();

  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  late ProfileProvider provider;
  @override
  void initState() {
    super.initState();

    provider = context.read<ProfileProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.disableEditProfile();
      await provider.fetchProfileGuardian();

      final profile = provider.guardianProfile;
      if (profile != null) {
        setState(() {
          guardianNameController.text = profile.guardianName ?? '';
          guardianContactController.text = profile.guardianContact ?? '';
          guardianEmailController.text = profile.guardianEmail ?? '';
          guardianJobController.text = profile.guardianJob ?? '';
          guardianRelationController.text = profile.guardianRelation ?? '';

          guardian2NameController.text = profile.guardian2Name ?? '';
          guardian2ContactController.text = profile.guardian2Contact ?? '';
          guardian2JobController.text = profile.guardian2Job ?? '';
          guardian2RelationController.text = profile.guardian2Relation ?? '';

          fatherNameController.text = profile.fatherName ?? '';
          motherNameController.text = profile.motherName ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    guardianNameController.dispose();
    guardianContactController.dispose();
    guardianEmailController.dispose();
    guardianJobController.dispose();
    guardianRelationController.dispose();
    guardian2NameController.dispose();
    guardian2ContactController.dispose();
    guardian2JobController.dispose();
    guardian2RelationController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    super.dispose();
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

                              _buildSectionTitle("Primary Guardian"),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.user),
                                controller: guardianNameController,
                                label: "Guardian Name",
                                hintText: 'Enter guardian name',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.phone),
                                controller: guardianContactController,
                                label: "Contact Number",
                                hintText: 'Enter contact number',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.mail),
                                controller: guardianEmailController,
                                label: "Email",
                                hintText: 'Enter email address',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.briefcase),
                                controller: guardianJobController,
                                label: "Job",
                                hintText: 'Enter occupation',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.users),
                                controller: guardianRelationController,
                                label: "Relation",
                                hintText: 'Enter relation to student',
                                enabled: enabled,
                              ),

                              const SizedBox(height: 30),

                              // Secondary Guardian Section
                              _buildSectionTitle("Secondary Guardian"),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.user),
                                controller: guardian2NameController,
                                label: "Guardian 2 Name",
                                hintText: 'Enter secondary guardian name',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.phone),
                                controller: guardian2ContactController,
                                label: "Contact Number",
                                hintText: 'Enter contact number',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.briefcase),
                                controller: guardian2JobController,
                                label: "Job",
                                hintText: 'Enter occupation',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.users),
                                controller: guardian2RelationController,
                                label: "Relation",
                                hintText: 'Enter relation to student',
                                enabled: enabled,
                              ),

                              const SizedBox(height: 30),

                              // Parents Section
                              _buildSectionTitle("Parents"),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.user),
                                controller: fatherNameController,
                                label: "Father's Name",
                                hintText: 'Enter father\'s name',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),

                              CustomTextfield(
                                iconData: const Icon(LucideIcons.user),
                                controller: motherNameController,
                                label: "Mother's Name",
                                hintText: 'Enter mother\'s name',
                                enabled: enabled,
                              ),

                              const SizedBox(height: 50),
                              provider.editProfileEnabled
                                  ? CommonButton(
                                    onPressed: () {
                                      final updatedGuardian = GuardianModel(
                                        guardianName:
                                            guardianNameController.text.trim(),
                                        guardianContact:
                                            guardianContactController.text
                                                .trim(),
                                        guardianEmail:
                                            guardianEmailController.text.trim(),
                                        guardianJob:
                                            guardianJobController.text.trim(),
                                        guardianRelation:
                                            guardianRelationController.text
                                                .trim(),
                                        guardian2Name:
                                            guardian2NameController.text.trim(),
                                        guardian2Contact:
                                            guardian2ContactController.text
                                                .trim(),
                                        guardian2Job:
                                            guardian2JobController.text.trim(),
                                        guardian2Relation:
                                            guardian2RelationController.text
                                                .trim(),
                                        fatherName:
                                            fatherNameController.text.trim(),
                                        motherName:
                                            motherNameController.text.trim(),
                                      );
                                      context
                                          .read<ProfileProvider>()
                                          .saveProfileDetails(
                                            context: context,
                                            guardian: updatedGuardian,
                                          );
                                    },
                                    widget:
                                        provider.isLoadingTwo
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
