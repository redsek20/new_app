import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_theme.dart';
import '../features/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Curate Your\nStyle Destiny',
      description:
          'AI-driven fashion discovery that understands your unique aesthetic and body type.',
      image:
          'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=1080&auto=format&fit=crop&q=82',
      color: AppTheme.primary,
    ),
    OnboardingData(
      title: 'Smart Wardrobe\nIntelligence',
      description:
          'Organize your closet with machine learning and get daily outfit inspirations.',
      image:
          'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=1080&auto=format&fit=crop&q=82',
      color: AppTheme.accent,
    ),
    OnboardingData(
      title: 'Virtual AR\nFitting Room',
      description:
          'Experience fashion in 3D. Try on clothes virtually before they even arrive.',
      image:
          'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=1080&auto=format&fit=crop&q=82',
      color: AppTheme.secondary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          AnimatedContainer(
            duration: 800.ms,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _pages[_currentPage].color.withOpacity(0.2),
                  AppTheme.background,
                  AppTheme.background,
                ],
              ),
            ),
          ),

          // Main Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return OnboardingPageWidget(
                data: page,
                isActive: _currentPage == index,
              );
            },
          ),

          // Top Navigation
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'STYLX',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          const Shadow(
                              color: Colors.black54,
                              blurRadius: 4.0,
                              offset: Offset(1, 1))
                        ],
                      ),
                    ),
                  ],
                ),
                // Skip Button
                TextButton(
                  onPressed: () => _navigateToLogin(context),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicators
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: 300.ms,
                          margin: const EdgeInsets.only(right: 8),
                          height: 6,
                          width: _currentPage == index ? 24 : 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? _pages[_currentPage].color
                                : AppTheme.textSecondary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),

                    // Next Button
                    GestureDetector(
                      onTap: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: 600.ms,
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _navigateToLogin(context);
                        }
                      },
                      child: Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: _pages[_currentPage].color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  _pages[_currentPage].color.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.check
                              : Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingData data;
  final bool isActive;

  const OnboardingPageWidget({
    super.key,
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Creative Image Card
          Center(
            child: Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: data.color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: data.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              data.color.withOpacity(0.3),
                              data.color.withOpacity(0.6),
                              data.color,
                            ],
                          ),
                        ),
                        child: Icon(
                          _getIconForPage(),
                          size: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              data.color.withOpacity(0.3),
                              data.color.withOpacity(0.6),
                              data.color,
                            ],
                          ),
                        ),
                        child: Icon(
                          _getIconForPage(),
                          size: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                    // Gradient Overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(target: isActive ? 1 : 0)
                .scale(
                    begin: const Offset(0.9, 0.9),
                    curve: Curves.easeOut,
                    duration: 400.ms)
                .fadeIn(),
          ),
          const SizedBox(height: 60),
          // Title
          Text(
            data.title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              shadows: [
                const Shadow(
                    color: Colors.black54,
                    blurRadius: 4.0,
                    offset: Offset(1, 1))
              ],
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 200.ms)
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 20),
          // Description
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              shadows: [
                const Shadow(
                    color: Colors.black54,
                    blurRadius: 4.0,
                    offset: Offset(1, 1))
              ],
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  IconData _getIconForPage() {
    // Return different icons based on the page title
    if (data.title.contains('Style')) {
      return Icons.auto_awesome;
    } else if (data.title.contains('Wardrobe')) {
      return Icons.checkroom_rounded;
    } else {
      return Icons.view_in_ar_rounded;
    }
  }
}
