import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';
import '../services/firebase_service.dart';
import '../services/api_config.dart';

class AddProductScreen extends StatefulWidget {
  final Uint8List? enhancedImageBytes;

  const AddProductScreen({super.key, this.enhancedImageBytes});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final Uuid _uuid = const Uuid();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _categoryController = TextEditingController(
    text: 'Handicraft',
  );

  Uint8List? _selectedImageBytes;
  Uint8List? _enhancedImageBytes;

  XFile? _selectedImage;

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _isGenerating = false;
  bool _isPublishing = false;

  String _selectedLanguage = 'English';

  String generationProductName = '';

  String get apiUrl => ApiConfig.baseUrl;

  final List<String> _languages = ['English', 'Hindi', 'Odia', 'Bengali'];

  @override
  void initState() {
    super.initState();

    _enhancedImageBytes = widget.enhancedImageBytes;

    if (_enhancedImageBytes != null) {
      _selectedImageBytes = _enhancedImageBytes;
    }

    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;

          setState(() {
            _isListening = status == 'listening';
          });
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _isListening = false;
          });
        },
      );

      if (!mounted) return;

      setState(() {
        _speechAvailable = available;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _speechAvailable = false;
      });
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      _showMessage(
        'Speech recognition is not available on this device/browser.',
      );
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            _descriptionController.text = result.recognizedWords;
          });
        },
      );

      if (!mounted) return;

      setState(() {
        _isListening = true;
      });
    } catch (_) {
      _showMessage('Could not start microphone.');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _isListening = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
        _enhancedImageBytes = null;
      });
    } catch (_) {
      _showMessage('Could not select image.');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
        _enhancedImageBytes = null;
      });
    } catch (_) {
      _showMessage('Could not open camera.');
    }
  }

  Future<void> _generateCatalog() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Enter the product name first.');
      return;
    }

    generationProductName = name;

    setState(() {
      _isGenerating = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/ai/generate-catalog'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': generationProductName,
          'category': _categoryController.text.trim().isEmpty
              ? 'Handicraft'
              : _categoryController.text.trim(),
          'language': _selectedLanguage,
          'notes': _descriptionController.text.trim(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Server error ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['success'] != true) {
        throw Exception('Catalog generation failed');
      }

      if (!mounted) return;

      setState(() {
        if (data['title'] != null &&
            data['title'].toString().trim().isNotEmpty) {
          _nameController.text = data['title'].toString();
        }

        if (data['category'] != null &&
            data['category'].toString().trim().isNotEmpty) {
          _categoryController.text = data['category'].toString();
        }

        if (data['description'] != null) {
          _descriptionController.text = data['description'].toString();
        }
      });

      _showMessage('AI catalog generated successfully.');
    } catch (_) {
      _showMessage(
        'Could not generate catalog. Make sure the AI server is running.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _publishProduct() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final priceText = _priceController.text.trim();
    final category = _categoryController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter product name.');
      return;
    }

    if (description.isEmpty) {
      _showMessage('Please enter product description.');
      return;
    }

    final price = double.tryParse(priceText);

    if (price == null || price <= 0) {
      _showMessage('Please enter a valid price.');
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      String? imageUrl;
      if (_selectedImageBytes != null) {
        imageUrl = await _firebaseService.uploadImage(
          _selectedImageBytes!,
          'products/${FirebaseAuth.instance.currentUser!.uid}/${_uuid.v4()}.jpg',
        );
      }

      final product = Product(
        id: _uuid.v4(),
        name: name,
        description: description,
        price: price,
        category: category.isEmpty ? 'Handicraft' : category,
        imageUrl: imageUrl,
      );

      await _firebaseService.saveProduct(product);

      if (!mounted) return;

      generationProductName = '';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product published successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showMessage('Could not publish product. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Catalog Language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                ..._languages.map(
                  (language) => ListTile(
                    leading: Icon(
                      language == _selectedLanguage
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: const Color(0xFFB388FF),
                    ),
                    title: Text(
                      language,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language;
                      });

                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF171A22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (_selectedImageBytes == null) {
      return GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: double.infinity,
          height: 230,
          decoration: BoxDecoration(
            color: const Color(0xFF171A22),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: Color(0xFFB388FF),
                size: 50,
              ),
              SizedBox(height: 12),
              Text(
                'Add Product Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Tap to choose from gallery',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF101218),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.memory(_selectedImageBytes!, fit: BoxFit.contain),
          ),
          if (_enhancedImageBytes != null)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.72),
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
                      'AI Enhanced Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Row(
              children: [
                FloatingActionButton.small(
                  heroTag: 'gallery',
                  onPressed: _pickImage,
                  backgroundColor: Colors.black87,
                  child: const Icon(Icons.photo_library, color: Colors.white),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  heroTag: 'camera',
                  onPressed: _takePhoto,
                  backgroundColor: Colors.black87,
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechButton() {
    return IconButton(
      tooltip: 'Voice input',
      onPressed: _isListening ? _stopListening : _startListening,
      icon: Icon(
        _isListening ? Icons.mic : Icons.mic_none,
        color: _isListening ? const Color(0xFFFF5252) : const Color(0xFFB388FF),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();

    _speech.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D12),
        elevation: 0,
        title: const Text(
          'Add Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),

              const SizedBox(height: 22),

              const Text(
                'Product Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _nameController,
                label: 'Product Name',
                hint: 'Example: Handwoven Bamboo Basket',
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _categoryController,
                label: 'Category',
                hint: 'Handicraft',
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _descriptionController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your product...',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white30),
                  suffixIcon: _buildSpeechButton(),
                  filled: true,
                  fillColor: const Color(0xFF171A22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _priceController,
                label: 'Price',
                hint: 'Enter price',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF171A22),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.translate, color: Color(0xFFB388FF)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'AI Catalog Language',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _showLanguageSelector,
                      child: Text(
                        _selectedLanguage,
                        style: const TextStyle(
                          color: Color(0xFFB388FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isGenerating ? null : _generateCatalog,
                  icon: _isGenerating
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isGenerating ? 'Generating...' : 'Generate AI Catalog',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB388FF),
                    side: BorderSide(
                      color: const Color(0xFFB388FF).withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isPublishing ? null : _publishProduct,
                  icon: _isPublishing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    _isPublishing ? 'Publishing...' : 'Publish Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
