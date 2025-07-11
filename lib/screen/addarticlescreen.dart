import 'package:currency_converter/model/article_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/firebase_service.dart';

class userArticleScreen extends StatefulWidget {
  final Article? article;

  const userArticleScreen({super.key, this.article});

  @override
  State<userArticleScreen> createState() => _userArticleScreenState();
}

class _userArticleScreenState extends State<userArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _sourceController = TextEditingController();
  final _authorController = TextEditingController();

  String _selectedCategory = 'USD';
  String _selectedImpact = 'Medium';
  bool _isPublished = true;
  bool _isLoading = false;

  // Image handling
  File? _selectedImage;
  Uint8List? _webImage;
  String? _imageBase64;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = ['USD', 'EUR', 'GBP', 'Asia', 'Crypto', 'Commodities'];
  final List<String> _impacts = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final article = widget.article!;
    _titleController.text = article.title;
    _summaryController.text = article.summary;
    _contentController.text = article.content;
    _sourceController.text = article.source;
    _authorController.text = article.authorName;
    _selectedCategory = article.category;
    _selectedImpact = article.impact;
    _isPublished = article.isPublished;
    _imageBase64 = article.imageUrl; // Existing image as base64
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _sourceController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _buildArticleForm(),
                      ),
                    ),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Expanded(
            child: Text(
              widget.article == null ? 'Add Article' : 'Edit Article',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildArticleForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 32),
          // Image Picker Section
          _buildImagePicker(),
          const SizedBox(height: 24),
          // Title
          _buildTextFormField(
            controller: _titleController,
            label: 'Article Title',
            hint: 'Enter article title...',
            icon: Icons.title_rounded,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              if (value.length < 10) {
                return 'Title must be at least 10 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Category and Impact Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Category',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                  icon: Icons.category_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Impact Level',
                  value: _selectedImpact,
                  items: _impacts,
                  onChanged: (value) => setState(() => _selectedImpact = value!),
                  icon: Icons.trending_up_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Source and Author Row
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _sourceController,
                  label: 'Source',
                  hint: 'e.g., Reuters, Bloomberg',
                  icon: Icons.source_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter source';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextFormField(
                  controller: _authorController,
                  label: 'Author',
                  hint: 'Author name',
                  icon: Icons.person_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter author name';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Summary
          _buildTextFormField(
            controller: _summaryController,
            label: 'Summary',
            hint: 'Enter article summary...',
            icon: Icons.summarize_rounded,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a summary';
              }
              if (value.length < 50) {
                return 'Summary must be at least 50 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Content
          _buildTextFormField(
            controller: _contentController,
            label: 'Article Content',
            hint: 'Enter full article content...',
            icon: Icons.article_rounded,
            maxLines: 8,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter article content';
              }
              if (value.length < 100) {
                return 'Content must be at least 100 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Published Switch
          _buildPublishSwitch(),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.image_rounded, color: Color.fromARGB(255, 10, 108, 236), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Article Image',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A94A6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F23),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: _buildImagePreview(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF8A94A6), size: 16),
            const SizedBox(width: 4),
            const Text(
              'Tap to select image (Max 900KB)',
              style: TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 12,
              ),
            ),
            const Spacer(),
            if (_hasImage())
              TextButton(
                onPressed: _removeImage,
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    // Priority: New selected image > Existing base64 > Placeholder
    if (kIsWeb && _webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _webImage!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (!kIsWeb && _selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImage!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(_imageBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        print('Error decoding existing image: $e');
      }
    }

    // Default placeholder
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.6),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add image',
          style: TextStyle(
            color: const Color(0xFF8A94A6).withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG (Max 900KB)',
          style: TextStyle(
            color: const Color(0xFF8A94A6).withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  bool _hasImage() {
    return _selectedImage != null || _webImage != null || (_imageBase64 != null && _imageBase64!.isNotEmpty);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          if (bytes.length > 900 * 1024) {
            throw Exception('Image too large (max 900KB)');
          }
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
            _imageBase64 = null; // Clear existing image
          });
        } else {
          final file = File(image.path);
          final bytes = await file.readAsBytes();
          if (bytes.length > 900 * 1024) {
            throw Exception('Image too large (max 900KB)');
          }
          setState(() {
            _selectedImage = file;
            _webImage = null;
            _imageBase64 = null; // Clear existing image
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _imageBase64 = null;
    });
  }

  String? _convertImageToBase64() {
    try {
      if (kIsWeb && _webImage != null) {
        return base64Encode(_webImage!);
      } else if (!kIsWeb && _selectedImage != null) {
        final bytes = _selectedImage!.readAsBytesSync();
        return base64Encode(bytes);
      }
      return _imageBase64; // Return existing image if no new image selected
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
            const Color.fromARGB(255, 10, 108, 236).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.article == null ? Icons.add_circle_outline : Icons.edit_note_rounded,
              color: const Color.fromARGB(255, 10, 108, 236),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.article == null ? 'Create New Article' : 'Edit Article',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.article == null 
                    ? 'Fill in the details to create a new currency news article'
                    : 'Update article information and content',
                  style: const TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 10, 108, 236), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8A94A6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF8A94A6)),
            filled: true,
            fillColor: const Color(0xFF0F0F23),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 10, 108, 236),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            errorStyle: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 10, 108, 236), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8A94A6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F0F23),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 10, 108, 236),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          dropdownColor: const Color(0xFF1A1A2E),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPublishSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.publish_rounded, color: Color.fromARGB(255, 10, 108, 236), size: 20),
              SizedBox(width: 8),
              Text(
                'Publish Article',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Switch(
            value: _isPublished,
            onChanged: (value) {
              setState(() {
                _isPublished = value;
              });
            },
            activeColor: const Color.fromARGB(255, 10, 108, 236),
            activeTrackColor: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFF8A94A6),
            inactiveTrackColor: const Color(0xFF8A94A6).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveArticle,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 10, 108, 236),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.article == null ? Icons.add : Icons.update),
                  const SizedBox(width: 8),
                  Text(
                    widget.article == null ? 'Add Article' : 'Update Article',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      
      // Convert image to base64 if available
      final imageBase64 = _convertImageToBase64();
      
      final article = Article(
        id: widget.article?.id,
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        source: _sourceController.text.trim(),
        impact: _selectedImpact,
        imageUrl: imageBase64 ?? '', // Store as base64 string
        createdAt: widget.article?.createdAt ?? now,
        updatedAt: now,
        authorId: 'user',
        authorName: _authorController.text.trim(),
        isPublished: _isPublished,
      );

      bool success;
      if (widget.article == null) {
        String? id = await FirebaseService.addArticle(article);
        success = id != null;
      } else {
        success = (await FirebaseService.updateArticle(widget.article!.id!, article)) != null;
      }

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  widget.article == null
                      ? 'Article added successfully!'
                      : 'Article updated successfully!',
                ),
              ],
            ),
            backgroundColor: const Color.fromARGB(255, 10, 108, 236),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        throw Exception('Failed to save article');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
