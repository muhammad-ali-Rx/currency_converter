import 'package:currency_converter/model/trend_model.dart';
import 'package:currency_converter/services/firebase_service.dart';
import 'package:flutter/material.dart';

class AddTrendScreen extends StatefulWidget {
  final Trend? trend;
  
  const AddTrendScreen({super.key, this.trend});

  @override
  State<AddTrendScreen> createState() => _AddTrendScreenState();
}

class _AddTrendScreenState extends State<AddTrendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _analysisController = TextEditingController();
  final _percentageController = TextEditingController();
  final _authorController = TextEditingController();
  
  String _selectedCurrency = 'USD/EUR';
  String _selectedTimeframe = '1D';
  String _selectedDirection = 'up';
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _currencies = [
    'USD/EUR', 'USD/GBP', 'USD/JPY', 'EUR/GBP', 
    'GBP/JPY', 'AUD/USD', 'USD/CAD', 'NZD/USD'
  ];
  
  final List<String> _timeframes = ['1H', '4H', '1D', '1W', '1M', '3M', '1Y'];
  final List<String> _directions = ['up', 'down', 'neutral'];

  @override
  void initState() {
    super.initState();
    if (widget.trend != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final trend = widget.trend!;
    _titleController.text = trend.title;
    _descriptionController.text = trend.description;
    _analysisController.text = trend.analysis;
    _percentageController.text = trend.percentage.toString();
    _authorController.text = trend.authorName;
    _selectedCurrency = trend.currency;
    _selectedTimeframe = trend.timeframe;
    _selectedDirection = trend.direction;
    _isActive = trend.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _analysisController.dispose();
    _percentageController.dispose();
    _authorController.dispose();
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
                        child: _buildTrendForm(),
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
              widget.trend == null ? 'Add Market Trend' : 'Edit Market Trend',
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

  Widget _buildTrendForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 32),
          
          // Title
          _buildTextFormField(
            controller: _titleController,
            label: 'Trend Title',
            hint: 'Enter trend title...',
            icon: Icons.trending_up_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              if (value.length < 5) {
                return 'Title must be at least 5 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Currency and Timeframe Row
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
                  label: 'Timeframe',
                  value: _selectedTimeframe,
                  items: _timeframes,
                  onChanged: (value) => setState(() => _selectedTimeframe = value!),
                  icon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Direction and Percentage Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Direction',
                  value: _selectedDirection,
                  items: _directions,
                  onChanged: (value) => setState(() => _selectedDirection = value!),
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextFormField(
                  controller: _percentageController,
                  label: 'Percentage Change',
                  hint: 'e.g., 2.5 or -1.8',
                  icon: Icons.percent_rounded,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter percentage';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid number';
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
          
          // Description
          _buildTextFormField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Enter trend description...',
            icon: Icons.description_rounded,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              if (value.length < 20) {
                return 'Description must be at least 20 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Analysis
          _buildTextFormField(
            controller: _analysisController,
            label: 'Market Analysis',
            hint: 'Enter detailed market analysis...',
            icon: Icons.analytics_rounded,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter market analysis';
              }
              if (value.length < 50) {
                return 'Analysis must be at least 50 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Active Switch
          _buildActiveSwitch(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.deepOrange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.trend == null ? Icons.add_chart : Icons.edit_note_rounded,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.trend == null ? 'Create Market Trend' : 'Edit Market Trend',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.trend == null 
                    ? 'Add new market trend analysis and insights'
                    : 'Update trend information and analysis',
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
            Icon(icon, color: Colors.orange, size: 20),
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
                color: Colors.orange,
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
            Icon(icon, color: Colors.orange, size: 20),
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
                color: Colors.orange,
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

  Widget _buildActiveSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Active Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Switch(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeColor: Colors.orange,
            activeTrackColor: Colors.orange.withOpacity(0.3),
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
        onPressed: _isLoading ? null : _saveTrend,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
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
                  Icon(widget.trend == null ? Icons.add : Icons.update),
                  const SizedBox(width: 8),
                  Text(
                    widget.trend == null ? 'Add Trend' : 'Update Trend',
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

  Future<void> _saveTrend() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      
      final trend = Trend(
        id: widget.trend?.id,
        title: _titleController.text.trim(),
        currency: _selectedCurrency,
        timeframe: _selectedTimeframe,
        percentage: double.parse(_percentageController.text.trim()),
        direction: _selectedDirection,
        description: _descriptionController.text.trim(),
        analysis: _analysisController.text.trim(),
        isActive: _isActive,
        createdAt: widget.trend?.createdAt ?? now,
        updatedAt: now,
        authorId: 'admin',
        authorName: _authorController.text.trim(),
      );

      bool success;
      if (widget.trend == null) {
        String? id = await FirebaseService.addTrend(trend);
        success = id != null;
      } else {
        success = (await FirebaseService.updateTrend(widget.trend!.id!, trend)) != null;
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
                  widget.trend == null
                      ? 'Trend added successfully!'
                      : 'Trend updated successfully!',
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        throw Exception('Failed to save trend');
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
