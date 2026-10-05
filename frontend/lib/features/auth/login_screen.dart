import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/services/auth_service.dart';
import '../patient/home/user_dashboard.dart';
import '../doctor/home/doctor_dashboard.dart';
import '../admin/home/admin_dashboard.dart';
import 'register_screen.dart';
import '../../core/widgets/responsive_web_container.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../core/widgets/entrance_animation.dart';
import '../../core/theme/page_transitions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await AuthService().login(email, password);
      
      if (!mounted) return;

      if (success) {
        debugPrint('Login: SUCCESS');
        CustomSnackbar.show(context, 'Login Successful');
        
        final role = await AuthService().getRole();
        debugPrint('Login: Role is "$role"');
        if (!mounted) return;

        Widget dashboard;
        if (role == 'DOCTOR') {
          debugPrint('Login: Navigating to DoctorDashboard');
          dashboard = const DoctorDashboard();
        } else if (role == 'ADMIN') {
          debugPrint('Login: Navigating to AdminDashboard');
          dashboard = const AdminDashboard();
        } else {
          debugPrint('Login: Navigating to UserDashboard');
          dashboard = const UserDashboard();
        }

        Navigator.pushReplacement(
          context,
          FadePageRoute(child: dashboard),
        );
      } else {
        CustomSnackbar.show(context, 'Invalid email or password', isError: true);
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
      backgroundColor: AppColors.scaffoldBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 600;

          return ResponsiveWebContainer(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: isWeb 
                  ? Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Container(
                        width: 450,
                        padding: const EdgeInsets.all(40),
                        child: _buildLoginForm(context),
                      ),
                    )
                  : _buildLoginForm(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Center(
            child: EntranceAnimation(
              offset: const Offset(0, 0.2),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_hospital,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          EntranceAnimation(
            delay: const Duration(milliseconds: 100),
            child: Center(
              child: Text(
                'Welcome Back',
                style: AppTextStyles.h1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          EntranceAnimation(
            delay: const Duration(milliseconds: 200),
            child: Center(
              child: Text(
                'Sign in to your account',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Email
          EntranceAnimation(
            delay: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Password
          EntranceAnimation(
            delay: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Password', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          
          // Remember Me & Forgot Password
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Login Button
          EntranceAnimation(
            delay: const Duration(milliseconds: 500),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : PrimaryButton(
                    text: 'Login',
                    onPressed: _handleLogin,
                  ),
          ),
          
          const SizedBox(height: 24),
          
          // Register Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: AppTextStyles.bodyMedium,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    FadePageRoute(child: const RegisterScreen()),
                  );
                },
                child: Text(
                  'Register',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
          
          // Trust Indicator
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_outlined, 
                  size: 16, 
                  color: AppColors.success
                ),
                const SizedBox(width: 8),
                Text(
                  'Your data is 100% encrypted & secure',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
