import 'dart:async';

import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/features/authentication/presentation/provider/auth_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

const Color _tPrimaryColor = Color(0xFF00AEF0);
const Color _tTealColor = Color(0xFF35C2C1);
const Color _tSecondaryTextColor = Color(0xFF757575);
const Color _tBackgroundColor = Color(0xFFF4F6F9);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Step tracking: 1 = Phone, 2 = Verify OTP, 3 = Reset Password, 4 = Success
  int _currentStep = 1;

  // Form Keys
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // OTP Timer
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().resetForgotPasswordState();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = 60;
      _canResendOtp = false;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResendOtp = true;
          _resendCountdown = 0;
        });
      }
    });
  }

  double _cardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return double.infinity;
    if (width < 1024) return 420;
    return 460;
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 16;
    if (width < 1024) return 48;
    return 120;
  }

  // Action: Step 1 - Send OTP
  Future<void> _handleSendOtp() async {
    FocusScope.of(context).unfocus();
    if (!_phoneFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final phone = _phoneController.text.trim();

    final success = await authProvider.forgetPassword(
      context: context,
      phone: phone,
    );

    if (success && mounted) {
      authProvider.clearForgotPasswordError();
      _otpController.clear();
      _startResendTimer();
      setState(() {
        _currentStep = 2;
      });
    }
  }

  // Action: Step 2 - Resend OTP
  Future<void> _handleResendOtp() async {
    if (!_canResendOtp) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final phone = _phoneController.text.trim();

    final success = await authProvider.resendOtp(
      context: context,
      phone: phone,
    );

    if (success && mounted) {
      _otpController.clear();
      _startResendTimer();
    }
  }

  // Action: Step 2 - Verify OTP
  Future<void> _handleVerifyOtp() async {
    FocusScope.of(context).unfocus();
    if (!_otpFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    final success = await authProvider.verifyOtp(
      context: context,
      phone: phone,
      otp: otp,
    );

    if (success && mounted) {
      authProvider.clearForgotPasswordError();
      setState(() {
        _currentStep = 3;
      });
    }
  }

  // Action: Step 3 - Reset Password
  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();
    if (!_passwordFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final newPassword = _newPasswordController.text;

    final success = await authProvider.resetPassword(
      context: context,
      newPassword: newPassword,
    );

    if (success && mounted) {
      authProvider.clearForgotPasswordError();
      setState(() {
        _currentStep = 4; // Success step
      });
    }
  }

  void _handleBack() {
    context.read<AuthProvider>().clearForgotPasswordError();
    if (_currentStep == 1 || _currentStep == 4) {
      context.pop();
    } else if (_currentStep == 2) {
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 3) {
      setState(() {
        _currentStep = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return PopScope(
      canPop: _currentStep == 1 || _currentStep == 4,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: _tBackgroundColor,
          body: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset('assets/background.png', fit: BoxFit.cover),
              ),

              // Main Content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: _horizontalPadding(context),
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header Bar with Back Button & Branding
                        SizedBox(
                          width: _cardWidth(context),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _handleBack,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 1,
                                  shadowColor: Colors.black12,
                                  padding: const EdgeInsets.all(8),
                                ),
                                icon: const Icon(
                                  LucideIcons.arrowLeft,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Image.asset(
                                'assets/logo.png',
                                width: 36,
                                height: 36,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Acadobs',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(width: 40), // Balance back button
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Form Card
                        Container(
                          width: _cardWidth(context),
                          padding: EdgeInsets.all(isMobile ? 20 : 28),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(245),
                            borderRadius: BorderRadius.circular(24),
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
                              final isLoading =
                                  provider.isForgotPasswordLoading;
                              final error = provider.forgotPasswordError;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Stepper Indicator (shown on steps 1, 2, 3)
                                  if (_currentStep < 4) ...[
                                    _buildStepper(),
                                    const SizedBox(height: 22),
                                  ],

                                  // Error Banner
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    child:
                                        error != null && _currentStep < 4
                                            ? Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 18,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFFF1F2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFFECDD3,
                                                    ),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFE11D48,
                                                      ).withAlpha(12),
                                                      blurRadius: 10,
                                                      offset: const Offset(
                                                        0,
                                                        3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFFFE4E6,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        LucideIcons.circleAlert,
                                                        color: Color(
                                                          0xFFE11D48,
                                                        ),
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            switch (_currentStep) {
                                                              1 =>
                                                                "Couldn't Send Code",
                                                              2 =>
                                                                "Verification Failed",
                                                              _ =>
                                                                "Password Reset Failed",
                                                            },
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Color(
                                                                    0xFF9F1239,
                                                                  ),
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            error,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize:
                                                                      12.5,
                                                                  color: Color(
                                                                    0xFFBE123C,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  height: 1.35,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      onTap:
                                                          provider
                                                              .clearForgotPasswordError,
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(
                                                          4,
                                                        ),
                                                        child: Icon(
                                                          LucideIcons.x,
                                                          size: 15,
                                                          color: Color(
                                                            0xFF9F1239,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            : const SizedBox.shrink(),
                                  ),

                                  // Step Content
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: switch (_currentStep) {
                                      1 => _buildPhoneStep(isLoading, provider),
                                      2 => _buildOtpStep(isLoading, provider),
                                      3 => _buildPasswordStep(
                                        isLoading,
                                        provider,
                                      ),
                                      _ => _buildSuccessStep(),
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Back to Sign In Link
                        if (_currentStep < 4)
                          TextButton.icon(
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              LucideIcons.logIn,
                              size: 16,
                              color: _tSecondaryTextColor,
                            ),
                            label: const Text(
                              "Return to Login",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _tSecondaryTextColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== STEPPER WIDGET =====================
  Widget _buildStepper() {
    return Row(
      children: [
        _buildStepIndicator(
          step: 1,
          title: "Phone",
          isActive: _currentStep >= 1,
          isDone: _currentStep > 1,
        ),
        _buildStepLine(_currentStep > 1),
        _buildStepIndicator(
          step: 2,
          title: "Verify",
          isActive: _currentStep >= 2,
          isDone: _currentStep > 2,
        ),
        _buildStepLine(_currentStep > 2),
        _buildStepIndicator(
          step: 3,
          title: "Password",
          isActive: _currentStep >= 3,
          isDone: _currentStep > 3,
        ),
      ],
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required String title,
    required bool isActive,
    required bool isDone,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient:
                isActive
                    ? const LinearGradient(
                      colors: [_tTealColor, _tPrimaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: isActive ? null : Colors.grey.shade200,
            shape: BoxShape.circle,
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: _tPrimaryColor.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child:
                isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                      "$step",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        decoration: BoxDecoration(
          color: isCompleted ? _tPrimaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  // ===================== STEP 1: PHONE =====================
  Widget _buildPhoneStep(bool isLoading, AuthProvider provider) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Icon & Text
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _tPrimaryColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.keyRound,
                size: 32,
                color: _tPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Forgot Password",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Enter your registered 10-digit mobile number. We will send a verification OTP to verify your identity.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _tSecondaryTextColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Phone Number Field
          CustomTextfield(
            hintText: "Enter 10-digit phone number",
            label: "Phone Number",
            enabled: !isLoading,
            keyBoardtype: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSendOtp(),
            iconData: const Icon(
              Icons.phone_android_rounded,
              color: _tSecondaryTextColor,
            ),
            controller: _phoneController,
            onChanged: (_) {
              if (provider.forgotPasswordError != null) {
                provider.clearForgotPasswordError();
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter your phone number";
              }
              final clean = value.trim();
              if (clean.length != 10 || int.tryParse(clean) == null) {
                return "Phone number must be exactly 10 digits";
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Send OTP Button
          CommonButton(
            onPressed: isLoading ? null : _handleSendOtp,
            backgroundColor: _tPrimaryColor,
            widget:
                isLoading
                    ? const ButtonLoading()
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Send Verification Code",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          LucideIcons.arrowRight,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  // ===================== STEP 2: VERIFY OTP =====================
  Widget _buildOtpStep(bool isLoading, AuthProvider provider) {
    final phone = _phoneController.text.trim();

    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Icon & Text
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _tPrimaryColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.shieldCheck,
                size: 32,
                color: _tPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Verify OTP",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  "Code sent to +91 $phone",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _tSecondaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  provider.clearForgotPasswordError();
                  setState(() {
                    _currentStep = 1;
                  });
                },
                child: const Text(
                  "Edit",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _tPrimaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // OTP Input Field
          TextFormField(
            controller: _otpController,
            enabled: !isLoading,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 14,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              counterText: "",
              hintText: "••••••",
              hintStyle: TextStyle(
                fontSize: 24,
                letterSpacing: 14,
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _tPrimaryColor, width: 2),
              ),
            ),
            onChanged: (val) {
              if (provider.forgotPasswordError != null) {
                provider.clearForgotPasswordError();
              }
              if (val.trim().length == 6) {
                _handleVerifyOtp();
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter the 6-digit OTP code";
              }
              if (value.trim().length != 6) {
                return "Please enter all 6 digits";
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Resend Timer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_canResendOtp) ...[
                const Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: _tSecondaryTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  "Resend code in ${_resendCountdown.toString().padLeft(2, '0')}s",
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: _tSecondaryTextColor,
                  ),
                ),
              ] else ...[
                const Text(
                  "Didn't receive the code? ",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _tSecondaryTextColor,
                  ),
                ),
                GestureDetector(
                  onTap: isLoading ? null : _handleResendOtp,
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: _tPrimaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Verify Button
          CommonButton(
            onPressed: isLoading ? null : _handleVerifyOtp,
            backgroundColor: _tPrimaryColor,
            widget:
                isLoading
                    ? const ButtonLoading()
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Verify Code",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          LucideIcons.checkCheck,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  // ===================== STEP 3: RESET PASSWORD =====================
  Widget _buildPasswordStep(bool isLoading, AuthProvider provider) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Icon & Text
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _tPrimaryColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.lockKeyhole,
                size: 32,
                color: _tPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Set New Password",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Create a new password that is at least 4 characters long.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _tSecondaryTextColor,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 22),

          // New Password Field
          CustomTextfield(
            hintText: "Enter new password",
            label: "New Password",
            enabled: !isLoading,
            isPasswordField: true,
            textInputAction: TextInputAction.next,
            iconData: const Icon(
              Icons.lock_outline,
              color: _tSecondaryTextColor,
            ),
            controller: _newPasswordController,
            onChanged: (_) {
              if (provider.forgotPasswordError != null) {
                provider.clearForgotPasswordError();
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter a new password";
              }
              if (value.length < 4) {
                return "Password must be at least 4 characters";
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Confirm Password Field
          CustomTextfield(
            hintText: "Confirm new password",
            label: "Confirm Password",
            enabled: !isLoading,
            isPasswordField: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleResetPassword(),
            iconData: const Icon(
              Icons.lock_reset_rounded,
              color: _tSecondaryTextColor,
            ),
            controller: _confirmPasswordController,
            onChanged: (_) {
              if (provider.forgotPasswordError != null) {
                provider.clearForgotPasswordError();
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please confirm your password";
              }
              if (value != _newPasswordController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Submit Reset Button
          CommonButton(
            onPressed: isLoading ? null : _handleResetPassword,
            backgroundColor: _tPrimaryColor,
            widget:
                isLoading
                    ? const ButtonLoading()
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          LucideIcons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  // ===================== STEP 4: SUCCESS =====================
  Widget _buildSuccessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withAlpha(80),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "Password Reset Complete!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your password has been changed successfully. You can now sign in using your new password.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: _tSecondaryTextColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        CommonButton(
          onPressed: () {
            context.pop(); // Returns to login screen
          },
          backgroundColor: _tPrimaryColor,
          widget: const Text(
            "Back to Login",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
