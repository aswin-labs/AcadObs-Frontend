import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/logo.png'),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Welcome to Acadobs',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Login to your account',
                    style: TextStyle(fontSize: 14, color: tSecondaryTextColor),
                  ),

                  const SizedBox(height: 32),

                  // Card
                  Container(
                    width: _cardWidth(context),
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(243),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(21),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Secure Login',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Email
                          CustomTextfield(
                            hintText: "Username",
                            iconData: const Icon(
                              Icons.person_outline,
                              color: tSecondaryTextColor,
                            ),
                            controller: emailController,
                          ),

                          const SizedBox(height: 16),

                          // Password
                          CustomTextfield(
                            hintText: "Password",
                            iconData: const Icon(
                              Icons.lock_outline,
                              color: tSecondaryTextColor,
                            ),
                            isPasswordField: true,
                            controller: passwordController,
                            validator:
                                (value) =>
                                    FormValidator.validatePassword(value),
                          ),

                          const SizedBox(height: 24),

                          // Login Button
                          Consumer<AuthProvider>(
                            builder: (context, provider, _) {
                              final loginError = provider.loginError;

                              if (loginError != null) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!context.mounted) return;

                                  CustomSnackbar.show(
                                    context,
                                    message: loginError,
                                    type: SnackbarType.failure,
                                  );

                                  context
                                      .read<AuthProvider>()
                                      .clearLoginError();
                                });
                              }

                              return CommonButton(
                                onPressed:
                                    provider.isLoading
                                        ? null
                                        : () {
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            return;
                                          }

                                          context.read<AuthProvider>().login(
                                            context: context,
                                            identifier:
                                                emailController.text.trim(),
                                            password: passwordController.text,
                                          );
                                        },
                                widget:
                                    provider.isLoading
                                        ? const ButtonLoading()
                                        : const Text("Login"),
                              );
                            },
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
