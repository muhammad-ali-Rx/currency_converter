import 'package:currency_converter/model/Rate_Alerts.dart';
import 'package:currency_converter/services/rate_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CreateAlertScreen extends StatefulWidget {
  final RateAlert? alert;
  
  const CreateAlertScreen({super.key, this.alert});

  @override
  State<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends State<CreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetRateController = TextEditingController();
  final RateAlertService _alertService = RateAlertService();
  
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  String _condition = 'above';
  bool _isLoading = false;

  final List<String> _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK', 'NZD'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.alert != null) {
      _fromCurrency = widget.alert!.fromCurrency;
      _toCurrency = widget.alert!.toCurrency;
      _condition = widget.alert!.condition;
      _targetRateController.text = widget.alert!.targetRate.toString();
    }
  }

  @override
  void dispose() {
    _targetRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: Text(
          widget.alert != null ? 'Edit Alert' : 'Create Rate Alert',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Currency Pair'),
            const SizedBox(height: 12),
            _buildCurrencySelector(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Alert Condition'),
            const SizedBox(height: 12),
            _buildConditionSelector(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Target Rate'),
            const SizedBox(height: 12),
            _buildTargetRateInput(),
            const SizedBox(height: 32),
            
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'From',
                      style: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildCurrencyDropdown(_fromCurrency, (value) {
                      setState(() => _fromCurrency = value!);
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: Color.fromARGB(255, 10, 108, 236),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To',
                      style: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildCurrencyDropdown(_toCurrency, (value) {
                      setState(() => _toCurrency = value!);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF8A94A6).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8A94A6)),
          items: _currencies.map((currency) {
            return DropdownMenuItem(
              value: currency,
              child: Text(currency),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildConditionSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildConditionOption('above', 'Above', Icons.trending_up),
          ),
          Expanded(
            child: _buildConditionOption('below', 'Below', Icons.trending_down),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionOption(String value, String label, IconData icon) {
    final isSelected = _condition == value;
    return GestureDetector(
      onTap: () => setState(() => _condition = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 10, 108, 236) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF8A94A6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8A94A6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetRateInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alert when $_fromCurrency/$_toCurrency goes $_condition:',
            style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _targetRateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0.0000',
              hintStyle: TextStyle(
                color: const Color(0xFF8A94A6).withOpacity(0.5),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a target rate';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (double.parse(value) <= 0) {
                return 'Rate must be greater than 0';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleCreateAlert,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 10, 108, 236),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              widget.alert != null ? 'Update Alert' : 'Create Alert',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Future<void> _handleCreateAlert() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final targetRate = double.parse(_targetRateController.text);
      
      if (widget.alert != null) {
        // Update existing alert
        final updatedAlert = widget.alert!.copyWith(
          fromCurrency: _fromCurrency,
          toCurrency: _toCurrency,
          targetRate: targetRate,
          condition: _condition,
          isActive: true,
          triggeredAt: null, // Reset triggered status
        );
        await _alertService.updateAlert(updatedAlert);
      } else {
        // Create new alert
        final alert = RateAlert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fromCurrency: _fromCurrency,
          toCurrency: _toCurrency,
          targetRate: targetRate,
          condition: _condition,
          createdAt: DateTime.now(),
        );
        await _alertService.addAlert(alert);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.alert != null 
                ? 'Alert updated successfully!' 
                : 'Alert created successfully!',
            ),
            backgroundColor: const Color.fromARGB(255, 10, 108, 236),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}