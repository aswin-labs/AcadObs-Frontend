import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/profile/data/models/guardian_model.dart';
import 'package:acadobs/features/profile/presentation/provider/profile_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class EditCredential extends StatefulWidget {
  const EditCredential({super.key});

  @override
  State<EditCredential> createState() => _EditCredentialState();
}

class _EditCredentialState extends State<EditCredential> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController guardianEmailController = TextEditingController();
  final TextEditingController guardianNameController = TextEditingController();
  final TextEditingController guardianContactController =
      TextEditingController();
  late ProfileProvider provider;

  @override
  void initState() {
    super.initState();
    provider = context.read<ProfileProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.disableEditProfile();
      await provider.fetchProfileGuardian();

      final profile = provider.guardianProfile;
      if (profile != null && mounted) {
        setState(() {
          guardianNameController.text = profile.user!.name!;
          guardianContactController.text = profile.user!.phone!;
          guardianEmailController.text = profile.user!.email!;
        });
      }
    });
  }

  @override
  void dispose() {
    guardianEmailController.dispose();
    guardianContactController.dispose();
    guardianNameController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showConfirmationDialog(
      context: context,
      title: "Update Login Credentials?",
      content:
          "Updating your contact number or email will change your login credentials. You must use the new information on your next sign-in.",
      action: "Confirm & Save",
      onConfirm: () async {
        final updatedGuardian = GuardianModel(
          guardianName: guardianNameController.text.trim(),
          guardianContact: guardianContactController.text.trim(),
          guardianEmail: guardianEmailController.text.trim(),
        );
        final success = await context
            .read<ProfileProvider>()
            .changeCredentialAndName(
              context: context,
              guardian: updatedGuardian,
            );
        if (success && mounted) {
          context.pop(true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CommonAppBar(
        title: "Edit Login Information",
        isBackButton: true,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warning Notice Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber.shade300,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.alertTriangle,
                              color: Colors.amber.shade900,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Important Account Notice',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your contact number is used to sign in to your AcadObs account. Please ensure all values are correct and active before saving.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.amber.shade900.withValues(
                                      alpha: 0.85,
                                    ),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    Text(
                      'Guardian Credentials',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ensure this information is accurate for account recovery and notifications.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Guardian Name
                    CustomTextfield(
                      iconData: const Icon(LucideIcons.user),
                      controller: guardianNameController,
                      label: "Guardian Full Name",
                      hintText: 'Enter guardian name',
                      enabled: !profileProvider.isLoadingTwo,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the guardian name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Contact Number
                    CustomTextfield(
                      iconData: const Icon(LucideIcons.phone),
                      controller: guardianContactController,
                      label: "Login Contact Number",
                      hintText: 'Enter contact phone number',
                      keyBoardtype: TextInputType.phone,
                      enabled: !profileProvider.isLoadingTwo,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter contact phone number';
                        }
                        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length < 7 || digits.length > 15) {
                          return 'Please enter a valid phone number (7-15 digits)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Email Address
                    CustomTextfield(
                      iconData: const Icon(LucideIcons.mail),
                      controller: guardianEmailController,
                      label: "Login Email Address",
                      hintText: 'Enter account email address',
                      keyBoardtype: TextInputType.emailAddress,
                      enabled: !profileProvider.isLoadingTwo,
                      // validator: (value) {
                      //   if (value == null || value.trim().isEmpty) {
                      //     return 'Please enter email address';
                      //   }
                      //   final emailRegex = RegExp(
                      //     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      //   );
                      //   if (!emailRegex.hasMatch(value.trim())) {
                      //     return 'Please enter a valid email address';
                      //   }
                      //   return null;
                      // },
                    ),

                    const SizedBox(height: 48),

                    // Save Button
                    CommonButton(
                      onPressed:
                          profileProvider.isLoadingTwo ? () {} : _onSavePressed,
                      widget:
                          profileProvider.isLoadingTwo
                              ? const ButtonLoading()
                              : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
