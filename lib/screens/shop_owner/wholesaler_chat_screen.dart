import 'package:flutter/material.dart';
import 'package:nitymulya/utils/user_session.dart';

import '../../../network/wholesaler_api.dart';

class WholesalerChatScreen extends StatefulWidget {
  final String contactId;
  final String contactType;
  final String contactName;
  final String? contactPhone;

  const WholesalerChatScreen({
    super.key,
    required this.contactId,
    required this.contactType,
    required this.contactName,
    this.contactPhone,
  });

  @override
  State<WholesalerChatScreen> createState() => _WholesalerChatScreenState();
}

class _WholesalerChatScreenState extends State<WholesalerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  String? _currentUserType;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = await UserSession.getCurrentUserId();
      final userType = await UserSession.getCurrentUserType();

      if (userId != null && userType != null) {
        setState(() {
          _currentUserId = userId;
          _currentUserType = userType;
        });
        await _loadMessages();
      } else {
        setState(() {
          _error = 'Unable to identify current user';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading user session: $e';
      });
    }
  }

  Future<void> _loadMessages() async {
    if (_currentUserId == null || _currentUserType == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await WholesalerApiService.getConversationMessages(
        user1Id: _currentUserId!,
        user1Type: _currentUserType!,
        user2Id: widget.contactId,
        user2Type: widget.contactType,
      );

      if (result['success'] == true) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load messages';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading messages: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_currentUserId == null || _currentUserType == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Add message optimistically to UI
    final tempMessage = {
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'message_text': messageText,
      'sender_id': _currentUserId,
      'sender_type': _currentUserType,
      'receiver_id': widget.contactId,
      'receiver_type': widget.contactType,
      'created_at': DateTime.now().toIso8601String(),
      'is_read': false,
    };

    setState(() {
      _messages.add(tempMessage);
    });
    _scrollToBottom();

    try {
      final result = await WholesalerApiService.sendMessage(
        senderId: _currentUserId!,
        senderType: _currentUserType!,
        receiverId: widget.contactId,
        receiverType: widget.contactType,
        message: messageText,
      );

      if (result['success'] == true) {
        // Replace temp message with real one
        await _loadMessages();
      } else {
        // Remove temp message on failure
        setState(() {
          _messages.removeWhere((msg) => msg['id'] == tempMessage['id']);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Remove temp message on error
      setState(() {
        _messages.removeWhere((msg) => msg['id'] == tempMessage['id']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

  Widget _buildMessage(Map<String, dynamic> message) {
    final isFromMe = message['sender_id'] == _currentUserId;
    final messageText = message['message_text'] ?? '';
    final timestamp =
        DateTime.tryParse(message['created_at'] ?? '') ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green[100],
              child: Text(
                widget.contactName.isNotEmpty
                    ? widget.contactName[0].toUpperCase()
                    : 'W',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromMe ? Colors.green[600] : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isFromMe
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isFromMe
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageText,
                    style: TextStyle(
                      color: isFromMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color: isFromMe ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: const Icon(
                Icons.person,
                color: Colors.blue,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show time
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Other dates
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.contactName.isNotEmpty
                    ? widget.contactName[0].toUpperCase()
                    : 'W',
                style: TextStyle(
                  color: Colors.green[600],
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
                    widget.contactName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (widget.contactPhone != null)
                    Text(
                      widget.contactPhone!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMessages,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start the conversation with ${widget.contactName}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessage(_messages[index]);
                            },
                          ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.green[600]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
