import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/authentication/presentation/provider/auth_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Color tSecondaryTextColor = Color(0xFF757575);
const Color tBackgroundColor = Color(0xFFF4F6F9);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  double _cardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return double.infinity; // Mobile
    if (width < 1024) return 420; // Tablet
    return 460; // Web/Desktop
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 16;
    if (width < 1024) return 48;
    return 120;
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      context: context,
      identifier: identifierController.text.trim(),
      password: passwordController.text,
    );

    if (!success && mounted) {
      final errorMsg = authProvider.loginError;
      if (errorMsg != null && errorMsg.isNotEmpty) {
        CustomSnackbar.show(
          context,
          message: errorMsg,
          type: SnackbarType.failure,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: tBackgroundColor,
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset('assets/background.png', fit: BoxFit.cover),
            ),

            // Login Form
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: _horizontalPadding(context),
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Image.asset('assets/logo.png'),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Welcome to Acadobs',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Sign in to access your dashboard',
                      style: TextStyle(
                        fontSize: 14,
                        color: tSecondaryTextColor,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Card
                    Container(
                      width: _cardWidth(context),
                      padding: EdgeInsets.all(isMobile ? 20 : 28),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(245),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(16),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Consumer<AuthProvider>(
                        builder: (context, provider, _) {
                          final isLoading = provider.isLoading;
                          final loginError = provider.loginError;

                          return Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header Title & Roles info
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Account Login',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                // Supported roles badge
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF00AEF0,
                                      ).withAlpha(20),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Parents • Teachers • Staff',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF00AEF0),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Inline Error Message Banner
                                if (loginError != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFFCA5A5),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          color: Color(0xFFDC2626),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            loginError,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFFB91C1C),
                                              fontWeight: FontWeight.w500,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap:
                                              () => provider.clearLoginError(),
                                          child: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Color(0xFF991B1B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Identifier Field (Phone number or username)
                                CustomTextfield(
                                  hintText: "Phone number or Username",
                                  label: "Phone / Username",
                                  enabled: !isLoading,
                                  keyBoardtype: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  iconData: const Icon(
                                    Icons.person_outline,
                                    color: tSecondaryTextColor,
                                  ),
                                  controller: identifierController,
                                  onChanged: (_) {
                                    if (provider.loginError != null) {
                                      provider.clearLoginError();
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please enter your phone number or username";
                                    }
                                    if (value.trim().length < 3) {
                                      return "Identifier must be at least 3 characters";
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Password Field
                                CustomTextfield(
                                  hintText: "Password",
                                  label: "Password",
                                  enabled: !isLoading,
                                  isPasswordField: true,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submitLogin(),
                                  iconData: const Icon(
                                    Icons.lock_outline,
                                    color: tSecondaryTextColor,
                                  ),
                                  controller: passwordController,
                                  onChanged: (_) {
                                    if (provider.loginError != null) {
                                      provider.clearLoginError();
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please enter your password";
                                    }
                                    if (value.length < 4) {
                                      return "Password must be at least 4 characters";
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Login Button
                                CommonButton(
                                  onPressed: isLoading ? null : _submitLogin,
                                  widget:
                                      isLoading
                                          ? const ButtonLoading()
                                          : const Text(
                                            "Login",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),

                                const SizedBox(height: 16),

                                // Help note
                                Center(
                                  child: Text(
                                    'Need help signing in? Contact school admin',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
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
