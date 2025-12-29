import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_theme.dart';
import '../../core/remote_database_service.dart';
import '../../screens/main_layout.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final RemoteDatabaseService _remoteDb = RemoteDatabaseService();

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // simulate a small network delay for "feel"
    await Future.delayed(const Duration(milliseconds: 800));

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text; // hashed in real app

    try {
      // 1. Save Locally (Primary Source of Truth for simple auth)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);
      await prefs.setBool('is_logged_in', true);

      // 2. Sync to Remote (Background / Best Effort)
      _remoteDb.saveUser({
        'email': email,
        'name': name,
        'password': password,
        'last_login': DateTime.now().toIso8601String(),
        'auth_token': 'token_${DateTime.now().millisecondsSinceEpoch}',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        // Success Navigation
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating account: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.2),
                  boxShadow: const [
                    BoxShadow(
                        blurRadius: 100,
                        color: AppTheme.primary,
                        spreadRadius: 10)
                  ]),
            ).animate().scale(duration: 2.seconds, curve: Curves.easeInOut),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(0.15),
                  boxShadow: const [
                    BoxShadow(
                        blurRadius: 80, color: AppTheme.accent, spreadRadius: 5)
                  ]),
            )
                .animate(delay: 1.seconds)
                .scale(duration: 2.seconds, curve: Curves.easeInOut),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.surface,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2),

                    const SizedBox(height: 40),

                    // Header
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displayMedium,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 12),

                    Text(
                      'Join Stylx and start your fashion journey today with your personal AI stylist.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 40),

                    // Form Fields
                    _buildLabel('Full Name'),
                    const SizedBox(height: 8),
                    _buildGlassTextField(
                      controller: _nameController,
                      hintText: 'John Doe',
                      icon: Icons.person_outline_rounded,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Name is required'
                          : null,
                    ),

                    const SizedBox(height: 24),

                    _buildLabel('Email Address'),
                    const SizedBox(height: 8),
                    _buildGlassTextField(
                      controller: _emailController,
                      hintText: 'john@example.com',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.text,
                      validator: (value) => value != null && value.contains('@')
                          ? null
                          : 'Enter a valid email',
                    ),
                    const SizedBox(height: 8),
                    // Quick Input Helper for Emulator Users
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickInputChip('@'),
                          const SizedBox(width: 8),
                          _buildQuickInputChip('@gmail.com'),
                          const SizedBox(width: 8),
                          _buildQuickInputChip('@hotmail.com'),
                          const SizedBox(width: 8),
                          _buildQuickInputChip('.fr'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildLabel('Password'),
                    const SizedBox(height: 8),
                    _buildGlassTextField(
                      controller: _passwordController,
                      hintText: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePassword: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                      validator: (value) => value != null && value.length > 5
                          ? null
                          : 'Password must be 6+ chars',
                    ),

                    const SizedBox(height: 32),

                    // Terms and Conditions
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: true,
                            onChanged: (v) {},
                            activeColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms),

                    const SizedBox(height: 32),

                    // Sign Up Button
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primary))
                        : ElevatedButton(
                            onPressed: _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor: AppTheme.primary.withOpacity(0.5),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppTheme.primaryGradient,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                height: 56,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          )
                            .animate()
                            .fadeIn(delay: 800.ms)
                            .scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 40),

                    // Footer
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color),
                            children: const [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 900.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInputChip(String text) {
    return ActionChip(
      label: Text(text),
      side: BorderSide.none,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.05),
      labelStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: FontWeight.w600,
      ),
      onPressed: () {
        final currentText = _emailController.text;
        final selection = _emailController.selection;

        if (selection.isValid && selection.start >= 0) {
          final newText =
              currentText.replaceRange(selection.start, selection.end, text);
          _emailController.text = newText;
          _emailController.selection =
              TextSelection.collapsed(offset: selection.start + text.length);
        } else {
          _emailController.text = currentText + text;
          _emailController.selection =
              TextSelection.collapsed(offset: _emailController.text.length);
        }
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.1),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          )),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(icon,
              size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
        ),
      ),
    );
  }
}
