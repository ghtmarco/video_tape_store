import 'package:flutter/material.dart';
import 'package:video_tape_store/utils/constants.dart';
import 'package:video_tape_store/widgets/custom_button.dart';
import 'package:video_tape_store/widgets/custom_textfield.dart';
import 'package:video_tape_store/pages/auth/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptedTerms = false;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      _showErrorDialog('Please accept the Terms and Conditions');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceColor,
            title: const Text('Success!'),
            content: const Text('Your account has been created successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Login Now'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up Error'),
        content: Text(message),
        backgroundColor: AppColors.surfaceColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          AppStrings.signup,
          style: AppTextStyles.headingMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create your account',
                  style: AppTextStyles.headingLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.marginSmall),
                const Text(
                  'Please fill in the form to continue',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.marginLarge * 2),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  validator: _validateName,
                ),
                const SizedBox(height: AppDimensions.marginMedium),
                CustomTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: 'Enter your email',
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppDimensions.marginMedium),
                CustomTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  hint: 'Create a password',
                  isPassword: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: AppDimensions.marginMedium),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: AppStrings.confirmPassword,
                  hint: 'Confirm your password',
                  isPassword: true,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: AppDimensions.marginLarge),
                CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
                  title: const Text(
                    'I accept the Terms and Conditions',
                    style: AppTextStyles.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primaryColor,
                  checkColor: Colors.white,
                ),
                const SizedBox(height: AppDimensions.marginLarge),
                CustomButton(
                  onPressed: _handleSignUp,
                  text: AppStrings.signup,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppDimensions.marginLarge),
                const Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.dividerColor),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMedium,
                      ),
                      child: Text(
                        'Or sign up with',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppColors.dividerColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.marginLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialSignUpButton(
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Google',
                      onTap: () {},
                    ),
                    const SizedBox(width: AppDimensions.marginLarge),
                    _SocialSignUpButton(
                      icon: Icons.apple,
                      label: 'Apple',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.marginLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: AppTextStyles.bodySmall,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        AppStrings.login,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialSignUpButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialSignUpButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryTextColor),
            const SizedBox(width: AppDimensions.marginSmall),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
