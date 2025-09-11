import 'package:flutter/material.dart';
import 'package:nitymulya/network/shop_owner_api.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/user_session.dart';

class ChatScreen extends StatefulWidget {
  final String contactId;
  final String contactType;
  final String contactName;
  final String? contactPhone;

  const ChatScreen({
    super.key,
    required this.contactId,
    required this.contactType,
    required this.contactName,
    this.contactPhone,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
    // Debug prints
    print('=== LOAD CURRENT USER DEBUG ===');
    
    try {
      final userId = await UserSession.getCurrentUserId();
      final userType = await UserSession.getCurrentUserType();
      
      print('UserSession.getCurrentUserId(): $userId');
      print('UserSession.getCurrentUserType(): $userType');
      
      setState(() {
        // If no user session found, use test user for development
        if (userId == null) {
          print('No user session found, using test user for development');
          _currentUserId = '6e25c880-75cb-4582-9821-31cdcae5335c'; // Test shop owner ID
          _currentUserType = 'shop_owner';
        } else {
          _currentUserId = userId;
          _currentUserType = userType ?? 'shop_owner';
        }
      });
      
      print('Final currentUserId: $_currentUserId');
      print('Final currentUserType: $_currentUserType');
      
      if (_currentUserId != null) {
        _loadMessages();
      } else {
        print('WARNING: No user ID found in UserSession');
        setState(() {
          _error = 'User not logged in. Please login again.';
        });
      }
    } catch (e) {
      print('Error loading user session: $e');
      setState(() {
        _error = 'Error loading user session: $e';
      });
    }
  }

  Future<void> _makePhoneCall() async {
    if (widget.contactPhone == null || widget.contactPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final phoneNumber = widget.contactPhone!;
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone dialer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMessages() async {
    if (_currentUserId == null || _currentUserType == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ShopOwnerApiService.getConversationMessages(
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
        
        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    
    // Debug prints
    print('=== SEND MESSAGE DEBUG ===');
    print('Message text: "$messageText"');
    print('Current user ID: $_currentUserId');
    print('Current user type: $_currentUserType');
    print('Contact ID: ${widget.contactId}');
    print('Contact type: ${widget.contactType}');
    
    if (messageText.isEmpty) {
      print('Message is empty, returning');
      return;
    }
    
    if (_currentUserId == null) {
      print('Current user ID is null, returning');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Add message to UI immediately for better UX
    final tempMessage = {
      'message': messageText,
      'sender_id': _currentUserId,
      'sender_type': _currentUserType,
      'receiver_id': widget.contactId,
      'receiver_type': widget.contactType,
      'created_at': DateTime.now().toIso8601String(),
      'sending': true, // Temporary flag
    };

    setState(() {
      _messages.add(tempMessage);
    });
    
    _messageController.clear();
    
    // Scroll to bottom after a brief delay to ensure the message is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      print('Sending message via API...');
      final result = await ShopOwnerApiService.sendMessage(
        senderId: _currentUserId!,
        senderType: _currentUserType!,
        receiverId: widget.contactId,
        receiverType: widget.contactType,
        message: messageText,
      );

      print('API result: $result');

      if (result['success'] == true) {
        // Replace temp message with actual message from server
        setState(() {
          _messages.removeLast();
          _messages.add(result['data']);
        });
        print('Message sent successfully');
      } else {
        // Remove temp message on failure
        setState(() {
          _messages.removeLast();
        });
        
        print('Failed to send message: ${result['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to send message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Remove temp message on error
      setState(() {
        _messages.removeLast();
      });
      
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return "এখনই";
      } else if (difference.inHours < 1) {
        return "${difference.inMinutes} মিনিট আগে";
      } else if (difference.inDays < 1) {
        return "${difference.inHours} ঘণ্টা আগে";
      } else {
        return "${dateTime.day}/${dateTime.month}";
      }
    } catch (e) {
      return "Unknown";
    }
  }

  bool _isFromCurrentUser(Map<String, dynamic> message) {
    return message['sender_id']?.toString() == _currentUserId;
  }

  String _getContactInitial() {
    if (widget.contactName.isEmpty) return 'W';
    return widget.contactName[0].toUpperCase();
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
                _getContactInitial(),
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
                    widget.contactName,
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
          if (widget.contactPhone != null)
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: _makePhoneCall,
              tooltip: "Call ${widget.contactName}",
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showQuickActions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _buildMessagesList(),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
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
                    onPressed: () {
                      print('=== SEND BUTTON PRESSED ===');
                      print('Message controller text: "${_messageController.text}"');
                      _sendMessage();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading messages..."),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMessages,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Start a conversation",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Send your first message to ${widget.contactName}",
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isFromMe = _isFromCurrentUser(message);
    final isSending = message['sending'] == true;
    
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
                _getContactInitial(),
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
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message']?.toString() ?? '',
                    style: TextStyle(
                      color: isFromMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message['created_at']?.toString() ?? ''),
                        style: TextStyle(
                          color: isFromMe ? Colors.purple[200] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (isSending) ...[
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isFromMe ? Colors.purple[200]! : Colors.grey[600]!,
                            ),
                          ),
                        ),
                      ],
                    ],
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
