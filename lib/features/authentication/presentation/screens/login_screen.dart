import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
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

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = context.paddingHorizontal.horizontal / 2;

    return Scaffold(
      backgroundColor: tBackgroundColor,
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/logo.png'),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Welcome to  Acadobs',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const Text(
                    'Login to your account',
                    style: TextStyle(fontSize: 14, color: tSecondaryTextColor),
                  ),
                  SizedBox(height: Responsive.height * 5),
                  Container(
                    width: Responsive.isMobilePortrait ? double.infinity : 450,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: BoxBorder.all(color: Colors.grey),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
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

                          // --- Email/ID Field ---
                          CustomTextfield(
                            hintText: "Email ID",
                            iconData: const Icon(
                              Icons.person_outline,
                              color: tSecondaryTextColor,
                            ),
                            controller: emailController,
                            keyBoardtype: TextInputType.emailAddress,
                            validator:
                                (value) => FormValidator.validateEmail(value),
                          ),
                          SizedBox(height: Responsive.height * 2),

                          // --- Password Field ---
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
                          SizedBox(height: Responsive.height * 3),

                          // --- Login Button ---
                          Consumer<AuthProvider>(
                            builder: (context, provider, _) {
                              return CommonButton(
                                onPressed:
                                    () => context.read<AuthProvider>().login(
                                      context: context,
                                      email: emailController.text,
                                      password: passwordController.text,
                                    ),
                                widget:
                                    provider.isLoading
                                        ? ButtonLoading()
                                        : Text("Login"),
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
