import 'package:currency_converter/model/chart_model.dart';
import 'package:currency_converter/services/firebase_service.dart';
import 'package:flutter/material.dart';

class AddChartScreen extends StatefulWidget {
  final ChartData? chart;
  
  const AddChartScreen({super.key, this.chart});

  @override
  State<AddChartScreen> createState() => _AddChartScreenState();
}

class _AddChartScreenState extends State<AddChartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  final _indicatorController = TextEditingController();
  
  String _selectedCurrency = 'USD/EUR';
  String _selectedChartType = 'Line';
  String _selectedTimeframe = '1D';
  bool _isActive = true;
  bool _isLoading = false;
  List<String> _technicalIndicators = [];
  List<ChartPoint> _dataPoints = [];
  Map<String, dynamic> _chartSettings = {
    'showGrid': true,
    'showVolume': false,
    'theme': 'dark'
  };

  final List<String> _currencies = [
    'USD/EUR', 'USD/GBP', 'USD/JPY', 'EUR/GBP', 
    'GBP/JPY', 'AUD/USD', 'USD/CAD', 'NZD/USD'
    // add more currency pairs as needed
    'USD/CHF', 'AUD/JPY', 'CAD/JPY', 'GBP/AUD'
    // more
    'EUR/JPY', 'EUR/AUD', 'GBP/CAD', 'AUD/CAD'
    // and so on...
    'EUR/CHF', 'GBP/CHF', 'AUD/NZD', 'NZD/CAD'
    // you can expand this list with more pairs as needed 
    'USD/SGD', 'USD/HKD', 'USD/CNY', 'USD/INR'
    // and more pairs as needed 
    'USD/SEK', 'USD/NOK', 'USD/DKK', 'USD/ZAR'
    'USD/PKR', 'USD/TRY', 'USD/MXN', 'USD/BRL'
    'INR/PKR', 'INR/JPY', 'INR/EUR', 'INR/USD'
    'PKR/JPY', 'PKR/EUR', 'PKR/USD', 'PKR/GBP'
    

  ];
  
  final List<String> _chartTypes = ['Line', 'Candlestick', 'Bar', 'Area'];
  final List<String> _timeframes = ['1H', '4H', '1D', '1W', '1M', '3M', '1Y'];

  @override
  void initState() {
    super.initState();
    if (widget.chart != null) {
      _populateFields();
    } else {
      _generateSampleDataPoints();
    }
  }

  void _populateFields() {
    final chart = widget.chart!;
    _titleController.text = chart.title;
    _descriptionController.text = chart.description;
    _authorController.text = chart.authorName;
    _selectedCurrency = chart.currency;
    _selectedChartType = chart.chartType;
    _selectedTimeframe = chart.timeframe;
    _isActive = chart.isActive;
    _technicalIndicators = List.from(chart.technicalIndicators);
    _dataPoints = List.from(chart.dataPoints);
    _chartSettings = Map.from(chart.chartSettings);
  }

  void _generateSampleDataPoints() {
    // Generate sample data points for demonstration
    final now = DateTime.now();
    final baseValue = 1.0850; // Sample EUR/USD rate
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final randomVariation = (i % 5 - 2) * 0.001; // Small random variation
      final value = baseValue + randomVariation;
      
      _dataPoints.add(ChartPoint(
        timestamp: date,
        value: value,
        high: value + 0.002,
        low: value - 0.002,
        open: value - 0.001,
        close: value + 0.001,
        volume: 1000000 + (i * 50000),
      ));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _indicatorController.dispose();
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
                        child: _buildChartForm(),
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
              widget.chart == null ? 'Add Market Chart' : 'Edit Market Chart',
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

  Widget _buildChartForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 32),
          
          // Title
          _buildTextFormField(
            controller: _titleController,
            label: 'Chart Title',
            hint: 'Enter chart title...',
            icon: Icons.show_chart_rounded,
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
          
          // Currency and Chart Type Row
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
                  label: 'Chart Type',
                  value: _selectedChartType,
                  items: _chartTypes,
                  onChanged: (value) => setState(() => _selectedChartType = value!),
                  icon: Icons.bar_chart_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Timeframe and Author Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Timeframe',
                  value: _selectedTimeframe,
                  items: _timeframes,
                  onChanged: (value) => setState(() => _selectedTimeframe = value!),
                  icon: Icons.schedule_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextFormField(
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
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Description
          _buildTextFormField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Enter chart description...',
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
          
          // Technical Indicators Section
          _buildTechnicalIndicatorsSection(),
          const SizedBox(height: 24),
          
          // Chart Settings Section
          _buildChartSettingsSection(),
          const SizedBox(height: 24),
          
          // Data Points Info
          _buildDataPointsInfo(),
          const SizedBox(height: 24),
          
          // Active Switch
          _buildActiveSwitch(),
        ],
      ),
    );
  }

  Widget _buildTechnicalIndicatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics_rounded, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Technical Indicators',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A94A6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Add Indicator Input
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _indicatorController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Add indicator (e.g., RSI, MACD, SMA)...',
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
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addTechnicalIndicator,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
        
        // Indicators List
        if (_technicalIndicators.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _technicalIndicators.asMap().entries.map((entry) {
                final index = entry.key;
                final indicator = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        indicator,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeTechnicalIndicator(index),
                        child: const Icon(
                          Icons.close,
                          color: Colors.blue,
                          size: 14,
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

  Widget _buildChartSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Chart Settings',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A94A6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Show Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Show Grid',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Switch(
                value: _chartSettings['showGrid'] ?? true,
                onChanged: (value) {
                  setState(() {
                    _chartSettings['showGrid'] = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
          
          // Show Volume
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Show Volume',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Switch(
                value: _chartSettings['showVolume'] ?? false,
                onChanged: (value) {
                  setState(() {
                    _chartSettings['showVolume'] = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
          
          // Theme
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Theme',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              DropdownButton<String>(
                value: _chartSettings['theme'] ?? 'dark',
                onChanged: (value) {
                  setState(() {
                    _chartSettings['theme'] = value!;
                  });
                },
                dropdownColor: const Color(0xFF1A1A2E),
                items: ['dark', 'light'].map((String theme) {
                  return DropdownMenuItem<String>(
                    value: theme,
                    child: Text(
                      theme.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataPointsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.data_usage_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Chart Data',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A94A6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Data Points:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                '${_dataPoints.length}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_dataPoints.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date Range:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_dataPoints.first.timestamp.day}/${_dataPoints.first.timestamp.month} - ${_dataPoints.last.timestamp.day}/${_dataPoints.last.timestamp.month}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _generateSampleDataPoints,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.2),
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Regenerate Sample Data',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _addTechnicalIndicator() {
    if (_indicatorController.text.trim().isNotEmpty) {
      setState(() {
        _technicalIndicators.add(_indicatorController.text.trim().toUpperCase());
        _indicatorController.clear();
      });
    }
  }

  void _removeTechnicalIndicator(int index) {
    setState(() {
      _technicalIndicators.removeAt(index);
    });
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.indigo.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.chart == null ? Icons.add_chart : Icons.edit_note_rounded,
              color: Colors.blue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chart == null ? 'Create Market Chart' : 'Edit Market Chart',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.chart == null 
                    ? 'Add new market chart with technical analysis'
                    : 'Update chart information and settings',
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
            Icon(icon, color: Colors.blue, size: 20),
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
                color: Colors.blue,
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
            Icon(icon, color: Colors.blue, size: 20),
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
                color: Colors.blue,
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
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_rounded, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Active Chart',
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
            activeColor: Colors.blue,
            activeTrackColor: Colors.blue.withOpacity(0.3),
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
        onPressed: _isLoading ? null : _saveChart,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
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
                  Icon(widget.chart == null ? Icons.add : Icons.update),
                  const SizedBox(width: 8),
                  Text(
                    widget.chart == null ? 'Add Chart' : 'Update Chart',
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

  Future<void> _saveChart() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      
      final chart = ChartData(
        id: widget.chart?.id,
        title: _titleController.text.trim(),
        currency: _selectedCurrency,
        chartType: _selectedChartType,
        timeframe: _selectedTimeframe,
        dataPoints: _dataPoints,
        description: _descriptionController.text.trim(),
        technicalIndicators: _technicalIndicators,
        chartSettings: _chartSettings,
        isActive: _isActive,
        createdAt: widget.chart?.createdAt ?? now,
        updatedAt: now,
        authorId: 'admin',
        authorName: _authorController.text.trim(),
      );

      bool success;
      if (widget.chart == null) {
        String? id = await FirebaseService.addChart(chart);
        success = id != null;
      } else {
        success = (await FirebaseService.updateChart(widget.chart!.id!, chart)) != null;
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
                  widget.chart == null
                      ? 'Chart added successfully!'
                      : 'Chart updated successfully!',
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        throw Exception('Failed to save chart');
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
