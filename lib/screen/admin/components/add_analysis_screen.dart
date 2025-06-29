import 'package:currency_converter/model/analysis_model.dart';
import 'package:currency_converter/services/firebase_service.dart';
import 'package:flutter/material.dart';

class AddAnalysisScreen extends StatefulWidget {
  final Analysis? analysis;
  
  const AddAnalysisScreen({super.key, this.analysis});

  @override
  State<AddAnalysisScreen> createState() => _AddAnalysisScreenState();
}

class _AddAnalysisScreenState extends State<AddAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _confidenceController = TextEditingController();
  final _authorController = TextEditingController();
  final _keyPointController = TextEditingController();
  
  String _selectedCurrency = 'USD/EUR';
  String _selectedAnalysisType = 'Technical';
  String _selectedRecommendation = 'Hold';
  String _selectedRiskLevel = 'Medium';
  String _selectedTimeHorizon = 'Medium-term';
  bool _isPublished = true;
  bool _isLoading = false;
  List<String> _keyPoints = [];

  final List<String> _currencies = [
    'USD/EUR', 'USD/GBP', 'USD/JPY', 'EUR/GBP', 
    'GBP/JPY', 'AUD/USD', 'USD/CAD', 'NZD/USD'
  ];
  
  final List<String> _analysisTypes = ['Technical', 'Fundamental', 'Market Sentiment'];
  final List<String> _recommendations = ['Buy', 'Sell', 'Hold'];
  final List<String> _riskLevels = ['Low', 'Medium', 'High'];
  final List<String> _timeHorizons = ['Short-term', 'Medium-term', 'Long-term'];

  @override
  void initState() {
    super.initState();
    if (widget.analysis != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final analysis = widget.analysis!;
    _titleController.text = analysis.title;
    _summaryController.text = analysis.summary;
    _contentController.text = analysis.content;
    _confidenceController.text = analysis.confidenceScore.toString();
    _authorController.text = analysis.authorName;
    _selectedCurrency = analysis.currency;
    _selectedAnalysisType = analysis.analysisType;
    _selectedRecommendation = analysis.recommendation;
    _selectedRiskLevel = analysis.riskLevel;
    _selectedTimeHorizon = analysis.timeHorizon;
    _isPublished = analysis.isPublished;
    _keyPoints = List.from(analysis.keyPoints);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _confidenceController.dispose();
    _authorController.dispose();
    _keyPointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F23),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1A1A2E)),
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
                        child: _buildAnalysisForm(),
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
              widget.analysis == null ? 'Add Market Analysis' : 'Edit Market Analysis',
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

  Widget _buildAnalysisForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 32),
          
          // Title
          _buildTextFormField(
            controller: _titleController,
            label: 'Analysis Title',
            hint: 'Enter analysis title...',
            icon: Icons.analytics_rounded,
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
          
          // Currency and Analysis Type Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Currency Pair',
                  value: _selectedCurrency,
                  items: _currencies,
                  onChanged: (value) => setState(() => _selectedCurrency = value!),
                  icon: Icons.currency_exchange_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Analysis Type',
                  value: _selectedAnalysisType,
                  items: _analysisTypes,
                  onChanged: (value) => setState(() => _selectedAnalysisType = value!),
                  icon: Icons.category_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recommendation and Risk Level Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Recommendation',
                  value: _selectedRecommendation,
                  items: _recommendations,
                  onChanged: (value) => setState(() => _selectedRecommendation = value!),
                  icon: Icons.recommend_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Risk Level',
                  value: _selectedRiskLevel,
                  items: _riskLevels,
                  onChanged: (value) => setState(() => _selectedRiskLevel = value!),
                  icon: Icons.warning_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Time Horizon and Confidence Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Time Horizon',
                  value: _selectedTimeHorizon,
                  items: _timeHorizons,
                  onChanged: (value) => setState(() => _selectedTimeHorizon = value!),
                  icon: Icons.schedule_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextFormField(
                  controller: _confidenceController,
                  label: 'Confidence Score',
                  hint: 'e.g., 85.5',
                  icon: Icons.percent_rounded,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter confidence score';
                    }
                    final score = double.tryParse(value);
                    if (score == null || score < 0 || score > 100) {
                      return 'Enter valid score (0-100)';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Author
          _buildTextFormField(
            controller: _authorController,
            label: 'Author Name',
            hint: 'Author name',
            icon: Icons.person_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter author name';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Summary
          _buildTextFormField(
            controller: _summaryController,
            label: 'Summary',
            hint: 'Enter analysis summary...',
            icon: Icons.summarize_rounded,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a summary';
              }
              if (value.length < 30) {
                return 'Summary must be at least 30 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Content
          _buildTextFormField(
            controller: _contentController,
            label: 'Analysis Content',
            hint: 'Enter detailed analysis content...',
            icon: Icons.article_rounded,
            maxLines: 6,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter analysis content';
              }
              if (value.length < 100) {
                return 'Content must be at least 100 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Key Points Section
          _buildKeyPointsSection(),
          const SizedBox(height: 24),
          
          // Published Switch
          _buildPublishSwitch(),
        ],
      ),
    );
  }

  Widget _buildKeyPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.list_rounded, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Key Points',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A94A6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Add Key Point Input
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _keyPointController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Add key point...',
                  hintStyle: const TextStyle(color: Color(0xFF8A94A6)),
                  filled: true,
                  fillColor: const Color(0xFF1A1A2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addKeyPoint,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Key Points List
        if (_keyPoints.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: _keyPoints.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 8,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeKeyPoint(index),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  void _addKeyPoint() {
    if (_keyPointController.text.trim().isNotEmpty) {
      setState(() {
        _keyPoints.add(_keyPointController.text.trim());
        _keyPointController.clear();
      });
    }
  }

  void _removeKeyPoint(int index) {
    setState(() {
      _keyPoints.removeAt(index);
    });
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.teal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.analysis == null ? Icons.add_chart : Icons.edit_note_rounded,
              color: Colors.green,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.analysis == null ? 'Create Market Analysis' : 'Edit Market Analysis',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.analysis == null 
                    ? 'Add comprehensive market analysis and recommendations'
                    : 'Update analysis information and recommendations',
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green, size: 20),
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
          keyboardType: keyboardType,
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
            fillColor: const Color(0xFF1A1A2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.green,
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
            Icon(icon, color: Colors.green, size: 20),
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
            fillColor: const Color(0xFF1A1A2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.green,
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
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.publish_rounded, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Publish Analysis',
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
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.3),
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
        onPressed: _isLoading ? null : _saveAnalysis,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
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
                  Icon(widget.analysis == null ? Icons.add : Icons.update),
                  const SizedBox(width: 8),
                  Text(
                    widget.analysis == null ? 'Add Analysis' : 'Update Analysis',
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

  Future<void> _saveAnalysis() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      
      final analysis = Analysis(
        id: widget.analysis?.id,
        title: _titleController.text.trim(),
        currency: _selectedCurrency,
        analysisType: _selectedAnalysisType,
        content: _contentController.text.trim(),
        summary: _summaryController.text.trim(),
        recommendation: _selectedRecommendation,
        riskLevel: _selectedRiskLevel,
        confidenceScore: double.parse(_confidenceController.text.trim()),
        keyPoints: _keyPoints,
        timeHorizon: _selectedTimeHorizon,
        isPublished: _isPublished,
        views: widget.analysis?.views ?? 0,
        createdAt: widget.analysis?.createdAt ?? now,
        updatedAt: now,
        authorId: 'admin',
        authorName: _authorController.text.trim(),
      );

      bool success;
      if (widget.analysis == null) {
        String? id = await FirebaseService.addAnalysis(analysis);
        success = id != null;
      } else {
        success = (await FirebaseService.updateAnalysis(widget.analysis!.id!, analysis)) != null;
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
                  widget.analysis == null
                      ? 'Analysis added successfully!'
                      : 'Analysis updated successfully!',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        throw Exception('Failed to save analysis');
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
