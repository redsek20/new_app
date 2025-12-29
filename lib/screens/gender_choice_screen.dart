import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'catalog_screen.dart';

class GenderChoiceScreen extends StatelessWidget {
  const GenderChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              _buildCategoryCard(
                context,
                title: 'MEN',
                subtitle: 'S T R E E T  &  F O R M A L',
                // Detailed, moody fashion shot
                imageUrl:
                    'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?w=800&q=80',
                gender: 'Men',
                delay: 200,
              ),
              _buildCategoryCard(
                context,
                title: 'WOMEN',
                subtitle: 'E L E G A N C E  R E D E F I N E D',
                // High fashion editorial
                imageUrl:
                    'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?w=800&q=80',
                gender: 'Women',
                delay: 400,
              ),
              _buildCategoryCard(
                context,
                title: 'CHILDREN',
                subtitle: 'N E X T  G E N',
                // Cool kid style
                imageUrl:
                    'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=800&q=80',
                gender: 'Children',
                delay: 600,
                imageAlignment: Alignment.center, // Adjusted alignment
              ),
            ],
          ),

          // Conditional Back Button
          if (Navigator.canPop(context))
            Positioned(
              top: 60,
              left: 24,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ).animate().fadeIn(delay: 800.ms),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imageUrl,
    required String gender,
    required int delay,
    AlignmentGeometry imageAlignment = Alignment.topCenter,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) =>
                  CatalogScreen(initialGender: gender),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white12, width: 1),
            ),
          ),
          child: Stack(
            children: [
              // 1. Background Image with Parallax-like feel (static fit cover is handled by standard Image)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  alignment:
                      imageAlignment as Alignment? ?? Alignment.topCenter,
                  placeholder: (c, u) => Container(color: Colors.black26),
                  errorWidget: (c, u, e) => Container(color: Colors.grey[900]),
                ).animate().fadeIn(duration: 800.ms),
              ),

              // 2. Gradient Overlay for Text Readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Text Content
              Positioned(
                bottom: 40,
                left: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Didot', // Or serif default
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        height: 0.9,
                      ),
                    )
                        .animate(delay: delay.ms)
                        .slideX(begin: -0.2, end: 0, duration: 600.ms)
                        .fadeIn(),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    )
                        .animate(delay: (delay + 100).ms)
                        .slideX(begin: -0.2, end: 0, duration: 600.ms)
                        .fadeIn(),
                  ],
                ),
              ),

              // 4. Interactive Arrow
              Positioned(
                bottom: 40,
                right: 30,
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 30,
                )
                    .animate(delay: (delay + 300).ms)
                    .fadeIn()
                    .moveX(begin: -10, end: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
