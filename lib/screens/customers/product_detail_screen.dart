import 'package:flutter/material.dart';
import 'package:nitymulya/network/pricelist_api.dart';

class ProductDetailScreen extends StatefulWidget {
  final String title;
  final String unit;
  final int low;
  final int high;
  final String? subcatId; // Add subcategory ID

  const ProductDetailScreen({
    super.key,
    required this.title,
    required this.unit,
    required this.low,
    required this.high,
    this.subcatId, // Optional for backward compatibility
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<Map<String, dynamic>> availableShops = [];
  Map<String, dynamic>? priceHistory;
  bool isLoadingShops = true;
  bool isLoadingHistory = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAvailableShops(),
      _loadPriceHistory(),
    ]);
  }

  Future<void> _loadAvailableShops() async {
    try {
      setState(() {
        isLoadingShops = true;
        errorMessage = null;
      });

      print('Loading shops for: ${widget.title} (ID: ${widget.subcatId})');

      List<Map<String, dynamic>> shops;

      // Use subcategory ID if available, otherwise fall back to product name
      if (widget.subcatId != null && widget.subcatId!.isNotEmpty) {
        shops = await fetchShopsBySubcategoryId(widget.subcatId!);
      } else {
        shops = await fetchShopsByProduct(widget.title);
      }

      print('Fetched ${shops.length} shops');

      setState(() {
        availableShops = shops;
        isLoadingShops = false;
      });
    } catch (e) {
      print('Error loading shops: $e');
      setState(() {
        // Don't show error message for shops, just show empty state
        errorMessage = null;
        isLoadingShops = false;
        availableShops = [];
      });
    }
  }

  Future<void> _loadPriceHistory() async {
    try {
      setState(() {
        isLoadingHistory = true;
      });

      final history = await fetchProductPriceHistory(widget.title);

      setState(() {
        priceHistory = history;
        isLoadingHistory = false;
      });
    } catch (e) {
      print('Error loading price history: $e');
      setState(() {
        isLoadingHistory = false;
        priceHistory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: Colors.indigo,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Unit: ${widget.unit}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Current Price Range:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Low: ৳${widget.low}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "High: ৳${widget.high}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Available Shops Section
            Row(
              children: [
                const Icon(Icons.store, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  "Available Shops (${availableShops.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                if (isLoadingShops)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (isLoadingShops)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (availableShops.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.store_mall_directory_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "No shops currently have this product in stock",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: availableShops.length,
                itemBuilder: (context, index) {
                  final shop = availableShops[index];
                  final price = shop['unit_price']?.toString() ?? '0';
                  final shopName = shop['name']?.toString() ?? 'Unknown Shop';
                  final shopAddress =
                      shop['address']?.toString() ?? 'Unknown Address';
                  final shopPhone = shop['phone']?.toString() ?? 'No Phone';
                  final stockQuantity =
                      shop['stock_quantity']?.toString() ?? '0';
                  final shopDescription =
                      shop['shop_description']?.toString() ?? '';
                  final lowStockThreshold =
                      shop['low_stock_threshold']?.toString() ?? '10';

                  // Determine stock status
                  final stock = int.tryParse(stockQuantity) ?? 0;
                  final threshold = int.tryParse(lowStockThreshold) ?? 10;
                  final isLowStock = stock <= threshold;
                  final stockStatus = stock > 50
                      ? 'High Stock'
                      : stock > threshold
                          ? 'Medium Stock'
                          : 'Low Stock';
                  final stockColor = stock > 50
                      ? Colors.green
                      : stock > threshold
                          ? Colors.orange
                          : Colors.red;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.withOpacity(0.1),
                        child: Text(
                          shopName.isNotEmpty ? shopName[0] : 'S',
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              shopName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Show verified icon if shop has good rating or stock
                          if (stock > 50)
                            const Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 20,
                            ),
                          // Show stock status chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: stockColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: stockColor, width: 1),
                            ),
                            child: Text(
                              stockStatus,
                              style: TextStyle(
                                color: stockColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  shopAddress,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                shopPhone,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (shopDescription.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    shopDescription,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                          ],
                          Row(
                            children: [
                              const Icon(
                                Icons.inventory,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Stock: $stockQuantity ${widget.unit}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: stockColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isLowStock) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.warning,
                                  size: 12,
                                  color: Colors.orange[700],
                                ),
                              ],
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "৳$price",
                                  style: const TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(shopName),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Address: $shopAddress"),
                                Text("Phone: $shopPhone"),
                                if (shopDescription.isNotEmpty)
                                  Text("Description: $shopDescription"),
                                Text("Stock: $stockQuantity ${widget.unit}"),
                                Text("Stock Status: $stockStatus"),
                                Text("Price: ৳$price per ${widget.unit}"),
                                if (isLowStock)
                                  const Text(
                                    "⚠️ Low stock - order soon!",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                    SnackBar(
                                      content: Text("Calling $shopName..."),
                                    ),
                                  );
                                },
                                child: const Text("Contact"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // Price History Section
            Row(
              children: [
                const Icon(Icons.history, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  "Price History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                if (isLoadingHistory)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (isLoadingHistory)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (priceHistory == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Price history not available",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      (priceHistory!['price_history'] as List?)?.length ?? 0,
                  itemBuilder: (context, index) {
                    final history = priceHistory!['price_history'] as List;
                    final dayHistory = history[index];
                    final date = dayHistory['date']?.toString() ?? '';
                    final minPrice = dayHistory['min_price']?.toString() ?? '0';
                    final maxPrice = dayHistory['max_price']?.toString() ?? '0';

                    String subtitle = '';
                    if (index == 0) {
                      subtitle = 'Today';
                    } else if (index == 1) {
                      subtitle = 'Yesterday';
                    } else {
                      subtitle = '$index days ago';
                    }

                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.calendar_today,
                              color: index == 0 ? Colors.indigo : Colors.grey),
                          title: Text(date),
                          subtitle: Text(subtitle),
                          trailing: Text(
                            "৳$minPrice - ৳$maxPrice",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: index == 0 ? Colors.indigo : Colors.black,
                            ),
                          ),
                        ),
                        if (index < (history.length - 1))
                          const Divider(height: 1),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Added to favorites!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text("Add to Favorites"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Price alert set!"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                    label: const Text("Price Alert"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
}
