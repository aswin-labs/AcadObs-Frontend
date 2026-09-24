import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/features/profile/data/models/guardian_model.dart';
import 'package:acadobs/features/profile/presentation/provider/profile_provider.dart';
import 'package:acadobs/features/profile/presentation/widgets/editing_enable_mode.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
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
      await Future.wait([
        provider.fetchProfileGuardian(),
        provider.fetchGuardianRelations(),
      ]);

      final profile = provider.guardianProfile;
      if (profile != null && mounted) {
        _resetControllers(profile);
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

  final _formKey = GlobalKey<FormState>();

  String? _findMatchingRelation(
    String? relation,
    List<String> availableRelations,
  ) {
    if (relation == null || relation.trim().isEmpty) return null;
    final trimmed = relation.trim();
    final lower = trimmed.toLowerCase();
    final normalized = lower.replaceAll(' ', '_');

    for (final r in availableRelations) {
      if (r.toLowerCase() == lower || r.toLowerCase() == normalized) {
        return r;
      }
    }
    return trimmed;
  }

  String _formatRelationLabel(String value) {
    if (value.isEmpty) return value;
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '',
        )
        .join(' ');
  }

  void _resetControllers(GuardianModel profile) {
    final relations = context.read<ProfileProvider>().guardianRelations;

    final primaryRel =
        _findMatchingRelation(profile.guardianRelation, relations) ??
            (profile.guardianRelation ?? '');
    final secondaryRel =
        _findMatchingRelation(profile.guardian2Relation, relations) ??
            (profile.guardian2Relation ?? '');

    if (mounted) {
      context
          .read<DropdownProvider>()
          .setSelectedItem('guardianRelation', primaryRel);
      context
          .read<DropdownProvider>()
          .setSelectedItem('guardian2Relation', secondaryRel);
    }

    setState(() {
      guardianNameController.text = (profile.user?.name ?? '');
      guardianContactController.text = (profile.user?.phone ?? '');
      guardianEmailController.text = (profile.user?.email ?? '');
      guardianJobController.text = profile.guardianJob ?? '';
      guardianRelationController.text = primaryRel;

      guardian2NameController.text = profile.guardian2Name ?? '';
      guardian2ContactController.text = profile.guardian2Contact ?? '';
      guardian2JobController.text = profile.guardian2Job ?? '';
      guardian2RelationController.text = secondaryRel;

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

  void _onCancelEdit() {
    final profile = provider.guardianProfile;
    if (profile != null) {
      _resetControllers(profile);
    }
    provider.disableEditProfile();
  }

  void _saveProfile() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    final selectedPrimaryRel = context
        .read<DropdownProvider>()
        .getSelectedItem('guardianRelation');
    final selectedSecondaryRel = context
        .read<DropdownProvider>()
        .getSelectedItem('guardian2Relation');

    final primaryRelation = selectedPrimaryRel.isNotEmpty
        ? selectedPrimaryRel
        : guardianRelationController.text.trim();
    final secondaryRelation = selectedSecondaryRel.isNotEmpty
        ? selectedSecondaryRel
        : guardian2RelationController.text.trim();

    final updatedGuardian = GuardianModel(
      guardianName: guardianNameController.text.trim(),
      guardianContact: guardianContactController.text.trim(),
      guardianEmail: guardianEmailController.text.trim(),
      guardianJob: guardianJobController.text.trim(),
      guardianRelation: primaryRelation,
      guardian2Name: guardian2NameController.text.trim(),
      guardian2Contact: guardian2ContactController.text.trim(),
      guardian2Job: guardian2JobController.text.trim(),
      guardian2Relation: secondaryRelation,
      fatherName: fatherNameController.text.trim(),
      motherName: motherNameController.text.trim(),
      houseName: houseNameController.text.trim(),
      street: streetController.text.trim(),
      city: cityController.text.trim(),
      district: districtController.text.trim(),
      state: stateController.text.trim(),
      country: countryController.text.trim(),
      post: postController.text.trim(),
      pincode: pincodeController.text.trim(),
    );
    final success = await context.read<ProfileProvider>().saveProfileDetails(
      context: context,
      guardian: updatedGuardian,
    );
    if (success && mounted) {
      final updatedProfile = context.read<ProfileProvider>().guardianProfile;
      if (updatedProfile != null) {
        _resetControllers(updatedProfile);
      }
    }
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
                  final profile =
                      context.read<ProfileProvider>().guardianProfile;
                  if (profile != null) {
                    _resetControllers(profile);
                  }
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
                                                            Colors
                                                                .grey
                                                                .shade900,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Guardian account details',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  await context.pushNamed(
                                                    RouteConstants.changelogin,
                                                  );
                                                  if (!context.mounted) return;
                                                  await provider
                                                      .fetchProfileGuardian();
                                                  final profile =
                                                      provider.guardianProfile;
                                                  if (profile != null) {
                                                    _resetControllers(profile);
                                                  }
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
                                        Builder(
                                          builder: (context) {
                                            final profile =
                                                provider.guardianProfile;
                                            final displayName =
                                                (profile
                                                            ?.user
                                                            ?.name
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? profile!.user!.name!
                                                    : guardianNameController
                                                        .text);
                                            final displayContact =
                                                (profile
                                                            ?.user
                                                            ?.phone
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? profile!.user!.phone!
                                                    : guardianContactController
                                                        .text);
                                            final displayEmail =
                                                (profile
                                                            ?.user
                                                            ?.email
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? profile!.user!.email!
                                                    : guardianEmailController
                                                        .text);

                                            return Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                children: [
                                                  _buildSimpleField(
                                                    label: 'Guardian Name',
                                                    value: displayName,
                                                    icon: LucideIcons.user,
                                                  ),
                                                  const SizedBox(height: 20),
                                                  _buildSimpleField(
                                                    label: 'Contact Number',
                                                    value: displayContact,
                                                    icon: LucideIcons.phone,
                                                  ),
                                                  const SizedBox(height: 20),
                                                  _buildSimpleField(
                                                    label: 'Email Address',
                                                    value: displayEmail,
                                                    icon: LucideIcons.mail,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                              
                                SizedBox(height: 20),

                                CustomTextfield(
                                  iconData: const Icon(LucideIcons.briefcase),
                                  controller: guardianJobController,
                                  label: "Job",
                                  hintText: 'Enter occupation',
                                  enabled: enabled,
                                ),
                                const SizedBox(height: 16),

                                Builder(
                                  builder: (context) {
                                    final relList =
                                        provider.guardianRelations.isNotEmpty
                                            ? provider.guardianRelations
                                            : ProfileProvider.defaultRelations;
                                    final currentRel = context
                                        .watch<DropdownProvider>()
                                        .getSelectedItem('guardianRelation');
                                    final items =
                                        (currentRel.isNotEmpty &&
                                                !relList.contains(currentRel))
                                            ? [currentRel, ...relList]
                                            : relList;

                                    return CustomDropdown(
                                      dropdownKey: 'guardianRelation',
                                      label: "Relation",
                                      icon: LucideIcons.users,
                                      enabled: enabled,
                                      items: items,
                                      itemLabelBuilder: _formatRelationLabel,
                                      onChanged: (val) {
                                        guardianRelationController.text = val;
                                      },
                                      validator:
                                          (val) =>
                                              val == null || val.isEmpty
                                                  ? 'Please select a relation'
                                                  : null,
                                    );
                                  },
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

                                Builder(
                                  builder: (context) {
                                    final relList =
                                        provider.guardianRelations.isNotEmpty
                                            ? provider.guardianRelations
                                            : ProfileProvider.defaultRelations;
                                    final currentRel = context
                                        .watch<DropdownProvider>()
                                        .getSelectedItem('guardian2Relation');
                                    final items =
                                        (currentRel.isNotEmpty &&
                                                !relList.contains(currentRel))
                                            ? [currentRel, ...relList]
                                            : relList;

                                    return CustomDropdown(
                                      dropdownKey: 'guardian2Relation',
                                      label: "Relation",
                                      icon: LucideIcons.users,
                                      enabled: enabled,
                                      items: items,
                                      itemLabelBuilder: _formatRelationLabel,
                                      onChanged: (val) {
                                        guardian2RelationController.text = val;
                                      },
                                    );
                                  },
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
