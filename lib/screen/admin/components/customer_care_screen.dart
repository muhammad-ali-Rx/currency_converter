import 'package:currency_converter/model/chat_model.dart';
import 'package:currency_converter/model/contact_form_model.dart';
import 'package:currency_converter/model/ticket_model.dart';
import 'package:currency_converter/screen/admin/components/chat_reply_screen.dart';
import 'package:currency_converter/services/customer_care_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerCareScreen extends StatefulWidget {
  const CustomerCareScreen({super.key});

  @override
  State<CustomerCareScreen> createState() => _CustomerCareScreenState();
}

class _CustomerCareScreenState extends State<CustomerCareScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, int> _stats = {};
  bool _isLoading = true;
  List<LiveChat>? _cachedChats;
  bool _isLoadingChats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // Load chats when switching to the chats tab
    if (_tabController.index == 2 && _cachedChats == null && !_isLoadingChats) {
      _loadChats();
    }
  }

  Future<void> _loadChats() async {
    if (_isLoadingChats) return;
    
    setState(() {
      _isLoadingChats = true;
    });
    
    try {
      final chats = await CustomerCareService.getAllChats();
      setState(() {
        _cachedChats = chats;
        _isLoadingChats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingChats = false;
      });
      _showErrorSnackBar('Failed to load chats: $e');
    }
  }

  Future<void> _refreshChats() async {
    setState(() {
      _cachedChats = null;
    });
    await _loadChats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await CustomerCareService.getStatistics();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text(
          'Customer Care',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _loadStats();
              if (_tabController.index == 2) {
                _refreshChats();
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 10, 108, 236),
          labelColor: const Color.fromARGB(255, 10, 108, 236),
          unselectedLabelColor: const Color(0xFF8A94A6),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Tickets'),
            Tab(text: 'Live Chats'),
            Tab(text: 'Contact Forms'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTicketsTab(),
          _buildChatsTab(),
          _buildContactFormsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 10, 108, 236),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Care Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Total Tickets',
                _stats['totalTickets']?.toString() ?? '0',
                Icons.confirmation_number,
                Colors.blue,
              ),
              _buildStatCard(
                'Open Tickets',
                _stats['openTickets']?.toString() ?? '0',
                Icons.pending_actions,
                Colors.orange,
              ),
              _buildStatCard(
                'Active Chats',
                _stats['activeChats']?.toString() ?? '0',
                Icons.chat,
                Colors.green,
              ),
              _buildStatCard(
                'New Forms',
                _stats['newForms']?.toString() ?? '0',
                Icons.contact_mail,
                Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'View All Tickets',
                  Icons.confirmation_number,
                  () => _tabController.animateTo(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  'Active Chats',
                  Icons.chat,
                  () => _tabController.animateTo(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Contact Forms',
                  Icons.contact_mail,
                  () => _tabController.animateTo(3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  'Refresh Data',
                  Icons.refresh,
                  _loadStats,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsTab() {
    return StreamBuilder<List<SupportTicket>>(
      stream: CustomerCareService.getTicketsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 10, 108, 236),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final tickets = snapshot.data ?? [];
        if (tickets.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, color: Color(0xFF8A94A6), size: 64),
                SizedBox(height: 16),
                Text(
                  'No support tickets found',
                  style: TextStyle(color: Color(0xFF8A94A6), fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return _buildTicketCard(ticket);
          },
        );
      },
    );
  }

  Widget _buildChatsTab() {
    // Use cached chats instead of a stream to avoid the "Stream already listened to" error
    if (_isLoadingChats) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 10, 108, 236),
        ),
      );
    }

    if (_cachedChats == null) {
      _loadChats();
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 10, 108, 236),
        ),
      );
    }

    final chats = _cachedChats!;
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, color: Color(0xFF8A94A6), size: 64),
            const SizedBox(height: 16),
            const Text(
              'No live chats found',
              style: TextStyle(color: Color(0xFF8A94A6), fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshChats,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 10, 108, 236),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshChats,
      color: const Color.fromARGB(255, 10, 108, 236),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return _buildChatCard(chat);
        },
      ),
    );
  }

  Widget _buildContactFormsTab() {
    return StreamBuilder<List<ContactForm>>(
      stream: CustomerCareService.getContactFormsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 10, 108, 236),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final forms = snapshot.data ?? [];
        if (forms.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.contact_mail_outlined, color: Color(0xFF8A94A6), size: 64),
                SizedBox(height: 16),
                Text(
                  'No contact forms found',
                  style: TextStyle(color: Color(0xFF8A94A6), fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final form = forms[index];
            return _buildContactFormCard(form);
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
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

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
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
          child: Column(
            children: [
              Icon(
                icon,
                color: const Color.fromARGB(255, 10, 108, 236),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    Color statusColor;
    switch (ticket.status) {
      case 'open':
        statusColor = Colors.orange;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        break;
      case 'closed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.description,
              style: const TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: const Color(0xFF8A94A6), size: 16),
                const SizedBox(width: 4),
                Text(
                  ticket.userName,
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 12),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(ticket.createdAt),
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateTicketStatus(ticket.id, 'in_progress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('In Progress'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateTicketStatus(ticket.id, 'closed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(LiveChat chat) {
    Color statusColor;
    switch (chat.status) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'waiting':
        statusColor = Colors.orange;
        break;
      case 'closed':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chat with ${chat.userName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    chat.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${chat.messages.length} messages',
              style: const TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, color: const Color(0xFF8A94A6), size: 16),
                const SizedBox(width: 4),
                Text(
                  chat.userEmail,
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 12),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, HH:mm').format(chat.startTime),
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openChatReply(chat),
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('Reply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 10, 108, 236),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (chat.status == 'active')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _endChat(chat.id),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('End Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactFormCard(ContactForm form) {
    Color statusColor;
    switch (form.status) {
      case 'new':
        statusColor = Colors.orange;
        break;
      case 'replied':
        statusColor = Colors.blue;
        break;
      case 'closed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    form.subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    form.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              form.message,
              style: const TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: const Color(0xFF8A94A6), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${form.name} (${form.email})',
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 12),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(form.createdAt),
                  style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateContactFormStatus(form.id, 'replied'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Mark Replied'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateContactFormStatus(form.id, 'closed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openChatReply(LiveChat chat) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatReplyScreen(chat: chat),
      ),
    );
    
    // Refresh chats if chat was ended
    if (result == true) {
      _refreshChats();
      _loadStats();
    }
  }

  Future<void> _updateTicketStatus(String ticketId, String status) async {
    try {
      await CustomerCareService.updateTicketStatus(ticketId, status);
      _showSuccessSnackBar('Ticket status updated successfully');
      _loadStats();
    } catch (e) {
      _showErrorSnackBar('Failed to update ticket status: $e');
    }
  }

  Future<void> _endChat(String chatId) async {
    try {
      await CustomerCareService.endChat(chatId);
      _showSuccessSnackBar('Chat ended successfully');
      _refreshChats();
      _loadStats();
    } catch (e) {
      _showErrorSnackBar('Failed to end chat: $e');
    }
  }

  Future<void> _updateContactFormStatus(String formId, String status) async {
    try {
      await CustomerCareService.updateContactFormStatus(formId, status);
      _showSuccessSnackBar('Contact form status updated successfully');
      _loadStats();
    } catch (e) {
      _showErrorSnackBar('Failed to update contact form status: $e');
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
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
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
      ),
    );
  }
}
