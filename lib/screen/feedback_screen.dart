import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class UserFeedbackScreen extends StatefulWidget {
  const UserFeedbackScreen({super.key});

  @override
  State<UserFeedbackScreen> createState() => _UserFeedbackScreenState();
}

class _UserFeedbackScreenState extends State<UserFeedbackScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _issueFormKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  
  // State
  String _feedbackType = 'General Feedback';
  String _issueType = 'Bug Report';
  String _priority = 'Medium';
  double _rating = 4.0;
  bool _isSubmitting = false;
  bool _isSubmittingIssue = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _feedbackController.dispose();
    _issueController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text('User Feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 10, 108, 236),
          labelColor: const Color.fromARGB(255, 10, 108, 236),
          unselectedLabelColor: const Color(0xFF8A94A6),
          tabs: const [Tab(text: 'Feedback'), Tab(text: 'Report Issue'), Tab(text: 'Rate App')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFeedbackTab(), _buildReportIssueTab(), _buildRateAppTab()],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share Your Feedback', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Help us improve by sharing your thoughts.', style: TextStyle(color: Color(0xFF8A94A6), fontSize: 16)),
            const SizedBox(height: 24),
            
            // Feedback Type
            _buildContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.category, 'Feedback Type'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['General Feedback', 'Feature Request', 'UI/UX Feedback', 'Performance', 'Suggestion']
                        .map((type) => _buildFilterChip(type, _feedbackType, (value) => setState(() => _feedbackType = value)))
                        .toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildTextField(_nameController, 'Your Name (Optional)', Icons.person),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Email (Optional)', Icons.email, validator: _emailValidator),
            const SizedBox(height: 16),
            _buildTextField(_feedbackController, 'Your Feedback *', Icons.feedback, maxLines: 5, validator: _feedbackValidator),
            const SizedBox(height: 24),
            
            _buildSubmitButton('Submit Feedback', _isSubmitting, _submitFeedback, const Color.fromARGB(255, 10, 108, 236)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportIssueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _issueFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report an Issue', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Found a bug? Let us know so we can fix it.', style: TextStyle(color: Color(0xFF8A94A6), fontSize: 16)),
            const SizedBox(height: 24),
            
            // Issue Type
            _buildContainer(
              borderColor: Colors.red.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.bug_report, 'Issue Type', Colors.red),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Bug Report', 'App Crash', 'Login Issue', 'Data Sync', 'Performance', 'UI Problem', 'Other']
                        .map((type) => _buildFilterChip(type, _issueType, (value) => setState(() => _issueType = value), Colors.red))
                        .toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Priority
            _buildContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.priority_high, 'Priority Level'),
                  const SizedBox(height: 16),
                  Row(
                    children: ['Low', 'Medium', 'High', 'Critical'].map((priority) {
                      final isSelected = _priority == priority;
                      final color = _getPriorityColor(priority);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildFilterChip(priority, _priority, (value) => setState(() => _priority = value), color),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildTextField(_issueController, 'Describe the Issue *', Icons.description, maxLines: 5, validator: _issueValidator),
            const SizedBox(height: 16),
            _buildTextField(_stepsController, 'Steps to Reproduce (Optional)', Icons.list_alt, maxLines: 4),
            const SizedBox(height: 24),
            
            _buildSubmitButton('Report Issue', _isSubmittingIssue, _submitIssueReport, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildRateAppTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Rate Our App', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your rating helps us improve.', style: TextStyle(color: Color(0xFF8A94A6), fontSize: 16)),
          const SizedBox(height: 32),
          
          _buildContainer(
            child: Column(
              children: [
                const Icon(Icons.currency_exchange, size: 64, color: Color.fromARGB(255, 10, 108, 236)),
                const SizedBox(height: 16),
                const Text('Currency Converter', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('How would you rate your experience?', style: TextStyle(color: Color(0xFF8A94A6), fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => _rating = index + 1.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(_getRatingText(_rating), style: const TextStyle(color: Color.fromARGB(255, 10, 108, 236), fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: _submitRating, style: _buttonStyle(const Color.fromARGB(255, 10, 108, 236)), child: const Text('Submit Rating'))),
              const SizedBox(width: 16),
              Expanded(child: OutlinedButton(onPressed: _rateOnStore, style: _outlinedButtonStyle(), child: const Text('Rate on Store'))),
            ],
          ),
          
          const SizedBox(height: 32),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildContainer({required Widget child, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, [Color? color]) {
    return Row(
      children: [
        Icon(icon, color: color ?? const Color.fromARGB(255, 10, 108, 236), size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFilterChip(String label, String selectedValue, Function(String) onSelected, [Color? color]) {
    final isSelected = selectedValue == label;
    final chipColor = color ?? const Color.fromARGB(255, 10, 108, 236);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(label),
      backgroundColor: const Color(0xFF0F0F23),
      selectedColor: chipColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? chipColor : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(color: isSelected ? chipColor : const Color(0xFF8A94A6)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A94A6)),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 20.0) : 0),
          child: Icon(icon, color: const Color(0xFF8A94A6)),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8A94A6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 10, 108, 236))),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
      ),
      validator: validator,
    );
  }

  Widget _buildSubmitButton(String text, bool isLoading, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _buttonStyle(color),
        child: isLoading
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                SizedBox(width: 12),
                Text('Submitting...'),
              ])
            : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStats() {
    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Feedback Stats', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('Avg Rating', '4.2', Icons.star, Colors.amber)),
              Expanded(child: _buildStatItem('Reviews', '1,234', Icons.reviews, const Color.fromARGB(255, 10, 108, 236))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('Resolved', '98%', Icons.check_circle, Colors.green)),
              Expanded(child: _buildStatItem('Response', '< 24h', Icons.schedule, Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFF0F0F23), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color.fromARGB(255, 10, 108, 236),
      side: const BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low': return Colors.green;
      case 'Medium': return Colors.orange;
      case 'High': return Colors.red;
      case 'Critical': return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return 'Rate Us';
    }
  }

  String? _emailValidator(String? value) {
    if (value != null && value.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _feedbackValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your feedback';
    if (value.trim().length < 10) return 'Feedback should be at least 10 characters';
    return null;
  }

  String? _issueValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please describe the issue';
    if (value.trim().length < 20) return 'Please provide more details (at least 20 characters)';
    return null;
  }

  void _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    
    _sendFeedbackEmail(
      type: _feedbackType,
      name: _nameController.text.trim().isEmpty ? 'Anonymous User' : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? 'No email provided' : _emailController.text.trim(),
      feedback: _feedbackController.text.trim(),
    );
    
    _nameController.clear();
    _emailController.clear();
    _feedbackController.clear();
    setState(() => _isSubmitting = false);
    _showSuccessSnackBar('Thank you for your feedback!');
  }

  void _submitIssueReport() async {
    if (!_issueFormKey.currentState!.validate()) return;
    setState(() => _isSubmittingIssue = true);
    await Future.delayed(const Duration(seconds: 2));
    
    _sendIssueReportEmail(
      type: _issueType,
      priority: _priority,
      issue: _issueController.text.trim(),
      steps: _stepsController.text.trim(),
    );
    
    _issueController.clear();
    _stepsController.clear();
    setState(() => _isSubmittingIssue = false);
    _showSuccessSnackBar('Issue reported successfully!');
  }

  void _submitRating() {
    _sendRatingEmail(_rating);
    _showSuccessSnackBar('Thank you for rating our app!');
  }

  void _rateOnStore() {
    _showSuccessSnackBar('Redirecting to app store...');
  }

  Future<void> _sendFeedbackEmail({required String type, required String name, required String email, required String feedback}) async {
    try {
      final emailUrl = 'mailto:alimuhammadali8753@gmail.com?subject=${Uri.encodeComponent('User Feedback - $type')}&body=${Uri.encodeComponent('Name: $name\nEmail: $email\nType: $type\n\nFeedback:\n$feedback')}';
      final uri = Uri.parse(emailUrl);
      if (await launcher.canLaunchUrl(uri)) {
        await launcher.launchUrl(uri);
      }
    } catch (e) {
      _showErrorSnackBar('Could not launch email client');
    }
  }

  Future<void> _sendIssueReportEmail({required String type, required String priority, required String issue, required String steps}) async {
    try {
      final emailUrl = 'mailto:alimuhammadali8753@gmail.com?subject=${Uri.encodeComponent('Issue Report - $type')}&body=${Uri.encodeComponent('Type: $type\nPriority: $priority\n\nIssue:\n$issue\n\nSteps:\n$steps')}';
      final uri = Uri.parse(emailUrl);
      if (await launcher.canLaunchUrl(uri)) {
        await launcher.launchUrl(uri);
      }
    } catch (e) {
      _showErrorSnackBar('Could not launch email client');
    }
  }

  Future<void> _sendRatingEmail(double rating) async {
    try {
      final emailUrl = 'mailto:alimuhammadali8753@gmail.com?subject=${Uri.encodeComponent('App Rating')}&body=${Uri.encodeComponent('User rated the app: ${rating.toInt()} stars\nRating: ${_getRatingText(rating)}')}';
      final uri = Uri.parse(emailUrl);
      if (await launcher.canLaunchUrl(uri)) {
        await launcher.launchUrl(uri);
      }
    } catch (e) {
      _showErrorSnackBar('Could not launch email client');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color.fromARGB(255, 10, 108, 236), behavior: SnackBarBehavior.floating),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
    );
  }
}
