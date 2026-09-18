import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'add_product_screen.dart';
import '../services/api_config.dart';

class ImageStudioScreen extends StatefulWidget {
  const ImageStudioScreen({super.key});

  @override
  State<ImageStudioScreen> createState() => _ImageStudioScreenState();
}

class _ImageStudioScreenState extends State<ImageStudioScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  Uint8List? _originalImageBytes;
  Uint8List? _enhancedImageBytes;

  bool _isEnhancing = false;
  bool _enhanced = false;

  String get apiUrl => ApiConfig.baseUrl;

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        _selectedImage = image;
        _originalImageBytes = bytes;
        _enhancedImageBytes = null;
        _enhanced = false;
      });
    } catch (e) {
      _showMessage('Could not select image.');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        _selectedImage = image;
        _originalImageBytes = bytes;
        _enhancedImageBytes = null;
        _enhanced = false;
      });
    } catch (e) {
      _showMessage('Could not open camera.');
    }
  }

  Future<void> _showImageSourceOptions() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF7C4DFF),
                    child: Icon(Icons.photo_library, color: Colors.white),
                  ),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Choose an existing product photo',
                    style: TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF00BFA5),
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Take a new product photo',
                    style: TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _enhanceImage() async {
    if (_selectedImage == null) {
      _showMessage('Please select a product photo first.');
      return;
    }

    setState(() {
      _isEnhancing = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/ai/image-enhance-upload'),
      );

      request.fields['product_name'] = 'HeriTrace Product';

      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedImage!.path),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Image enhancement failed.');
      }

      final String base64Image = data['enhanced_image'];

      final String cleanBase64 = base64Image.contains(',')
          ? base64Image.split(',').last
          : base64Image;

      final bytes = base64Decode(cleanBase64);

      if (!mounted) return;

      setState(() {
        _enhancedImageBytes = bytes;
        _enhanced = true;
        _isEnhancing = false;
      });

      _showMessage('Image enhanced successfully.');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isEnhancing = false;
      });

      _showMessage(
        'Could not enhance image. Make sure the AI server is running.',
      );
    }
  }

  void _resetImage() {
    setState(() {
      _enhancedImageBytes = null;
      _enhanced = false;
    });
  }

  void _useEnhancedPhoto() {
    if (_enhancedImageBytes == null) {
      _showMessage('Please enhance the image first.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddProductScreen(enhancedImageBytes: _enhancedImageBytes),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const Expanded(
          child: Text(
            'AI Image Studio',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_enhanced)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00C853).withOpacity(0.4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF69F0AE), size: 16),
                SizedBox(width: 5),
                Text(
                  'AI Enhanced',
                  style: TextStyle(
                    color: Color(0xFF69F0AE),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF171A22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C4DFF).withOpacity(0.15),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFFB388FF),
              size: 44,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Create Better Product Photos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Upload a product photo and HeriTrace will improve lighting, contrast, color and sharpness.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, height: 1.5, fontSize: 14),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _showImageSourceOptions,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text(
                'Choose Product Photo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final imageBytes = _enhanced && _enhancedImageBytes != null
        ? _enhancedImageBytes!
        : _originalImageBytes!;

    return Container(
      width: double.infinity,
      height: 390,
      decoration: BoxDecoration(
        color: const Color(0xFF101218),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              imageBytes,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 50,
                  ),
                );
              },
            ),
          ),
          if (_enhanced)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF69F0AE),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Enhanced',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171A22),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enhancement',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _optionRow(
            Icons.wb_sunny_outlined,
            'Lighting',
            'Improve brightness and exposure',
          ),
          _optionRow(
            Icons.contrast,
            'Contrast',
            'Make product details clearer',
          ),
          _optionRow(
            Icons.palette_outlined,
            'Color',
            'Improve natural product colors',
          ),
          _optionRow(
            Icons.high_quality,
            'Sharpness',
            'Make product details clearer',
          ),
        ],
      ),
    );
  }

  Widget _optionRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFB388FF), size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF69F0AE), size: 20),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    if (_enhanced) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _useEnhancedPhoto,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Use Enhanced Photo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetImage,
                  icon: const Icon(Icons.undo),
                  label: const Text('Original'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showImageSourceOptions,
                  icon: const Icon(Icons.change_circle_outlined),
                  label: const Text('Change'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isEnhancing ? null : _enhanceImage,
        icon: _isEnhancing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(
          _isEnhancing ? 'Enhancing Photo...' : 'Enhance with AI',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C4DFF),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 20, 10),
              child: _buildTopBar(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: _originalImageBytes == null
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          _buildImagePreview(),
                          const SizedBox(height: 18),
                          _buildOptions(),
                          const SizedBox(height: 18),
                          _buildBottomButtons(),
                          const SizedBox(height: 20),
                          const Text(
                            'Tip: Use a well-lit photo with the complete product visible.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
