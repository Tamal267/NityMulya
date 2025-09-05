import 'package:flutter/material.dart';

class CustomerChatScreen extends StatefulWidget {
  final String shopName;
  final String shopId;
  final String? orderId;
  final String? customerId;
  final String customerName;

  const CustomerChatScreen({
    super.key,
    required this.shopName,
    required this.shopId,
    this.orderId,
    this.customerId,
    required this.customerName,
  });

  @override
  State<CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> chatMessages = [];
  bool isLoading = false;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Simulate loading chat messages from API
      await Future.delayed(const Duration(seconds: 1));

      // Sample chat messages - replace with actual API call
      final sampleMessages = [
        {
          'id': '1',
          'message': 'Hello! I have a question about my order.',
          'sender_type': 'customer',
          'sender_name': widget.customerName,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'is_read': true,
        },
        {
          'id': '2',
          'message':
              'Hi! Sure, I\'d be happy to help. What would you like to know?',
          'sender_type': 'shop_owner',
          'sender_name': widget.shopName,
          'timestamp':
              DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          'is_read': true,
        },
        {
          'id': '3',
          'message': 'When will my order be ready for pickup?',
          'sender_type': 'customer',
          'sender_name': widget.customerName,
          'timestamp':
              DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          'is_read': true,
        },
        {
          'id': '4',
          'message':
              'Your order will be ready in about 30 minutes. I\'ll send you a notification when it\'s ready!',
          'sender_type': 'shop_owner',
          'sender_name': widget.shopName,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
          'is_read': false,
        },
      ];

      setState(() {
        chatMessages = sampleMessages;
        isLoading = false;
      });

      // Auto scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load messages: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      isSending = true;
    });

    try {
      // Add message to local list immediately for better UX
      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'message': messageText,
        'sender_type': 'customer',
        'sender_name': widget.customerName,
        'timestamp': DateTime.now(),
        'is_read': false,
      };

      setState(() {
        chatMessages.add(newMessage);
        _messageController.clear();
      });

      // Auto scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      // Simulate sending message to API
      await Future.delayed(const Duration(seconds: 1));

      // Simulate shop owner response (for demo purposes)
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          final autoResponse = {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'message':
                'Thank you for your message! I\'ll get back to you shortly.',
            'sender_type': 'shop_owner',
            'sender_name': widget.shopName,
            'timestamp': DateTime.now(),
            'is_read': false,
          };

          setState(() {
            chatMessages.add(autoResponse);
          });

          // Auto scroll to bottom
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
      });

      setState(() {
        isSending = false;
      });
    } catch (e) {
      setState(() {
        isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isFromCustomer = message['sender_type'] == 'customer';

    return Align(
      alignment: isFromCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment: isFromCustomer
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromCustomer ? Colors.indigo : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message['message'] ?? '',
                style: TextStyle(
                  color: isFromCustomer ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message['timestamp']),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.shopName),
            if (widget.orderId != null)
              Text(
                'Order #${widget.orderId}',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Show shop info
              _showShopInfo();
            },
            icon: const Icon(Icons.info_outline),
            tooltip: 'Shop Info',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat header with order info (if available)
          if (widget.orderId != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.indigo[50],
              child: Row(
                children: [
                  Icon(Icons.shopping_bag, color: Colors.indigo[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Chat about Order #${widget.orderId}',
                    style: TextStyle(
                      color: Colors.indigo[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatMessages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start your conversation',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: chatMessages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(chatMessages[index]);
                        },
                      ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: isSending ? null : _sendMessage,
                    icon: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShopInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.shopName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shop Information:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Shop ID: ${widget.shopId}'),
            if (widget.orderId != null) ...[
              const SizedBox(height: 4),
              Text('Related Order: #${widget.orderId}'),
            ],
            const SizedBox(height: 16),
            const Text(
              'You can contact this shop owner about your orders, product availability, and any other questions.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
