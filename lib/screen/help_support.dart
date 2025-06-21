import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          tabs: const [
            Tab(text: 'FAQs'),
            Tab(text: 'Guides'),
            Tab(text: 'Contact'),
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
            subtitle: 'alimuhammadali8753@gmail.com',
            description: 'Get detailed help via email',
            onTap: () => _launchEmail(),
          ),
          const SizedBox(height: 16),
          
          _buildContactMethod(
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: '+1 (555) 123-4567',
            description: 'Mon-Fri, 9 AM - 6 PM EST',
            onTap: () => _launchPhone(),
          ),
          const SizedBox(height: 16),
          
          _buildContactMethod(
            icon: Icons.chat,
            title: 'Live Chat',
            subtitle: 'Available 24/7',
            description: 'Instant help from our team',
            onTap: () => _launchChat(),
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
          
          // Contact Form
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
                const SizedBox(height: 16),
                _buildContactForm(),
              ],
            ),
          ),
        ],
      ),
    );
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
            'Currency Converter is your comprehensive solution for real-time currency exchange rates, smart alerts, and portfolio tracking. Built with precision and user experience in mind.',
          ),
          
          _buildInfoSection(
            'Key Features',
            '• Real-time exchange rates from multiple sources\n'
            '• Smart rate alerts with customizable conditions\n'
            '• Portfolio tracking and performance analysis\n'
            '• Push notifications and email alerts\n'
            '• Dark theme and intuitive interface\n'
            '• Offline rate caching\n'
            '• Export capabilities for data analysis',
          ),
          
          _buildInfoSection(
            'Privacy & Security',
            'We take your privacy seriously. All data is encrypted and we follow industry-standard security practices. We don\'t share your personal information with third parties.',
          ),
          
          _buildInfoSection(
            'Terms & Conditions',
            'By using this app, you agree to our terms of service and privacy policy. Exchange rates are for informational purposes only.',
          ),
          
          const SizedBox(height: 24),
          
          // App Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildAppInfoRow('Version', '2.1.0'),
                _buildAppInfoRow('Build', '2024.01.15'),
                _buildAppInfoRow('Size', '25.4 MB'),
                _buildAppInfoRow('Developer', 'Currency Solutions Inc.'),
                _buildAppInfoRow('Support', 'alimuhammadali8753@gmail.com'),
              ],
            ),
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

  Widget _buildContactForm() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Your Name',
            labelStyle: const TextStyle(color: Color(0xFF8A94A6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8A94A6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email Address',
            labelStyle: const TextStyle(color: Color(0xFF8A94A6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8A94A6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _messageController,
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Your Message',
            labelStyle: const TextStyle(color: Color(0xFF8A94A6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8A94A6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _submitContactForm(
              _nameController.text,
              _emailController.text,
              _messageController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 10, 108, 236),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Send Message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
        content: Column(
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
              '• Your device model and OS version',
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
              _launchEmail(subject: 'Bug Report');
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

  // ✅ Updated: Your email address for receiving contact form submissions
  Future<void> _launchEmail({String? subject, String? body}) async {
    try {
      final String emailUrl = 'mailto:alimuhammadali8753@gmail.com?subject=${Uri.encodeComponent(subject ?? 'Support Request')}&body=${Uri.encodeComponent(body ?? 'Hello Support Team,\n\n')}';
      final Uri emailUri = Uri.parse(emailUrl);
      
      if (await launcher.canLaunchUrl(emailUri)) {
        await launcher.launchUrl(emailUri);
      } else {
        _showErrorSnackBar('Could not launch email client');
      }
    } catch (e) {
      _showErrorSnackBar('Error launching email: $e');
    }
  }

  Future<void> _launchPhone() async {
    try {
      const String phoneNumber = 'tel:+15551234567';
      final Uri phoneUri = Uri.parse(phoneNumber);
      
      if (await launcher.canLaunchUrl(phoneUri)) {
        await launcher.launchUrl(phoneUri);
      } else {
        await Clipboard.setData(const ClipboardData(text: '+1 (555) 123-4567'));
        _showSuccessSnackBar('Phone number copied to clipboard');
      }
    } catch (e) {
      await Clipboard.setData(const ClipboardData(text: '+1 (555) 123-4567'));
      _showSuccessSnackBar('Phone number copied to clipboard');
    }
  }

  void _launchChat() {
    _showSuccessSnackBar('Opening live chat...');
  }

  // ✅ Updated: Contact form now sends to your email
  void _submitContactForm(String name, String email, String message) {
    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      _showErrorSnackBar('Please fill all fields');
      return;
    }
    
    // Clear the form fields after submission
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    
    // Direct email with form data to your email address
    _launchEmail(
      subject: 'Contact Form Submission from $name',
      body: 'Name: $name\nEmail: $email\n\nMessage:\n$message\n\n---\nSent from Currency Converter App',
    );
    
    _showSuccessSnackBar('Message sent successfully! We\'ll get back to you soon.');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 10, 108, 236),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
