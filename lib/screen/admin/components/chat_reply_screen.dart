import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currency_converter/model/chat_model.dart';
import 'package:currency_converter/services/customer_care_service.dart';
import 'package:currency_converter/utils/responsive_helper.dart';

class ChatReplyScreen extends StatefulWidget {
  final LiveChat chat;

  const ChatReplyScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatReplyScreen> createState() => _ChatReplyScreenState();
}

class _ChatReplyScreenState extends State<ChatReplyScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  LiveChat? _currentChat;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _currentChat = widget.chat;
    _listenToChatUpdates();
    _scrollToBottom();
  }

  void _listenToChatUpdates() {
    CustomerCareService.getChatStream(widget.chat.id).listen((chat) {
      if (chat != null && mounted) {
        setState(() {
          _currentChat = chat;
        });
        _scrollToBottom();
      }
    });
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

  Future<void> _sendAdminReply() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await CustomerCareService.sendAdminReply(
        chatId: widget.chat.id,
        message: message,
        adminName: 'Support Agent', // You can get this from current admin user
      );

      _messageController.clear();
      _showSuccessSnackBar('Reply sent successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to send reply: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _endChat() async {
    try {
      await CustomerCareService.endChat(widget.chat.id);
      _showSuccessSnackBar('Chat ended successfully');
      Navigator.pop(context, true); // Return true to indicate chat was ended
    } catch (e) {
      _showErrorSnackBar('Failed to end chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat with ${_currentChat?.userName ?? 'User'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _currentChat?.userEmail ?? '',
              style: const TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _currentChat?.status.toUpperCase() ?? 'UNKNOWN',
              style: TextStyle(
                color: _getStatusColor(),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_currentChat?.status == 'active')
            IconButton(
              onPressed: _endChat,
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'End Chat',
            ),
        ],
      ),
      body: Column(
        children: [
          // Chat Info Card
          Container(
            margin: const EdgeInsets.all(16),
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
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 10, 108, 236),
                  child: Text(
                    (_currentChat?.userName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentChat?.userName ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Started: ${DateFormat('MMM dd, HH:mm').format(_currentChat?.startTime ?? DateTime.now())}',
                        style: const TextStyle(
                          color: Color(0xFF8A94A6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${_currentChat?.messages.length ?? 0} messages',
                  style: const TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
                ),
              ),
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
          ),

          // Reply Input
          if (_currentChat?.status == 'active')
            Container(
              margin: const EdgeInsets.all(16),
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
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type your reply...',
                        hintStyle: const TextStyle(color: Color(0xFF8A94A6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF8A94A6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 10, 108, 236)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendAdminReply(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSending ? null : _sendAdminReply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 10, 108, 236),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Send'),
                  ),
                ],
              ),
            ),

          // Chat Ended Message
          if (_currentChat?.status == 'closed')
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This chat has been ended',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Text(
                    'Ended: ${_currentChat?.endTime != null ? DateFormat('MMM dd, HH:mm').format(_currentChat!.endTime!) : 'Unknown'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isAdmin = !message.isUser;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAdmin) ...[
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
                color: isAdmin 
                    ? const Color(0xFF2A2A3E)
                    : const Color.fromARGB(255, 10, 108, 236),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAdmin ? 4 : 16),
                  bottomRight: Radius.circular(isAdmin ? 16 : 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAdmin)
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 10, 108, 236),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (isAdmin) const SizedBox(height: 4),
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
          if (!isAdmin) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Text(
                (message.senderName)[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_currentChat?.status) {
      case 'active':
        return Colors.green;
      case 'waiting':
        return Colors.orange;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
