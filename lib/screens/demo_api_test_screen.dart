import 'package:flutter/material.dart';
import 'package:nitymulya/network/pricelist_api.dart';
import 'package:nitymulya/services/pricelist_service.dart';

class DemoApiTestScreen extends StatefulWidget {
  const DemoApiTestScreen({super.key});

  @override
  State<DemoApiTestScreen> createState() => _DemoApiTestScreenState();
}

class _DemoApiTestScreenState extends State<DemoApiTestScreen> {
  String apiResponse = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _testApi();
  }

  Future<void> _testApi() async {
    setState(() {
      isLoading = true;
      apiResponse = 'Loading...';
    });

    try {
      // Test the old global function
      final response1 = await fetchPriceList();
      
      // Test the new structured service
      final response2 = await PriceListService.fetchPriceList();
      
      // Test getting as array
      final response3 = await PriceListService.fetchPriceListAsArray();

      setState(() {
        apiResponse = '''
Old Global Function Response:
$response1

New Structured Service Response:
$response2

Array Response (${response3.length} items):
${response3.take(2).toList()} ${response3.length > 2 ? '...' : ''}
        ''';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        apiResponse = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test Demo'),
        backgroundColor: const Color(0xFF079b11),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Price List API Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _testApi,
              child: Text(isLoading ? 'Testing...' : 'Test API Again'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    apiResponse,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
