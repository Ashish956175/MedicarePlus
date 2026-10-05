import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/custom_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  String _selectedRole = 'USER'; // Default
  bool _isLoading = false;
  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0;
    if (password.length > 6) strength += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.3;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.4;
    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
    });
  }

  Color _getStrengthColor() {
    if (_passwordStrength < 0.3) return AppColors.error;
    if (_passwordStrength < 0.7) return AppColors.warning;
    return AppColors.success;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await AuthService().register(
        name, 
        email, 
        password, 
        _selectedRole
      );

      if (!mounted) return;

      if (success) {
        CustomSnackbar.show(context, 'Registration Successful! Please Login.');
        Navigator.pop(context);
      } else {
        CustomSnackbar.show(context, 'Registration Failed', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(context, 'An error occurred: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 32),
                
                // Name
                Text('Full Name', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 24),
                
                // Email
                Text('Email', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => !value!.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 24),
                
                // Password
                Text('Password', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) => value!.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 8),
                
                // Password Strength Indicator
                if (_passwordController.text.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: _passwordStrength,
                        backgroundColor: AppColors.grey200,
                        color: _getStrengthColor(),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _passwordStrength < 0.3 ? 'Weak' : _passwordStrength < 0.7 ? 'Medium' : 'Strong',
                        style: AppTextStyles.caption.copyWith(
                          color: _getStrengthColor(),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),
                
                // Role Selector
                Text('I am a', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleSelector('USER', 'Patient'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildRoleSelector('DOCTOR', 'Doctor'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Register Button
                _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : PrimaryButton(
                  text: 'Register',
                  onPressed: _handleRegister,
                ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        'Encrypted & Secure Registration',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(String role, String label) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
