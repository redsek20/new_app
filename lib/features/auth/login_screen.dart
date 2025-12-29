import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/app_theme.dart';
import '../../core/remote_database_service.dart';
import '../../screens/main_layout.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final RemoteDatabaseService _remoteDb = RemoteDatabaseService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = false;

  final List<String> fashionBackgrounds = [
    'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1600&auto=format&fit=crop&q=80', // Women
    'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?w=1600&auto=format&fit=crop&q=80', // Men
    'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=1600&auto=format&fit=crop&q=80', // Kids
    'https://images.unsplash.com/photo-1532453288672-3a27e9be9efd?w=1600&auto=format&fit=crop&q=80', // Abstract
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) break;
      int next = (_currentPage + 1) % fashionBackgrounds.length;

      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 1000), // Smooth slide
        curve: Curves.easeInOutCubic,
      );
      // Wait for animation to finish
      setState(() {
        _currentPage = next;
      });
    }
    // Note: PageView.builder infinite scroll is complex to do perfectly simply.
    // For "one after one", a simple restart at 0 is jarring.
    // I will use a very large number of pages or simply let it animate.
    // Actually, to make it seamless, I can swap to index 0 instantly?
    // Let's stick to simple forward sliding for now, 0->1->2->3->0(jump).
    // The user just wants "slides one after one".
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Check against real database
    final result = await _remoteDb.login(email, password);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final userData = result['user'];
      final name = userData['name'] ?? email.split('@')[0];

      // Save user session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);
      await prefs.setBool('is_logged_in', true);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Login failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // SLIDING BACKGROUND
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable manual swipe? Or allow it? User said "let pictures slide".
              // Using modulo for "infinite" feeling if I wanted, but here simple list loops.
              itemCount: 1000, // Fake infinite
              itemBuilder: (context, index) {
                final imgIndex = index % fashionBackgrounds.length;
                return Image.network(
                  fashionBackgrounds[imgIndex],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Back Button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2),

                  const SizedBox(height: 40),

                  // Header
                  Text(
                    'Welcome back',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: Colors.white),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  Text(
                    'Sign in to continue your style journey with AI intelligence.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white70),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 40),

                  // Form Fields
                  _buildLabel('Email Address'),
                  const SizedBox(height: 8),
                  _buildGlassTextField(
                    controller: _emailController,
                    hintText: 'hello@stylx.com',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.text,
                  ).animate().fadeIn(delay: 400.ms),
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
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 32),

                  // Login Button
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary))
                      : ElevatedButton(
                          onPressed: _handleLogin,
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
                                'Sign In',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms).scale(),

                  const SizedBox(height: 40),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.2))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Or continue with',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                      Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.2))),
                    ],
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 32),

                  // Social Logins
                  Row(
                    children: [
                      _buildSocialButton(
                          Icons.g_mobiledata, 'Google', _handleGoogleLogin),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                          Icons.apple, 'Apple', _handleAppleLogin),
                    ],
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 40),

                  // Footer
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(
                              text: 'Create account',
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
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildQuickInputChip(String text) {
    return ActionChip(
      label: Text(text),
      side: BorderSide.none,
      backgroundColor: Colors.white.withOpacity(0.1),
      labelStyle: const TextStyle(
        color: Colors.white,
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

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(icon, size: 20, color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: Colors.white70,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(credential);

        // Save local session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', googleUser.email);
        await prefs.setString('user_name', googleUser.displayName ?? 'User');
        await prefs.setBool('is_logged_in', true);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Setup Required'),
            content: Text(
                'To make Google Sign-In work, you must add the SHA-1 fingerprint to your Firebase Console.\n\nError details: $e'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'))
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleLogin() async {
    // Apple Login usually requires the 'sign_in_with_apple' package and iOS capability configuration.
    // For now, we show a setup message.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apple Sign-In Setup'),
        content: const Text(
            'To enable Apple Sign-In, you need to:\n1. Add "sign_in_with_apple" package.\n2. Enable the Capability in Xcode.\n3. Configure it in Firebase Console.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }
}
