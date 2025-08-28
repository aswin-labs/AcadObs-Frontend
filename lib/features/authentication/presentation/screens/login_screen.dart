import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/authentication/presentation/provider/auth_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: context.paddingHorizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Login",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 48),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "to your account",
                  style: TextStyle(fontSize: 20, color: Color(0xFF3F3F3F)),
                ),
              ),
              SizedBox(height: Responsive.height * 5),

              CustomTextfield(
                hintText: "Username",
                iconData: Icon(Icons.person_outline),
                controller: emailController,
                onTap: null, // No tap event required for username input
                validator: (value) => FormValidator.validateEmail(value),
              ),
              SizedBox(height: Responsive.height * 2),
              CustomTextfield(
                hintText: "Password",
                iconData: Icon(Icons.lock_outline),
                isPasswordField: true,
                controller: passwordController,
                onTap: null, // No tap event required for password input
                validator: (value) => FormValidator.validatePassword(value),
              ),
              SizedBox(height: Responsive.height * 4),
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
                        provider.isLoading ? ButtonLoading() : Text("Login"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
