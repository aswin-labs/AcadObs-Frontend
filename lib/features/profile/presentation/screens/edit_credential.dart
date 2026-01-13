import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/profile/data/models/guardian_model.dart';
import 'package:acadobs/features/profile/presentation/provider/profile_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class EditCredential extends StatefulWidget {
  const EditCredential({super.key});

  @override
  State<EditCredential> createState() => _EditCredentialState();
}

class _EditCredentialState extends State<EditCredential> {
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
      if (profile != null) {
        setState(() {
          guardianNameController.text = profile.guardianName ?? '';
          guardianContactController.text = profile.guardianContact ?? '';
          guardianEmailController.text = profile.guardianEmail ?? '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Edit Login", isBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These credentials are used for login. Make sure to remember them.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),
            Text(
              'Guardian Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Update the guardian details below',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            CustomTextfield(
              iconData: const Icon(LucideIcons.user),
              controller: guardianNameController,
              label: "Guardian Name",
              hintText: 'Enter guardian name',
              enabled: true,
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              iconData: const Icon(LucideIcons.phone),
              controller: guardianContactController,
              label: "Contact Number",
              hintText: 'Enter contact number',
              enabled: true,
            ),
            const SizedBox(height: 16),

            CustomTextfield(
              iconData: const Icon(LucideIcons.mail),
              controller: guardianEmailController,
              label: "Email",
              hintText: 'Enter email address',
              enabled: true,
            ),

            SizedBox(height: 60),
            CommonButton(
              onPressed: () {
                showConfirmationDialog(
                  context: context,
                  title: "Remember",
                  content:
                      "Updating these details may impact your login information. Are you sure you want to continue?",
                  onConfirm: () {
                    final updatedGuardian = GuardianModel(
                      guardianName: guardianNameController.text.trim(),
                      guardianContact: guardianContactController.text.trim(),
                      guardianEmail: guardianEmailController.text.trim(),
                    );
                    context.read<ProfileProvider>().changeCredentialAndName(
                      context: context,
                      guardian: updatedGuardian,
                    );
                  },
                );
              },
              widget:
                  provider.isLoadingTwo
                      ? ButtonLoading()
                      : Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
