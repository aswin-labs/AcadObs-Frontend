import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/features/profile/data/models/guardian_model.dart';
import 'package:acadobs/features/profile/presentation/provider/profile_provider.dart';
import 'package:acadobs/features/profile/presentation/widgets/editing_enable_mode.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
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

  final TextEditingController houseNameController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

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

          houseNameController.text = profile.houseName ?? '';
          streetController.text = profile.street ?? '';
          cityController.text = profile.city ?? '';
          landmarkController.text = profile.landmark ?? '';
          districtController.text = profile.district ?? '';
          stateController.text = profile.state ?? '';
          countryController.text = profile.country ?? '';
          postController.text = profile.post ?? '';
          pincodeController.text = profile.pincode ?? '';
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

    houseNameController.dispose();
    streetController.dispose();
    cityController.dispose();
    landmarkController.dispose();
    districtController.dispose();
    stateController.dispose();
    countryController.dispose();
    postController.dispose();
    pincodeController.dispose();
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

                              if (!enabled) ...[
                                Container(
                                  // margin: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.grey.shade50,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title and Edit button
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Login Information',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.grey.shade900,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Guardian account details',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                context.pushNamed(
                                                  RouteConstants.changelogin,
                                                );
                                              },
                                              icon: Icon(
                                                LucideIcons.edit2,
                                                color: Colors.blue.shade700,
                                              ),
                                              style: IconButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue.shade50,
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Divider(
                                        height: 1,
                                        color: Colors.grey.shade300,
                                      ),

                                      // Fields
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            _buildSimpleField(
                                              label: 'Guardian Name',
                                              value:
                                                  guardianNameController.text,
                                              icon: LucideIcons.user,
                                            ),
                                            const SizedBox(height: 20),
                                            _buildSimpleField(
                                              label: 'Contact Number',
                                              value:
                                                  guardianContactController
                                                      .text,
                                              icon: LucideIcons.phone,
                                            ),
                                            const SizedBox(height: 20),
                                            _buildSimpleField(
                                              label: 'Email Address',
                                              value:
                                                  guardianEmailController.text,
                                              icon: LucideIcons.mail,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // if (!enabled) ...[
                              //   Container(
                              //     padding: EdgeInsets.all(12),
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(8),

                              //       // color: Colors.blue[200],
                              //       border: Border.all(color: Colors.black),
                              //     ),
                              //     child: Column(
                              //       children: [
                              //         CustomTextfield(
                              //           iconData: const Icon(LucideIcons.user),
                              //           controller: guardianNameController,
                              //           label: "Guardian Name",
                              //           hintText: 'Enter guardian name',
                              //           enabled: false, // 🔒 FIXED
                              //         ),
                              //         const SizedBox(height: 16),

                              //         CustomTextfield(
                              //           iconData: const Icon(LucideIcons.phone),
                              //           controller: guardianContactController,
                              //           label: "Contact Number",
                              //           hintText: 'Enter contact number',
                              //           enabled: false, // 🔒 FIXED
                              //         ),
                              //         const SizedBox(height: 16),

                              //         CustomTextfield(
                              //           iconData: const Icon(LucideIcons.mail),
                              //           controller: guardianEmailController,
                              //           label: "Email",
                              //           hintText: 'Enter email address',
                              //           enabled: false, // 🔒 FIXED
                              //         ),

                              //         TextButton(
                              //           onPressed: () {
                              //             context.pushNamed(
                              //               RouteConstants.changelogin,
                              //             );
                              //           },
                              //           child: Text("Edit"),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ],
                              SizedBox(height: 20),

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

                              const SizedBox(height: 16),
                              CustomTextfield(
                                iconData: const Icon(Icons.home),
                                controller: houseNameController,
                                label: "House Name",
                                hintText: 'Enter house name',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),
                              CustomTextfield(
                                iconData: const Icon(Icons.signpost),
                                controller: streetController,
                                label: "Street",
                                hintText: 'Enter street name',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),
                              CustomTextfield(
                                iconData: const Icon(Icons.location_city),
                                controller: cityController,
                                label: "City",
                                hintText: 'Enter city name',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),
                              CustomTextfield(
                                iconData: const Icon(LucideIcons.landmark),
                                controller: landmarkController,
                                label: "Landmark",
                                hintText: 'Enter landmark name',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),
                              CustomTextfield(
                                iconData: const Icon(LucideIcons.map),
                                controller: districtController,
                                label: "District",
                                hintText: 'Enter district name',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),
                              CustomTextfield(
                                iconData: const Icon(LucideIcons.mapPin),
                                controller: stateController,
                                label: "State",
                                hintText: 'Enter state name',
                                enabled: enabled,
                              ),

                              const SizedBox(height: 16),
                              CustomTextfield(
                                iconData: const Icon(LucideIcons.globe),
                                controller: countryController,
                                label: "Country",
                                hintText: 'Enter country name',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),
                              CustomTextfield(
                                iconData: const Icon(LucideIcons.mail),
                                controller: postController,
                                label: "Post",
                                hintText: 'Enter post',
                                enabled: enabled,
                              ),
                              const SizedBox(height: 16),
                              CustomTextfield(
                                iconData: const Icon(LucideIcons.hash),
                                controller: pincodeController,
                                label: "Pincode",
                                hintText: 'Enter pincode',
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
                                        houseName:
                                            houseNameController.text.trim(),
                                        street: streetController.text.trim(),
                                        city: cityController.text.trim(),
                                        district:
                                            districtController.text.trim(),
                                        state: stateController.text.trim(),
                                        country: countryController.text.trim(),
                                        post: postController.text.trim(),
                                        pincode: pincodeController.text.trim(),
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

// Helper method
Widget _buildSimpleField({
  required String label,
  required String value,
  required IconData icon,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: Colors.grey.shade600),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
