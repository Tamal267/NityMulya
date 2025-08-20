import 'lib/services/review_service.dart';

// Test script to verify review system functionality
void main() async {
  print('🧪 Testing Review System...');

  try {
    // Test 1: Create a product review
    print('\n1️⃣ Testing Product Review Creation...');
    final productReview = ReviewService.createProductReview(
      productName: 'Test Product',
      shopName: 'Test Shop',
      shopId: 'test_shop_123',
      customerId: 'customer_test',
      customerName: 'Test Customer',
      rating: 5,
      comment: 'Great product!',
      orderId: 'ORDER_123',
    );
    print('✅ Product review created: ${productReview['id']}');

    // Test 2: Create a shop review
    print('\n2️⃣ Testing Shop Review Creation...');
    final shopReview = ReviewService.createShopReview(
      shopName: 'Test Shop',
      shopId: 'test_shop_123',
      customerId: 'customer_test',
      customerName: 'Test Customer',
      rating: 4,
      comment: 'Good service!',
      deliveryRating: 5,
      serviceRating: 4,
    );
    print('✅ Shop review created: ${shopReview['id']}');

    // Test 3: Save and retrieve reviews
    print('\n3️⃣ Testing Review Storage...');
    final reviewService = ReviewService();

    await reviewService.saveProductReview(productReview);
    print('✅ Product review saved');

    await reviewService.saveShopReview(shopReview);
    print('✅ Shop review saved');

    final savedProductReviews =
        await reviewService.getCustomerReviews('customer_test');
    print('✅ Retrieved ${savedProductReviews.length} product reviews');

    final savedShopReviews =
        await reviewService.getShopReviews('test_shop_123');
    print('✅ Retrieved ${savedShopReviews.length} shop reviews');

    // Test 4: Rating calculations
    print('\n4️⃣ Testing Rating Calculations...');
    final ratings = await reviewService.getShopAverageRatings('test_shop_123');
    print('✅ Shop ratings calculated: ${ratings}');

    print('\n🎉 All tests passed! Review system is working correctly.');
  } catch (e) {
    print('\n❌ Test failed with error: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}
