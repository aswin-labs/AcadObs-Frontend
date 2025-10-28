import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/parents/presentation/provider/parent_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ParentProvider>();
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    await provider.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    if (!mounted) return;
    context.pop();

    CustomSnackbar.show(
      context,
      message: "Password changed successfully",
      type: SnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CommonAppBar(title: "Change Password", isBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            // Header Section
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6366F1).withAlpha(60),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Old Password
                    const Text(
                      "Current Password",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CommonTextField(
                      hintText: "Enter your current password",
                      controller: oldPasswordController,
                      isPassword: true,
                      isPasswordVisible: _isOldPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isOldPasswordVisible = !_isOldPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // New Password
                    const Text(
                      "New Password",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CommonTextField(
                      hintText: "Enter your new password",
                      controller: newPasswordController,
                      isPassword: true,
                      isPasswordVisible: _isNewPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (value == oldPasswordController.text) {
                          return 'New password must be different from current';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password
                    const Text(
                      "Confirm New Password",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CommonTextField(
                      hintText: "Re-enter your new password",
                      controller: confirmPasswordController,
                      isPassword: true,
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Change Password Button
                    SizedBox(
                      width: double.infinity,
                      child: CommonButton(
                        onPressed: _onChangePassword,
                        widget: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Change Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommonTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final String? Function(String?)? validator;

  const CommonTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onVisibilityToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(
          isPassword ? Icons.lock_outline : Icons.person_outline,
          color: const Color(0xFF6366F1),
        ),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: onVisibilityToggle,
                )
                : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
      ),
    );
  }
}

// import 'package:acadobs/features/parents/presentation/provider/parent_provider.dart';
// import 'package:acadobs/shared/widgets/common_appbar.dart';
// import 'package:acadobs/shared/widgets/common_button.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ChangePassword extends StatefulWidget {
//   const ChangePassword({super.key});

//   @override
//   State<ChangePassword> createState() => _ChangePasswordState();
// }

// class _ChangePasswordState extends State<ChangePassword> {
//   final oldPasswordController = TextEditingController();
//   final newPasswordController = TextEditingController();

//   @override
//   void dispose() {
//     oldPasswordController.dispose();
//     newPasswordController.dispose();
//     super.dispose();
//   }

//   void _onChangePassword() {
//     final provider = context.read<ParentProvider>();

//     final oldPassword = oldPasswordController.text.trim();
//     final newPassword = newPasswordController.text.trim();

//     if (oldPassword.isEmpty || newPassword.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
//       return;
//     }

//     provider.changePassword(oldPassword: oldPassword, newPassword: newPassword);

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Password changed successfully")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(title: "Reset Password", isBackButton: true),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "old password:",
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//             ),
//             CommonTextField(
//               hintText: "old password",
//               controller: oldPasswordController,
//             ),
//             SizedBox(height: 20),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "New password:",
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//             ),
//             CommonTextField(
//               hintText: "New password",
//               controller: newPasswordController,
//             ),

//             SizedBox(height: 30),
//             CommonButton(
//               onPressed: _onChangePassword,
//               widget: Text("Reset Password"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CommonTextField extends StatelessWidget {
//   final String hintText;
//   final TextEditingController controller;
//   const CommonTextField({
//     super.key,
//     required this.hintText,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//         hintText: hintText,
//       ),
//     );
//   }
// }
