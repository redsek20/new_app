import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../core/app_theme.dart';

class UploadAnalyzerScreen extends StatefulWidget {
  const UploadAnalyzerScreen({super.key});

  @override
  State<UploadAnalyzerScreen> createState() => _UploadAnalyzerScreenState();
}

class _UploadAnalyzerScreenState extends State<UploadAnalyzerScreen> {
  File? _image;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  String? _error;

  final _picker = ImagePicker();

  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static const String _apiUrl = "http://10.0.2.2/php_api/analyze_outfit.php";

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _analysisResult = null;
        _error = null;
      });
      _analyzeOutfit();
    }
  }

  Future<void> _analyzeOutfit() async {
    if (_image == null) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));

      final streamedResponse = await request.send();
      final finalResponse = await http.Response.fromStream(streamedResponse);

      if (finalResponse.statusCode == 200) {
        final data = jsonDecode(finalResponse.body);
        if (data['success'] == true) {
          // Check if PHP wrapper says success
          // The PHP script might return the raw Gemini JSON directly if successful,
          // OR it might be wrapped. Based on the PHP code, it echoes rawText.
          // Let's handle both cases or assume the PHP returns the JSON from Gemini.
          // Actually looking at the PHP, it echoes rawText directly which IS json.
          // However, if it errors, it returns {success: false}.
          // We'll try to parse the whole body.
          setState(() {
            _analysisResult = data;
            _isAnalyzing = false;
          });
        } else if (data['description'] != null) {
          // It seems the PHP returns the direct JSON from Gemini which DOES include 'description'
          // but might NOT have a root 'success' key depending on the prompt.
          // The prompt asks for { "success": true, ... }. So checking success is valid.
          setState(() {
            _analysisResult = data;
            _isAnalyzing = false;
          });
        } else {
          throw Exception(data['error'] ?? "Unknown API Error");
        }
      } else {
        throw Exception("Server Error: ${finalResponse.statusCode}");
      }
    } catch (e) {
      print("Analysis Error: $e");
      setState(() {
        _error =
            "Could not analyze image. Make sure the PHP server is running.\n\nError: $e";
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GEMINI AI STYLIST',
            style: TextStyle(
                letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Upload Area
            GestureDetector(
              onTap: () => _showPickerOptions(),
              child: Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2), width: 2),
                  image: _image != null
                      ? DecorationImage(
                          image: FileImage(_image!), fit: BoxFit.cover)
                      : null,
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              size: 64, color: AppTheme.primary),
                          SizedBox(height: 16),
                          Text('Upload Item to Analyze',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 32),

            if (_isAnalyzing)
              Column(
                children: [
                  const CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(height: 16),
                  Text('Gemini is studying your style...',
                      style:
                          TextStyle(color: AppTheme.primary.withOpacity(0.8))),
                ],
              ).animate().fadeIn()
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            else if (_analysisResult != null)
              _buildAnalysisResults()
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    final analysis = _analysisResult!['ai_analysis'] ?? {};
    final suggestions =
        _analysisResult!['suggested_combinations'] as List? ?? [];
    final description = _analysisResult!['description'] ?? "No description";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI DESCRIPTION
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.auto_awesome, color: AppTheme.primary, size: 20),
                SizedBox(width: 8),
                Text("AI Analysis",
                    style: TextStyle(fontWeight: FontWeight.bold))
              ]),
              const SizedBox(height: 12),
              Text(description,
                  style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _tag(analysis['style_vibe'] ?? 'Casual', Colors.blue),
                  _tag(analysis['color_palette'] ?? 'Unknown Color',
                      Colors.purple),
                  _tag(analysis['occasion'] ?? 'Anytime', Colors.orange),
                ],
              )
            ],
          ),
        ).animate().slideY(begin: 0.2, end: 0).fadeIn(),

        const SizedBox(height: 32),

        // SUGGESTIONS
        const Text('COMPLETE THE LOOK',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.grey)),
        const SizedBox(height: 16),

        ...suggestions.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(
                          "https://image.pollinations.ai/prompt/${Uri.encodeComponent("${item['color']} ${item['type']} clothing product white background")}"),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1), blurRadius: 4)
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['type'] ?? 'Item',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${item['color']} • ${item['reason']}",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey)
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideX();
        }).toList(),
      ],
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPickerBtn(Icons.camera_alt, 'Camera', ImageSource.camera),
            _buildPickerBtn(
                Icons.photo_library, 'Gallery', ImageSource.gallery),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerBtn(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _pickImage(source);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 32),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
