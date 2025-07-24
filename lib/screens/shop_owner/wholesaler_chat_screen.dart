import 'package:flutter/material.dart';

class WholesalerChatScreen extends StatefulWidget {
  final String wholesalerName;
  final String wholesalerInitial;

  const WholesalerChatScreen({
    super.key,
    required this.wholesalerName,
    required this.wholesalerInitial,
  });

  @override
  State<WholesalerChatScreen> createState() => _WholesalerChatScreenState();
}

class _WholesalerChatScreenState extends State<WholesalerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialMessages() {
    // Sample conversation based on wholesaler
    Map<String, List<Map<String, dynamic>>> initialChats = {
      'রহমান ট্রেডার্স': [
        {
          'message': 'আপনার দোকানের জন্য নতুন দামের তালিকা পাঠাচ্ছি',
          'isFromMe': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'type': 'text'
        },
        {
          'message': 'চাল সরু: ৭৮ টাকা কেজি\nসয়াবিন তেল: ১৬৫ টাকা লিটার\nমসুর ডাল: ১১৫ টাকা কেজি',
          'isFromMe': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: 1)),
          'type': 'price_list'
        },
        {
          'message': 'ধন্যবাদ! এই দামে ১০০ কেজি চাল দরকার',
          'isFromMe': true,
          'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          'type': 'text'
        },
        {
          'message': 'আগামীকাল সকালে ডেলিভারি দিতে পারবো',
          'isFromMe': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'type': 'text'
        }
      ],
      'করিম এন্টারপ্রাইজ': [
        {
          'message': 'আপনার অর্ডার কনফার্ম করেছি। আজ বিকেলে ডেলিভারি দেব।',
          'isFromMe': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
          'type': 'text'
        },
        {
          'message': 'অসাধারণ! ধন্যবাদ ভাই',
          'isFromMe': true,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
          'type': 'text'
        }
      ],
      'আলম ইমপোর্ট': [
        {
          'message': 'সব পণ্য স্টক আভেইলেবল আছে। কী পরিমাণ লাগবে?',
          'isFromMe': false,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 45)),
          'type': 'text'
        }
      ],
      'নিউ সুন্দরবন': [
        {
          'message': 'আগামীকাল সকাল ১০টায় আপনার দোকানে ডেলিভারি দেব',
          'isFromMe': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'type': 'text'
        },
        {
          'message': 'মাল পৌঁছানোর সময় ফোন করবেন',
          'isFromMe': false,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 55)),
          'type': 'text'
        },
        {
          'message': 'অবশ্যই! গেট দিয়ে ঢুকে ডান পাশে আমাদের দোকান',
          'isFromMe': true,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 50)),
          'type': 'text'
        }
      ],
    };

    setState(() {
      _messages.addAll(initialChats[widget.wholesalerName] ?? []);
    });

    // Scroll to bottom after loading messages
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

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      setState(() {
        _messages.add({
          'message': messageText,
          'isFromMe': true,
          'timestamp': DateTime.now(),
          'type': 'text'
        });
      });
      _messageController.clear();
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      // Simulate wholesaler response after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        _simulateWholesalerResponse(messageText);
      });
    }
  }

  void _simulateWholesalerResponse(String userMessage) {
    String response = "ধন্যবাদ! আপনার বার্তা পেয়েছি।";
    
    if (userMessage.contains('দাম') || userMessage.contains('price')) {
      response = "আপডেট দাম পাঠাচ্ছি। একটু অপেক্ষা করুন।";
    } else if (userMessage.contains('অর্ডার') || userMessage.contains('order')) {
      response = "অর্ডার কনফার্ম! আগামীকাল ডেলিভারি দেব।";
    } else if (userMessage.contains('ডেলিভারি') || userMessage.contains('delivery')) {
      response = "ডেলিভারির সময় জানিয়ে দেব। ধন্যবাদ!";
    } else if (userMessage.contains('স্টক') || userMessage.contains('stock')) {
      response = "সব পণ্য স্টক আছে। কোন পণ্য লাগবে?";
    }

    if (mounted) {
      setState(() {
        _messages.add({
          'message': response,
          'isFromMe': false,
          'timestamp': DateTime.now(),
          'type': 'text'
        });
      });

      // Scroll to bottom
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
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Quick Messages",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.price_check, color: Colors.green),
              title: const Text("Request Price List"),
              onTap: () {
                Navigator.pop(context);
                _sendQuickMessage("আজকের দামের তালিকা পাঠান");
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.blue),
              title: const Text("Place Order"),
              onTap: () {
                Navigator.pop(context);
                _sendQuickMessage("নতুন অর্ডার দিতে চাই");
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.orange),
              title: const Text("Check Stock"),
              onTap: () {
                Navigator.pop(context);
                _sendQuickMessage("পণ্যের স্টক আছে কিনা জানান");
              },
            ),
            ListTile(
              leading: const Icon(Icons.delivery_dining, color: Colors.purple),
              title: const Text("Delivery Status"),
              onTap: () {
                Navigator.pop(context);
                _sendQuickMessage("ডেলিভারির অবস্থা জানতে চাই");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return "এখনই";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes} মিনিট আগে";
    } else if (difference.inDays < 1) {
      return "${difference.inHours} ঘণ্টা আগে";
    } else {
      return "${timestamp.day}/${timestamp.month}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Text(
                widget.wholesalerInitial,
                style: TextStyle(
                  color: Colors.purple[600],
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
                    widget.wholesalerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "অনলাইন",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Calling ${widget.wholesalerName}..."),
                  backgroundColor: Colors.green[600],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showQuickActions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
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
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add, color: Colors.purple[600]),
                  onPressed: _showQuickActions,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "বার্তা লিখুন...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple[600],
                    borderRadius: BorderRadius.circular(25),
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

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isFromMe = message['isFromMe'] as bool;
    final messageType = message['type'] as String;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple[100],
              child: Text(
                widget.wholesalerInitial,
                style: TextStyle(
                  color: Colors.purple[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromMe ? Colors.purple[600] : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isFromMe ? 20 : 4),
                  bottomRight: Radius.circular(isFromMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (messageType == 'price_list')
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isFromMe ? Colors.purple[700] : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.price_check,
                            size: 16,
                            color: isFromMe ? Colors.white : Colors.green[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Price List",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isFromMe ? Colors.white : Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  Text(
                    message['message'] as String,
                    style: TextStyle(
                      color: isFromMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message['timestamp'] as DateTime),
                    style: TextStyle(
                      color: isFromMe ? Colors.purple[200] : Colors.grey[600],
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
              backgroundColor: Colors.green[100],
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.green[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
