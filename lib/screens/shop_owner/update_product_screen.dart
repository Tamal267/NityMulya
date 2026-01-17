import 'package:flutter/material.dart';
import 'package:nitymulya/network/shop_owner_api.dart';

class UpdateProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const UpdateProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isVisible = true;

  // Government fixed price ranges for reference
  final Map<String, String> _governmentPrices = {
    'চাল সরু (নাজির/মিনিকেট)': '৳78-82/কেজি',
    'চাল মোটা (পাইলস)': '৳58-62/কেজি',
    'সয়াবিন তেল (পিউর)': '৳165-175/লিটার',
    'মসুর ডাল': '৳115-125/কেজি',
    'পেঁয়াজ (দেশি)': '৳50-60/কেজি',
    'গমের আটা (প্রিমিয়াম)': '৳45-50/কেজি',
    'রুই মাছ': '৳350-400/কেজি',
    'গরুর দুধ': '৳60-70/লিটার',
  };

  @override
  void initState() {
    super.initState();
    // Initialize with current product data
    _quantityController.text = widget.product['quantity'].toString();
    _priceController.text = widget.product['price'].toString();
    _isVisible = !(widget.product['hidden'] ?? false);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final newQuantity = int.parse(_quantityController.text);
        final newPrice = double.parse(_priceController.text);
        final inventoryId = widget.product['id'].toString();

        // Call the API to update the inventory item
        final result = await ShopOwnerApiService.updateInventoryItem(
          inventoryId: inventoryId,
          stockQuantity: newQuantity,
          unitPrice: newPrice,
          lowStockThreshold: widget.product['low_stock_threshold'],
        );

        // Close loading dialog
        Navigator.pop(context);

        if (result['success'] == true) {
          final updatedProduct = {
            ...widget.product,
            'quantity': newQuantity,
            'stock_quantity': newQuantity, // Update both fields for consistency
            'price': newPrice,
            'unit_price': newPrice, // Update both fields for consistency
            'hidden': !_isVisible,
            'lastUpdated': DateTime.now().toIso8601String(),
          };

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Product "${widget.product['name']}" updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, updatedProduct);
        } else {
          // Handle API error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update product'),
              backgroundColor: Colors.red,
            ),
          );

          // Handle authentication error
          if (result['requiresLogin'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Please login again'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Close loading dialog
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text(
            'Are you sure you want to delete "${widget.product['name']}" from your inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, 'deleted'); // Return to dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Product "${widget.product['name']}" deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String? get _governmentPrice {
    return _governmentPrices[widget.product['name']];
  }

  bool get _isLowStock {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final threshold = widget.product['low_stock_threshold'] ?? 10;
    return quantity < threshold;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Update Product",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Icon(
                            Icons.inventory,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product['name'] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_governmentPrice != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Government Price: $_governmentPrice',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Current Stock Status
            Card(
              color: _isLowStock ? Colors.red[50] : Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isLowStock ? Icons.warning : Icons.check_circle,
                      color: _isLowStock ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLowStock
                                ? "Low Stock Alert"
                                : "Stock Status: Good",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isLowStock ? Colors.red : Colors.green,
                            ),
                          ),
                          Text(
                            _isLowStock
                                ? "Stock is running low. Consider restocking soon."
                                : "Your stock level is adequate.",
                            style: TextStyle(
                              fontSize: 12,
                              color: _isLowStock
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Update
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Update Stock Quantity",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              hintText: "Enter new quantity",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.numbers),
                              suffixText: "units",
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter quantity';
                              }
                              if (int.tryParse(value) == null ||
                                  int.parse(value) < 0) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {}); // Rebuild to update stock status
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                final current =
                                    int.tryParse(_quantityController.text) ?? 0;
                                _quantityController.text =
                                    (current + 10).toString();
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(60, 36),
                              ),
                              child: const Text(
                                "+10",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 4),
                            ElevatedButton(
                              onPressed: () {
                                final current =
                                    int.tryParse(_quantityController.text) ?? 0;
                                final newValue = (current - 10)
                                    .clamp(0, double.infinity)
                                    .toInt();
                                _quantityController.text = newValue.toString();
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(60, 36),
                              ),
                              child: const Text(
                                "-10",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Price Update
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Update Selling Price",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Must be within government price range",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        hintText: "Enter price per unit",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: "৳",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter selling price';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Visibility Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Visibility",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text("Visible to Customers"),
                      subtitle: Text(
                        _isVisible
                            ? "Customers can see and order this product"
                            : "Product is hidden from customers",
                      ),
                      value: _isVisible,
                      activeThumbColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _isVisible = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Update Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _updateProduct,
                icon: const Icon(Icons.update, color: Colors.white),
                label: const Text(
                  "Update Product",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
