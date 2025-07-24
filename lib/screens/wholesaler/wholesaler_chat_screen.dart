import 'package:flutter/material.dart';

class WholesalerChatScreen extends StatefulWidget {
  final String shopName;
  final String shopId;

  const WholesalerChatScreen({
    super.key,
    required this.shopName,
    required this.shopId,
  });

  @override
  State<WholesalerChatScreen> createState() => _WholesalerChatScreenState();
}

class _WholesalerChatScreenState extends State<WholesalerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  
  // Sample chat messages - in a real app, this would come from a database
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChatHistory() {
    // Sample chat history - replace with actual data loading
    setState(() {
      messages = [
        {
          "id": "1",
          "sender": "shop",
          "senderName": widget.shopName,
          "message": "আসসালামু আলাইকুম। চাল সরুর বর্তমান দাম কত?",
          "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
          "type": "text",
          "isRead": true,
        },
        {
          "id": "2",
          "sender": "wholesaler",
          "senderName": "You",
          "message": "ওয়ালাইকুম আসসালাম। চাল সরু প্রিমিয়াম এখন ৮৫ টাকা কেজি। ১০০ কেজির উপর অর্ডারে ৫% ছাড়।",
          "timestamp": DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          "type": "text",
          "isRead": true,
        },
        {
          "id": "3",
          "sender": "shop",
          "senderName": widget.shopName,
          "message": "১৫০ কেজি লাগবে। কখন ডেলিভারি দিতে পারবেন?",
          "timestamp": DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          "type": "text",
          "isRead": true,
        },
        {
          "id": "4",
          "sender": "wholesaler",
          "senderName": "You",
          "message": "আগামীকাল সকালে ডেলিভারি দিতে পারব। আপনার ঠিকানা একবার কনফার্ম করুন।",
          "timestamp": DateTime.now().subtract(const Duration(minutes: 45)),
          "type": "text",
          "isRead": true,
        },
        {
          "id": "5",
          "sender": "shop",
          "senderName": widget.shopName,
          "message": "ধানমন্ডি ১৫ নম্বর, আহমেদ স্টোর। মোবাইল: ০১৭১২৩৪৫৬১৮",
          "timestamp": DateTime.now().subtract(const Duration(minutes: 30)),
          "type": "text",
          "isRead": true,
        },
      ];
    });
    
    // Auto scroll to bottom when messages load
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
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "sender": "wholesaler",
      "senderName": "You",
      "message": _messageController.text.trim(),
      "timestamp": DateTime.now(),
      "type": "text",
      "isRead": false,
    };

    setState(() {
      messages.add(newMessage);
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

    // Simulate shop owner response after 2-3 seconds
    _simulateShopResponse();
  }

  void _simulateShopResponse() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isTyping = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            final responses = [
              "ধন্যবাদ! আগামীকাল সকালে পেয়ে যাব।",
              "ঠিক আছে। পেমেন্ট ক্যাশে দেব।",
              "অর্ডার কনফার্ম। সময়মতো ডেলিভারি দিয়েন।",
              "বুঝলাম। আগামীকাল সকাল ৯টার মধ্যে পৌঁছে দিয়েন।",
            ];

            final randomResponse = responses[DateTime.now().millisecond % responses.length];
            
            final responseMessage = {
              "id": DateTime.now().millisecondsSinceEpoch.toString(),
              "sender": "shop",
              "senderName": widget.shopName,
              "message": randomResponse,
              "timestamp": DateTime.now(),
              "type": "text",
              "isRead": false,
            };

            setState(() {
              _isTyping = false;
              messages.add(responseMessage);
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
      }
    });
  }

  void _attachFile() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Send Attachment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red[600]),
              title: const Text("Product Catalog (PDF)"),
              subtitle: const Text("Send current product price list"),
              onTap: () {
                Navigator.pop(context);
                _sendCatalog();
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Colors.green[600]),
              title: const Text("Price List (Excel)"),
              subtitle: const Text("Send detailed pricing information"),
              onTap: () {
                Navigator.pop(context);
                _sendPriceList();
              },
            ),
            ListTile(
              leading: Icon(Icons.local_offer, color: Colors.orange[600]),
              title: const Text("Special Offer"),
              subtitle: const Text("Send personalized discount offer"),
              onTap: () {
                Navigator.pop(context);
                _sendSpecialOffer();
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: Colors.blue[600]),
              title: const Text("Product Images"),
              subtitle: const Text("Send product photos"),
              onTap: () {
                Navigator.pop(context);
                _sendImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendCatalog() {
    final catalogMessage = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "sender": "wholesaler",
      "senderName": "You",
      "message": "📄 Product Catalog sent",
      "timestamp": DateTime.now(),
      "type": "file",
      "fileType": "pdf",
      "fileName": "Wholesale_Catalog_July2025.pdf",
      "fileSize": "2.3 MB",
      "isRead": false,
    };

    setState(() {
      messages.add(catalogMessage);
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Catalog sent successfully!"),
          ],
        ),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendPriceList() {
    final priceListMessage = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "sender": "wholesaler",
      "senderName": "You",
      "message": "📊 Price List sent",
      "timestamp": DateTime.now(),
      "type": "file",
      "fileType": "excel",
      "fileName": "Current_Prices_${widget.shopName.replaceAll(' ', '_')}.xlsx",
      "fileSize": "1.8 MB",
      "isRead": false,
    };

    setState(() {
      messages.add(priceListMessage);
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Price list sent successfully!"),
          ],
        ),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendSpecialOffer() {
    final offerMessage = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "sender": "wholesaler",
      "senderName": "You",
      "message": "🎉 বিশেষ অফার: আগামী ৩ দিনের জন্য সব পণ্যে ১০% অতিরিক্ত ছাড়! ১০০ কেজির উপর অর্ডারে ফ্রি ডেলিভারি।",
      "timestamp": DateTime.now(),
      "type": "offer",
      "offerDetails": {
        "discount": "10%",
        "validUntil": "৩ দিন",
        "minOrder": "১০০ কেজি",
        "freeDelivery": true,
      },
      "isRead": false,
    };

    setState(() {
      messages.add(offerMessage);
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.local_offer, color: Colors.white),
            SizedBox(width: 8),
            Text("Special offer sent!"),
          ],
        ),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendImages() {
    final imageMessage = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "sender": "wholesaler",
      "senderName": "You",
      "message": "📷 Product images sent",
      "timestamp": DateTime.now(),
      "type": "images",
      "imageCount": 5,
      "imageNames": ["rice_premium.jpg", "oil_soybean.jpg", "lentils_masur.jpg", "sugar_white.jpg", "flour_wheat.jpg"],
      "isRead": false,
    };

    setState(() {
      messages.add(imageMessage);
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.image, color: Colors.white),
            SizedBox(width: 8),
            Text("Images sent successfully!"),
          ],
        ),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _callShop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Call Shop"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone, size: 50, color: Colors.green[700]),
            const SizedBox(height: 16),
            Text("Call ${widget.shopName}?"),
            const SizedBox(height: 8),
            const Text(
              "৪ রিং এর পর আনসার করা হবে",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Calling ${widget.shopName}..."),
                  backgroundColor: Colors.green[700],
                ),
              );
            },
            icon: const Icon(Icons.phone, color: Colors.white),
            label: const Text("Call Now", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
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
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(child: Text("ধানমন্ডি ১৫ নম্বর, ঢাকা")),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text("০১৭১২৩৪৫৬১৮"),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.business, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text("License: DH-2025-1234"),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text("Last Order: ২ দিন আগে"),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text("Total Orders: ১২৫টি"),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Opening shop profile...")),
              );
            },
            child: const Text("View Profile"),
          ),
        ],
      ),
    );
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
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
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
              backgroundColor: Colors.green[100],
              child: Text(
                widget.shopName[0],
                style: TextStyle(
                  color: Colors.green[800],
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
                    widget.shopName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Online • Active now",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _callShop,
            tooltip: "Call Shop",
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showShopInfo,
            tooltip: "Shop Info",
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
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                
                final message = messages[index];
                final isMe = message['sender'] == 'wholesaler';
                
                return _buildMessageBubble(message, isMe);
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
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                  onPressed: _attachFile,
                  tooltip: "Attach File",
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                    tooltip: "Send Message",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final messageType = message['type'] as String;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Text(
                widget.shopName[0],
                style: TextStyle(
                  color: Colors.blue[800],
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
                color: isMe ? Colors.green[800] : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (messageType == 'text') ...[
                    Text(
                      message['message'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ] else if (messageType == 'file') ...[
                    _buildFileMessage(message, isMe),
                  ] else if (messageType == 'offer') ...[
                    _buildOfferMessage(message, isMe),
                  ] else if (messageType == 'images') ...[
                    _buildImageMessage(message, isMe),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message['timestamp']),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 50),
          if (!isMe) const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildFileMessage(Map<String, dynamic> message, bool isMe) {
    final fileType = message['fileType'] as String;
    IconData fileIcon;
    Color fileColor;
    
    switch (fileType) {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf;
        fileColor = Colors.red;
        break;
      case 'excel':
        fileIcon = Icons.table_chart;
        fileColor = Colors.green;
        break;
      default:
        fileIcon = Icons.insert_drive_file;
        fileColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withValues(alpha: 0.2) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(fileIcon, color: fileColor, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message['fileName'],
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                message['fileSize'],
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferMessage(Map<String, dynamic> message, bool isMe) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? Colors.orange.withValues(alpha: 0.2) : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                "বিশেষ অফার",
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message['message'],
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> message, bool isMe) {
    final imageCount = message['imageCount'] as int;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withValues(alpha: 0.2) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image, color: Colors.blue[600], size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$imageCount Product Images",
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                "Tap to view gallery",
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue[100],
            child: Text(
              widget.shopName[0],
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Typing",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
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
