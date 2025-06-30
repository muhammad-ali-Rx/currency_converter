import 'package:currency_converter/model/chart_model.dart';
import 'package:currency_converter/services/firebase_service.dart';
import 'package:flutter/material.dart';
import '../../../utils/modern_constants.dart' as modern_constants;
import '../../../utils/responsive_helper.dart';

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
    'GBP/JPY', 'AUD/USD', 'USD/CAD', 'NZD/USD',
    'USD/CHF', 'AUD/JPY', 'CAD/JPY', 'GBP/AUD',
    'EUR/JPY', 'EUR/AUD', 'GBP/CAD', 'AUD/CAD',
    'EUR/CHF', 'GBP/CHF', 'AUD/NZD', 'NZD/CAD',
    'USD/SGD', 'USD/HKD', 'USD/CNY', 'USD/INR',
    'USD/SEK', 'USD/NOK', 'USD/DKK', 'USD/ZAR',
    'USD/PKR', 'USD/TRY', 'USD/MXN', 'USD/BRL',
    'INR/PKR', 'INR/JPY', 'INR/EUR', 'INR/USD',
    'PKR/JPY', 'PKR/EUR', 'PKR/USD', 'PKR/GBP',
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
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      backgroundColor: modern_constants.ModernConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: modern_constants.ModernConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: modern_constants.ModernConstants.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.chart == null ? 'Add Market Chart' : 'Edit Market Chart',
          style: TextStyle(
            color: modern_constants.ModernConstants.textPrimary,
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: modern_constants.ModernConstants.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: modern_constants.ModernConstants.cardShadow,
                  border: Border.all(
                    color: modern_constants.ModernConstants.textTertiary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 20 : 24),
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
            Icon(
              Icons.analytics_rounded, 
              color: modern_constants.ModernConstants.primaryPurple, 
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              'Technical Indicators',
              style: TextStyle(
                fontSize: 14,
                color: modern_constants.ModernConstants.textSecondary,
                fontWeight: FontWeight.w600,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: modern_constants.ModernConstants.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Add indicator (e.g., RSI, MACD, SMA)...',
                  hintStyle: TextStyle(color: modern_constants.ModernConstants.textTertiary),
                  filled: true,
                  fillColor: modern_constants.ModernConstants.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: modern_constants.ModernConstants.textTertiary.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: modern_constants.ModernConstants.primaryPurple,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: modern_constants.ModernConstants.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _addTechnicalIndicator,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Indicators List
        if (_technicalIndicators.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: modern_constants.ModernConstants.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.3),
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
                    color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        indicator,
                        style: TextStyle(
                          color: modern_constants.ModernConstants.primaryPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeTechnicalIndicator(index),
                        child: Icon(
                          Icons.close,
                          color: modern_constants.ModernConstants.primaryPurple,
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
        color: modern_constants.ModernConstants.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_rounded, 
                color: modern_constants.ModernConstants.primaryPurple, 
                size: 20
              ),
              const SizedBox(width: 8),
              Text(
                'Chart Settings',
                style: TextStyle(
                  fontSize: 14,
                  color: modern_constants.ModernConstants.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Show Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Show Grid',
                style: TextStyle(
                  color: modern_constants.ModernConstants.textPrimary,
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
                activeColor: modern_constants.ModernConstants.primaryPurple,
              ),
            ],
          ),
          
          // Show Volume
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Show Volume',
                style: TextStyle(
                  color: modern_constants.ModernConstants.textPrimary,
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
                activeColor: modern_constants.ModernConstants.primaryPurple,
              ),
            ],
          ),
          
          // Theme
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Theme',
                style: TextStyle(
                  color: modern_constants.ModernConstants.textPrimary,
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
                dropdownColor: modern_constants.ModernConstants.cardBackground,
                items: ['dark', 'light'].map((String theme) {
                  return DropdownMenuItem<String>(
                    value: theme,
                    child: Text(
                      theme.toUpperCase(),
                      style: TextStyle(
                        color: modern_constants.ModernConstants.textPrimary, 
                        fontSize: 12
                      ),
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
        color: modern_constants.ModernConstants.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.data_usage_rounded, 
                color: modern_constants.ModernConstants.primaryPurple, 
                size: 20
              ),
              const SizedBox(width: 8),
              Text(
                'Chart Data',
                style: TextStyle(
                  fontSize: 14,
                  color: modern_constants.ModernConstants.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Data Points:',
                style: TextStyle(
                  color: modern_constants.ModernConstants.textPrimary,
                  fontSize: 14,
                ),
              ),
              Text(
                '${_dataPoints.length}',
                style: TextStyle(
                  color: modern_constants.ModernConstants.primaryPurple,
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
                Text(
                  'Date Range:',
                  style: TextStyle(
                    color: modern_constants.ModernConstants.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_dataPoints.first.timestamp.day}/${_dataPoints.first.timestamp.month} - ${_dataPoints.last.timestamp.day}/${_dataPoints.last.timestamp.month}',
                  style: TextStyle(
                    color: modern_constants.ModernConstants.primaryPurple,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _generateSampleDataPoints,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Regenerate Sample Data',
                    style: TextStyle(
                      fontSize: 12,
                      color: modern_constants.ModernConstants.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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
            modern_constants.ModernConstants.primaryPurple.withOpacity(0.1),
            modern_constants.ModernConstants.primaryPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: modern_constants.ModernConstants.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              widget.chart == null ? Icons.add_chart : Icons.edit_note_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chart == null ? 'Create Market Chart' : 'Edit Market Chart',
                  style: TextStyle(
                    color: modern_constants.ModernConstants.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.chart == null 
                    ? 'Add new market chart with technical analysis'
                    : 'Update chart information and settings',
                  style: TextStyle(
                    color: modern_constants.ModernConstants.textSecondary,
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
            Icon(
              icon, 
              color: modern_constants.ModernConstants.primaryPurple, 
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: modern_constants.ModernConstants.textSecondary,
                fontWeight: FontWeight.w600,
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: modern_constants.ModernConstants.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: modern_constants.ModernConstants.textTertiary),
            filled: true,
            fillColor: modern_constants.ModernConstants.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: modern_constants.ModernConstants.textTertiary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: modern_constants.ModernConstants.primaryPurple,
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
            Icon(
              icon, 
              color: modern_constants.ModernConstants.primaryPurple, 
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: modern_constants.ModernConstants.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: modern_constants.ModernConstants.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: modern_constants.ModernConstants.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: modern_constants.ModernConstants.textTertiary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: modern_constants.ModernConstants.primaryPurple,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          dropdownColor: modern_constants.ModernConstants.cardBackground,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(color: modern_constants.ModernConstants.textPrimary),
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
        color: modern_constants.ModernConstants.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_rounded, 
                color: modern_constants.ModernConstants.primaryPurple, 
                size: 20
              ),
              const SizedBox(width: 8),
              Text(
                'Active Chart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: modern_constants.ModernConstants.textPrimary,
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
            activeColor: modern_constants.ModernConstants.primaryPurple,
            activeTrackColor: modern_constants.ModernConstants.primaryPurple.withOpacity(0.3),
            inactiveThumbColor: modern_constants.ModernConstants.textTertiary,
            inactiveTrackColor: modern_constants.ModernConstants.textTertiary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: modern_constants.ModernConstants.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: modern_constants.ModernConstants.primaryPurple.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _saveChart,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                      Icon(
                        widget.chart == null ? Icons.add : Icons.update,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.chart == null ? 'Add Chart' : 'Update Chart',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
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
            backgroundColor: modern_constants.ModernConstants.primaryPurple,
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
