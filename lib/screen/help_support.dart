import 'package:currency_converter/model/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../services/customer_care_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFaqIndex = -1;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String _selectedSubject = 'general';

  // Your email configuration
  static const String supportEmail = 'alimuhammadali8753@gmail.com';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Initialize customer care collections
    CustomerCareService.initializeCollections();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 10, 108, 236),
          labelColor: const Color.fromARGB(255, 10, 108, 236),
          unselectedLabelColor: const Color(0xFF8A94A6),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          isScrollable: true,
          tabs: const [
            Tab(text: 'FAQs'),
            Tab(text: 'Guides'),
            Tab(text: 'Contact'),
            Tab(text: 'Live Chat'),
            Tab(text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFaqTab(),
          _buildGuidesTab(),
          _buildContactTab(),
          _buildLiveChatTab(),
          _buildAboutTab(),
        ],
      ),
    );
  }

  Widget _buildFaqTab() {
    final faqs = [
      {
        'question': 'How do I set up rate alerts?',
        'answer': 'Go to Rate Alerts section, tap the + button, select your currency pair, set your target rate, and choose alert conditions. You\'ll receive notifications when your target is reached.',
      },
      {
        'question': 'Why are my notifications not working?',
        'answer': 'Check your notification settings in the app and device settings. Ensure notifications are enabled for the Currency Converter app and check if Do Not Disturb mode is off.',
      },
      {
        'question': 'How accurate are the exchange rates?',
        'answer': 'Our rates are updated in real-time from multiple reliable financial data providers. However, actual exchange rates may vary slightly depending on your bank or exchange service.',
      },
      {
        'question': 'Can I use the app offline?',
        'answer': 'The app requires internet connection for real-time rates. However, the last fetched rates are cached and can be viewed offline, though they may not be current.',
      },
      {
        'question': 'How do I change my notification preferences?',
        'answer': 'Go to Settings > Notification Settings. Here you can customize alert types, frequency, quiet hours, and preferred currencies for notifications.',
      },
      {
        'question': 'Is my data secure?',
        'answer': 'Yes, we use industry-standard encryption to protect your data. We don\'t store sensitive financial information and follow strict privacy policies.',
      },
      {
        'question': 'How do I delete my account?',
        'answer': 'Go to Profile > Settings > Account Settings > Delete Account. Note that this action is irreversible and will remove all your data.',
      },
      {
        'question': 'Can I export my rate alert history?',
        'answer': 'Yes, go to Rate Alerts > History > Export. You can export your data in CSV or PDF format for your records.',
      },
      {
        'question': 'What currencies are supported?',
        'answer': 'We support over 170+ currencies including all major world currencies like USD, EUR, GBP, JPY, PKR, INR, and many more. The list is regularly updated.',
      },
      {
        'question': 'How often are rates updated?',
        'answer': 'Exchange rates are updated every 60 seconds during market hours. We fetch data from multiple reliable sources to ensure accuracy.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        final isExpanded = _selectedFaqIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpanded 
                  ? const Color.fromARGB(255, 10, 108, 236).withOpacity(0.5)
                  : Colors.transparent,
            ),
          ),
          child: ExpansionTile(
            title: Text(
              faq['question']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color.fromARGB(255, 10, 108, 236),
            ),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            onExpansionChanged: (expanded) {
              setState(() {
                _selectedFaqIndex = expanded ? index : -1;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  faq['answer']!,
                  style: const TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuidesTab() {
    final List<Map<String, dynamic>> guides = [
      {
        'title': 'Getting Started',
        'description': 'Learn the basics of using Currency Converter',
        'icon': Icons.play_circle_outline,
        'steps': [
          'Download and install the app',
          'Create your account or sign in',
          'Set your preferred base currency',
          'Explore real-time exchange rates',
          'Set up your first rate alert',
        ],
      },
      {
        'title': 'Setting Up Rate Alerts',
        'description': 'Step-by-step guide to create effective alerts',
        'icon': Icons.notifications_active,
        'steps': [
          'Navigate to Rate Alerts section',
          'Tap the + button to create new alert',
          'Select your currency pair (e.g., USD to EUR)',
          'Set your target rate',
          'Choose alert conditions (above/below/exact)',
          'Set frequency and expiration',
          'Save your alert',
        ],
      },
      {
        'title': 'Managing Notifications',
        'description': 'Customize your notification experience',
        'icon': Icons.notification_add_sharp,
        'steps': [
          'Go to Settings > Notification Settings',
          'Enable/disable notification types',
          'Set quiet hours for uninterrupted time',
          'Choose preferred currencies',
          'Adjust alert frequency',
          'Test notifications',
        ],
      },
      {
        'title': 'Portfolio Tracking',
        'description': 'Track your currency holdings and performance',
        'icon': Icons.account_balance_wallet,
        'steps': [
          'Navigate to Portfolio section',
          'Add your currency holdings',
          'Set purchase rates and amounts',
          'Monitor real-time performance',
          'View profit/loss calculations',
          'Export portfolio reports',
        ],
      },
      {
        'title': 'Advanced Features',
        'description': 'Make the most of advanced app features',
        'icon': Icons.settings,
        'steps': [
          'Set up multiple watchlists',
          'Use historical rate charts',
          'Configure custom alert sounds',
          'Set up email notifications',
          'Use dark/light theme options',
          'Export data for analysis',
        ],
      },
      {
        'title': 'Troubleshooting',
        'description': 'Common issues and their solutions',
        'icon': Icons.build,
        'steps': [
          'Check your internet connection',
          'Update the app to latest version',
          'Clear app cache if needed',
          'Restart the app',
          'Check notification permissions',
          'Contact support if issue persists',
        ],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guides.length,
      itemBuilder: (context, index) {
        final guide = guides[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
            ),
          ),
          child: InkWell(
            onTap: () => _showGuideDetails(context, guide),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      guide['icon'] as IconData,
                      color: const Color.fromARGB(255, 10, 108, 236),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          guide['description'] as String,
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF8A94A6),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get in Touch',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'re here to help! Choose the best way to reach us.',
            style: TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          
          // Contact Methods
          _buildContactMethod(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: supportEmail,
            description: 'Get detailed help via email',
            onTap: () => _launchDirectEmail(),
          ),
          const SizedBox(height: 16),
          
          _buildContactMethod(
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: '+92 300 1234567',
            description: 'Mon-Fri, 9 AM - 6 PM PKT',
            onTap: () => _launchPhone(),
          ),
          const SizedBox(height: 16),
          
          _buildContactMethod(
            icon: Icons.chat,
            title: 'WhatsApp',
            subtitle: 'Quick Response',
            description: 'Message us on WhatsApp',
            onTap: () => _launchWhatsApp(),
          ),
          const SizedBox(height: 16),
          
          _buildContactMethod(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            subtitle: 'Help us improve',
            description: 'Report issues or suggest features',
            onTap: () => _showBugReportDialog(),
          ),
          
          const SizedBox(height: 32),
          
          // Enhanced Contact Form with Firebase Integration
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Contact Form',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fill out the form below and we\'ll get back to you within 24 hours.',
                  style: TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                _buildEnhancedContactForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveChatTab() {
    return LiveChatWidget();
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.currency_exchange,
                size: 64,
                color: Color.fromARGB(255, 10, 108, 236),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          const Center(
            child: Text(
              'Currency Converter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          const Center(
            child: Text(
              'Version 2.1.0',
              style: TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          _buildInfoSection(
            'About the App',
            'Currency Converter is your comprehensive solution for real-time currency exchange rates, smart alerts, and portfolio tracking. Built with precision and user experience in mind, our app helps you stay updated with the latest currency trends and make informed financial decisions.',
          ),
          
          _buildInfoSection(
            'Key Features',
            '• Real-time exchange rates from multiple sources\n'
            '• Smart rate alerts with customizable conditions\n'
            '• Portfolio tracking and performance analysis\n'
            '• Push notifications and email alerts\n'
            '• Dark theme and intuitive interface\n'
            '• Offline rate caching\n'
            '• Export capabilities for data analysis\n'
            '• Support for 170+ currencies\n'
            '• Historical rate charts\n'
            '• Multiple watchlists',
          ),
          
          _buildInfoSection(
            'Privacy & Security',
            'We take your privacy seriously. All data is encrypted using industry-standard protocols and we follow strict security practices. We don\'t share your personal information with third parties and all financial data is processed securely.',
          ),
          
          _buildInfoSection(
            'Terms & Conditions',
            'By using this app, you agree to our terms of service and privacy policy. Exchange rates are for informational purposes only and actual rates may vary. Please consult with financial advisors for investment decisions.',
          ),
          
          _buildInfoSection(
            'Data Sources',
            'Our exchange rates are sourced from multiple reliable financial data providers including central banks, financial institutions, and market data vendors to ensure accuracy and reliability.',
          ),
          
          const SizedBox(height: 24),
          
          // App Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                _buildAppInfoRow('Version', '2.1.0'),
                _buildAppInfoRow('Build', '2024.01.15'),
                _buildAppInfoRow('Size', '25.4 MB'),
                _buildAppInfoRow('Developer', 'Ali Muhammad'),
                _buildAppInfoRow('Support', supportEmail),
                _buildAppInfoRow('Last Updated', 'January 2024'),
                _buildAppInfoRow('Compatibility', 'Android 6.0+'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Social Links
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connect With Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSocialButton(Icons.email, 'Email', () => _launchDirectEmail()),
                    _buildSocialButton(Icons.phone, 'Call', () => _launchPhone()),
                    _buildSocialButton(Icons.chat, 'WhatsApp', () => _launchWhatsApp()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 10, 108, 236)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color.fromARGB(255, 10, 108, 236),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedContactForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Field
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Your Name *',
              labelStyle: const TextStyle(color: Color(0xFF8A94A6)),
              prefixIcon: const Icon(Icons.person, color: Color(0xFF8A94A6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF8A94A6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Email Field
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Email Address *',
              labelStyle: const TextStyle(color: Color(0xFF8A94A6)),
              prefixIcon: const Icon(Icons.email, color: Color(0xFF8A94A6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF8A94A6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Subject Field
          DropdownButtonFormField<String>(
            value: _selectedSubject,
            style: const TextStyle(color: Colors.white),
            dropdownColor: const Color(0xFF1A1A2E),
            decoration: InputDecoration(
              labelText: 'Subject',
              labelStyle: const TextStyle(color: Color(0xFF8A94A6)),
              prefixIcon: const Icon(Icons.subject, color: Color(0xFF8A94A6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF8A94A6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'general', child: Text('General Inquiry')),
              DropdownMenuItem(value: 'bug', child: Text('Bug Report')),
              DropdownMenuItem(value: 'feature', child: Text('Feature Request')),
              DropdownMenuItem(value: 'account', child: Text('Account Issue')),
              DropdownMenuItem(value: 'rates', child: Text('Rate Alert Issue')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSubject = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Message Field
          TextFormField(
            controller: _messageController,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your message';
              }
              if (value.trim().length < 10) {
                return 'Message should be at least 10 characters';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Your Message *',
              labelStyle: const TextStyle(color: Color(0xFF8A94A6)),
              prefixIcon: const Icon(Icons.message, color: Color(0xFF8A94A6)),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF8A94A6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitContactForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 10, 108, 236),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Sending...'),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send),
                        SizedBox(width: 8),
                        Text(
                          'Send Message',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Alternative contact info
          Text(
            'Or email us directly at $supportEmail',
            style: const TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color.fromARGB(255, 10, 108, 236),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 10, 108, 236),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF8A94A6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF8A94A6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showGuideDetails(BuildContext context, Map<String, dynamic> guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              guide['icon'] as IconData,
              color: const Color.fromARGB(255, 10, 108, 236),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                guide['title'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guide['description'] as String,
                style: const TextStyle(
                  color: Color(0xFF8A94A6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Steps:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...((guide['steps'] as List<String>).asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 10, 108, 236),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            color: Color(0xFF8A94A6),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it!',
              style: TextStyle(color: Color.fromARGB(255, 10, 108, 236)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Color.fromARGB(255, 10, 108, 236)),
            SizedBox(width: 12),
            Text(
              'Report a Bug',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help us improve by reporting bugs or suggesting new features.',
              style: TextStyle(color: Color(0xFF8A94A6), fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'What to include:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Detailed description of the issue\n'
              '• Steps to reproduce the problem\n'
              '• Screenshots if applicable\n'
              '• Your device model and OS version\n'
              '• App version you\'re using',
              style: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A94A6))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchDirectEmail(subject: 'Bug Report - Currency Converter App');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 10, 108, 236),
            ),
            child: const Text('Send Report'),
          ),
        ],
      ),
    );
  }

  // Enhanced email launching
  Future<void> _launchDirectEmail({String? subject}) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: supportEmail,
        query: Uri(queryParameters: {
          'subject': subject ?? 'Support Request from Currency Converter App',
        }).query,
      );
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await Clipboard.setData(ClipboardData(text: supportEmail));
        _showSuccessSnackBar('Email address copied to clipboard');
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: supportEmail));
      _showSuccessSnackBar('Email address copied to clipboard');
    }
  }

  Future<void> _launchPhone() async {
    try {
      const String phoneNumber = 'tel:+923001234567';
      final Uri phoneUri = Uri.parse(phoneNumber);
      
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await Clipboard.setData(const ClipboardData(text: '+92 300 1234567'));
        _showSuccessSnackBar('Phone number copied to clipboard');
      }
    } catch (e) {
      await Clipboard.setData(const ClipboardData(text: '+92 300 1234567'));
      _showSuccessSnackBar('Phone number copied to clipboard');
    }
  }

  Future<void> _launchWhatsApp() async {
    try {
      const String whatsappNumber = '923001234567';
      final String message = Uri.encodeComponent('Hello! I need help with the Currency Converter app.');
      final Uri whatsappUri = Uri.parse('https://wa.me/$whatsappNumber?text=$message');
      
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('WhatsApp not installed');
      }
    } catch (e) {
      _showErrorSnackBar('Could not open WhatsApp');
    }
  }

  // Enhanced form submission with Firebase integration
  Future<void> _submitContactForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String message = _messageController.text.trim();
      
      // Get subject text
      final Map<String, String> subjectMap = {
        'general': 'General Inquiry',
        'bug': 'Bug Report',
        'feature': 'Feature Request',
        'account': 'Account Issue',
        'rates': 'Rate Alert Issue',
        'other': 'Other',
      };
      
      final String subjectText = subjectMap[_selectedSubject] ?? 'General Inquiry';

      // Save to Firebase
      await CustomerCareService.submitContactForm(
        name: name,
        email: email,
        subject: subjectText,
        message: message,
      );

      // Clear form after successful submission
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      setState(() {
        _selectedSubject = 'general';
      });
      
      _showSuccessSnackBar('Contact form submitted successfully! We\'ll get back to you within 24 hours.');
      
    } catch (e) {
      _showErrorSnackBar('Error submitting form: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 10, 108, 236),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// Live Chat Widget with Firebase Integration
class LiveChatWidget extends StatefulWidget {
  @override
  _LiveChatWidgetState createState() => _LiveChatWidgetState();
}

class _LiveChatWidgetState extends State<LiveChatWidget> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isConnected = false;
  String? _chatId;
  LiveChat? _currentChat;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      setState(() {
        _isConnected = true;
      });
      
      // Start a new chat session
      final chatId = await CustomerCareService.startLiveChat();
      setState(() {
        _chatId = chatId;
      });
      
      // Listen to chat updates
      CustomerCareService.getChatStream(chatId).listen((chat) {
        if (chat != null && mounted) {
          setState(() {
            _currentChat = chat;
          });
          _scrollToBottom();
        }
      });
      
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() {
        _isConnected = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _chatId == null) return;

    try {
      // Send user message
      await CustomerCareService.sendChatMessage(
        chatId: _chatId!,
        message: text,
        isUser: true,
      );
      
      _chatController.clear();
      
      // Note: Removed auto-response - now admin will reply manually
      
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isConnected ? Icons.support_agent : Icons.offline_bolt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Support Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isConnected ? 'Online - Admin will respond soon' : 'Offline',
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Chat Messages
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: _currentChat == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 10, 108, 236),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _currentChat!.messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_currentChat!.messages[index]);
                          },
                        ),
                ),
                
                // Message Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF2A2A3E)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: const TextStyle(color: Color(0xFF8A94A6)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Color(0xFF8A94A6)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 10, 108, 236),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color.fromARGB(255, 10, 108, 236),
              child: const Icon(Icons.support_agent, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? const Color.fromARGB(255, 10, 108, 236)
                    : const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isUser && message.senderName != 'Support Agent')
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 10, 108, 236),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (!message.isUser && message.senderName != 'Support Agent')
                    const SizedBox(height: 4),
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    // End chat session when widget is disposed
    if (_chatId != null) {
      CustomerCareService.endChat(_chatId!);
    }
    super.dispose();
  }
}
