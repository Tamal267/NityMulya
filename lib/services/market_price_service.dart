import '../models/market_price.dart';

class MarketPriceService {
  // Mock data generation (replace with actual API calls later)
  static List<MarketPrice> generateMockData() {
    return List.generate(
      10,
      (index) => MarketPrice(
        serial: '${index + 1}',
        title: 'ঢাকা খুচরা বাজার দর',
        time: '১২.৩০',
        date: '২০২৫-০৭-${(12 - index).toString().padLeft(2, '০')}',
      ),
    );
  }

  // Future method for API integration
  Future<List<MarketPrice>> fetchMarketPrices() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return generateMockData();
  }
}
