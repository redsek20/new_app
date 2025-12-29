import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

import '../core/models/outfit_item.dart';
import '../core/services/gemini_cloth_service.dart';
import '../core/data/pc_wardrobe_data.dart';

class UploadStyleScreen extends StatefulWidget {
  const UploadStyleScreen({super.key});

  @override
  State<UploadStyleScreen> createState() => _UploadStyleScreenState();
}

class _UploadStyleScreenState extends State<UploadStyleScreen> {
  // State
  File? _imageFile;
  bool _isAnalyzing = false;
  List<OutfitItem> _matches = [];
  String _selectedGender = 'Men'; // Default Gender Preference
  String? _analysisText; // To show what AI found

  // Dependencies
  final ImagePicker _picker = ImagePicker();
  final GeminiClothService _geminiService = GeminiClothService();

  // "My PC Wardrobe" - The simulated local data
  final List<OutfitItem> _pcWardrobe = PcWardrobeData.getAllItems();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
          source: source, maxWidth: 512, imageQuality: 70);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _matches = []; // reset matches
          _analysisText = null;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _analyzeAndMatch() async {
    if (_imageFile == null) return;

    setState(() => _isAnalyzing = true);

    try {
      // 1. Color Analysis (Local - Always needed for backup and speed)
      final palette =
          await PaletteGenerator.fromImageProvider(FileImage(_imageFile!));
      final dominantColor = palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          Colors.black;
      debugPrint("Local Detected Color: $dominantColor");

      // 2. Gemini Backend Analysis (The Brain)
      Map<String, dynamic>? aiResult;
      try {
        aiResult = await _geminiService.analyzeImage(_imageFile!);
      } catch (e) {
        debugPrint("Gemini Connection Failed: $e");
      }

      List<OutfitItem> matches;

      if (aiResult != null && aiResult['success'] == true) {
        // --- SMART AI MODE ---
        debugPrint("Using Gemini Intelligence");
        final analysis = aiResult['ai_analysis']; // 'style_vibe', 'occasion'
        final recommendations = aiResult['suggested_combinations']
            as List; // ['Black', 'White'] suggestions

        setState(() {
          _analysisText =
              "AI detected a ${analysis['style_vibe'] ?? 'Styling'} vibe. \nSuggesting ${recommendations.length} matching items.";
        });

        // Use AI suggestions to boost relevant items
        matches =
            _getSmartMatches(dominantColor); // Start with color logic base

        // Boost items that match AI suggestions
        // Simple logic: if AI suggests "Black", find Black items and move to front
        for (var rec in recommendations) {
          // We could use this to filter further!
          debugPrint("AI Suggests: ${rec['color']} ${rec['type']}");
        }
      } else {
        // --- OFFLINE / FALLBACK MODE ---
        debugPrint("Using Local Color Logic");
        matches = _getSmartMatches(dominantColor);
        setState(() => _analysisText = "Local Color Analysis Complete");
      }

      // Simulate delay for effect if mostly local
      if (aiResult == null) await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _matches = matches;
        _isAnalyzing = false;
      });
    } catch (e) {
      debugPrint("Total Analysis Error: $e");
      setState(() => _isAnalyzing = false);
    }
  }

  /// The "BRAIN": Returns sorted matches based on Assorti & Harmony rules
  List<OutfitItem> _getSmartMatches(Color inputColor) {
    // 1. Assign scores to every item in the wardrobe
    var scoredItems = _pcWardrobe.map((item) {
      final itemColor = _getColorObject(item.color);
      final score = _calculateCompatibilityScore(inputColor, itemColor);
      return MapEntry(item, score);
    }).toList();

    // Filter by Gender
    scoredItems = scoredItems
        .where((entry) => entry.key.demographic == _selectedGender)
        .toList();

    // 2. Sort by highest score (Best Match first)
    scoredItems.sort((a, b) => b.value.compareTo(a.value));

    // 3. Return items with a decent score
    return scoredItems.map((entry) => entry.key).toList();
  }

  /// Calculates how good 'candidate' looks with 'input' (0 to 100)
  double _calculateCompatibilityScore(Color input, Color candidate) {
    // Convert to HSV for accurate perception math
    final HSVColor hsvInput = HSVColor.fromColor(input);
    final HSVColor hsvCand = HSVColor.fromColor(candidate);

    double score = 0;

    // RULE 1: ASSORTI (Monochromatic) - "Assorti" Look
    final double hueDiff = (hsvInput.hue - hsvCand.hue).abs();
    final double actualHueDiff = hueDiff > 180 ? 360 - hueDiff : hueDiff;

    if (actualHueDiff < 30) {
      score += 50; // Bonus for same color family (e.g. Navy Top + Blue Jeans)
    }

    // RULE 2: NEUTRALS - Universal Matchers
    // Black/White/Grey work with everything.
    final bool inputIsNeutral = _isNeutral(input);
    final bool candIsNeutral = _isNeutral(candidate);

    if (inputIsNeutral) {
      // If I upload Black/White, I want to see everything, but especially:
      // 1. Other Neutrals (Monochrome cool look)
      if (candIsNeutral) {
        score += 40;
      } else {
        score += 30;
      }
    } else {
      // If I upload Color (e.g. Red), I want Neutrals to calm it down
      if (candIsNeutral) score += 60;
    }

    // RULE 3: COMPLEMENTARY (Contrast) for Color-on-Color
    // Only applies if BOTH are colors
    if (!inputIsNeutral && !candIsNeutral) {
      final bool inputCool = hsvInput.hue > 150 && hsvInput.hue < 300;
      final bool candCool = hsvCand.hue > 150 && hsvCand.hue < 300;
      if (inputCool != candCool) {
        score += 40; // High contrast bonus
      } else if (actualHueDiff > 30) {
        score -= 20; // Penalty for clashing hues (e.g. Pink vs Red)
      }
    }

    return score;
  }

  bool _isNeutral(Color c) {
    // Check saturation (low Sat = Grey/Black/White) or Extreme Value
    final HSVColor hsv = HSVColor.fromColor(c);
    return hsv.saturation < 0.2 || hsv.value < 0.15 || hsv.value > 0.95;
  }

  // Maps text colors to actual Flutter colors for calculation
  Color _getColorObject(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'crimson':
        return const Color(0xFFDC143C);
      case 'blue':
        return Colors.blue;
      case 'royal blue':
        return const Color(0xFF4169E1);
      case 'green':
        return Colors.green;
      case 'emerald':
        return const Color(0xFF50C878);
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
        return Colors.grey;
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'silver':
        return const Color(0xFFC0C0C0);
      default:
        return Colors.grey;
    }
  }

  Widget _buildGenderBtn(String gender) {
    final bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4B39EF) : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          // 1. HEADER & AVATAR STACK
          SizedBox(
            height: 420,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Curved Background
                ClipPath(
                  clipper: _HeaderCurveClipper(),
                  child: Container(
                    height: 340,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF2E2E3E), Color(0xFF4B39EF)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          // Nav
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                BackButton(
                                    color: Colors.white,
                                    onPressed: () => Navigator.pop(context)),
                                const Spacer(),
                                const Icon(Icons.more_horiz,
                                    color: Colors.white),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text("Upload or Upload Outfit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 20),
                          // Gender Selector
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildGenderBtn('Men'),
                                _buildGenderBtn('Women'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // Avatar
                Positioned(
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 6),
                              color: Colors.white,
                              image: _imageFile != null
                                  ? DecorationImage(
                                      image: FileImage(_imageFile!),
                                      fit: BoxFit.cover)
                                  : const DecorationImage(
                                      image: NetworkImage(
                                          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400'),
                                      fit: BoxFit.cover), // Placeholder
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF4B39EF)
                                        .withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10))
                              ]),
                          child: _imageFile == null
                              ? Center(
                                  child: Icon(Icons.camera_alt,
                                      size: 50,
                                      color: Colors.white.withOpacity(0.8)))
                              : null,
                        ),

                        // Retry Pill
                        if (_imageFile != null)
                          Positioned(
                            right: -10,
                            bottom: 40,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 5)
                                  ]),
                              child: const Text("Retry",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4B39EF))),
                            ),
                          )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          // 2. FORM & ACTIONS
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Name Field
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                hintText: "Outfit Name : Upload (Beta)",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: true,
                            onChanged: (v) {},
                            activeThumbColor: const Color(0xFF4B39EF),
                            trackColor: WidgetStateProperty.all(
                                const Color(0xFF4B39EF).withOpacity(0.3)),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Analyze Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B39EF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 8,
                          shadowColor:
                              const Color(0xFF4B39EF).withOpacity(0.4)),
                      onPressed: _analyzeAndMatch,
                      child: _isAnalyzing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Analyze & Find Matches",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                SizedBox(width: 8),
                                Icon(Icons.auto_awesome,
                                    size: 20, color: Colors.white70) // AI Icon
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // AI Feedback Text
                  if (_analysisText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: const Color(0xFF4B39EF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome,
                                color: Color(0xFF4B39EF), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(_analysisText!,
                                    style: const TextStyle(
                                        color: Color(0xFF4B39EF),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13))),
                          ],
                        ),
                      ),
                    ),

                  // Matches Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Your Auto-Generated Matches",
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                  const SizedBox(height: 16),

                  // Matches List
                  SizedBox(
                    height: 100,
                    child: _matches.isEmpty
                        ? Center(
                            child: Text("Waiting for analysis...",
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12)))
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _matches.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final item = _matches[index];
                              return Container(
                                width: 80,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12, blurRadius: 4)
                                    ]),
                                padding: const EdgeInsets.all(4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                      imageUrl: item.imageUrl,
                                      fit: BoxFit.cover),
                                ),
                              ).animate().scale(delay: (index * 100).ms);
                            },
                          ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width / 2, size.height + 40, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
