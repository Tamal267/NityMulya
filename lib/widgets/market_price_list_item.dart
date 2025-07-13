import 'package:flutter/material.dart';

import '../models/market_price.dart';

class MarketPriceListItem extends StatelessWidget {
  final MarketPrice marketPrice;
  final VoidCallback? onDownload;

  const MarketPriceListItem({
    super.key,
    required this.marketPrice,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                marketPrice.serial,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                marketPrice.title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                marketPrice.time,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                marketPrice.date,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: GestureDetector(
                onTap: onDownload,
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
