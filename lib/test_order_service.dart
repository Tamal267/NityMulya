import 'package:flutter/material.dart';

import '../services/order_service.dart';

class OrderTestWidget extends StatefulWidget {
  const OrderTestWidget({super.key});

  @override
  State<OrderTestWidget> createState() => _OrderTestWidgetState();
}

class _OrderTestWidgetState extends State<OrderTestWidget> {
  String _testResult = 'Ready to test';
  bool _isLoading = false;

  Future<void> _testOrderSaving() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing order save...';
    });

    try {
      // Create a test order
      final testOrder = OrderService.createOrder(
        productName: 'Test Product',
        shopName: 'Test Shop',
        shopPhone: '01700000000',
        shopAddress: 'Test Address',
        quantity: 2,
        unit: 'kg',
        unitPrice: 50.0,
        totalPrice: 100.0,
      );

      // Save the order
      await OrderService().saveOrder(testOrder);

      // Try to retrieve orders
      final orders = await OrderService().getOrders();

      if (orders.isNotEmpty) {
        setState(() {
          _testResult =
              'Success! Order saved and retrieved. Total orders: ${orders.length}';
        });
      } else {
        setState(() {
          _testResult = 'Warning: Order saved but not found in retrieval';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearTestOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await OrderService().clearAllOrders();
      setState(() {
        _testResult = 'All orders cleared successfully';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error clearing orders: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Service Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Service Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _testResult,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testOrderSaving,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Test Order Save'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _clearTestOrders,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clear Orders'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'This test will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. Create a test order with DateTime objects'),
            const Text(
                '2. Save it to local storage (converting DateTime to String)'),
            const Text(
                '3. Retrieve it back (converting String back to DateTime)'),
            const Text('4. Verify the process works without encoding errors'),
          ],
        ),
      ),
    );
  }
}
