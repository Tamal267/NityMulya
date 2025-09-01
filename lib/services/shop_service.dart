import '../models/shop.dart';

class ShopService {
  static List<Shop> getMockShops() {
    return [
      Shop(
        id: '1',
        name: 'রহমান গ্রোসারি',
        address: 'ধানমন্ডি, ঢাকা',
        phone: '01711123456',
        category: 'গ্রোসারি',
        rating: 4.5,
        image: 'assets/image/1.jpg',
        availableProducts: [
          'চাল সরু (নাজির/মিনিকেট)',
          'সয়াবিন তেল (পিউর)',
          'মসুর ডাল'
        ],
        isVerified: true,
        openingHours: '৮:০০ AM - ১০:০০ PM',
      ),
      Shop(
        id: '2',
        name: 'করিম স্টোর',
        address: 'গুলশান, ঢাকা',
        phone: '01812345678',
        category: 'সুপার শপ',
        rating: 4.2,
        image: 'assets/image/2.jpg',
        availableProducts: [
          'চাল মোটা (পাইলস)',
          'গমের আটা (প্রিমিয়াম)',
          'পেঁয়াজ (দেশি)'
        ],
        isVerified: true,
        openingHours: '৭:০০ AM - ১১:০০ PM',
      ),
      Shop(
        id: '3',
        name: 'আলম ট্রেডার্স',
        address: 'মিরপুর, ঢাকা',
        phone: '01913456789',
        category: 'পাইকারি',
        rating: 4.0,
        image: 'assets/image/3.jpg',
        availableProducts: ['রুই মাছ', 'গরুর দুধ', 'সয়াবিন তেল (পিউর)'],
        isVerified: false,
        openingHours: '৬:০০ AM - ৯:০০ PM',
      ),
      Shop(
        id: '4',
        name: 'নিউ মার্কেট স্টোর',
        address: 'নিউমার্কেট, ঢাকা',
        phone: '01714567890',
        category: 'খুচরা',
        rating: 4.7,
        image: 'assets/image/4.jpg',
        availableProducts: [
          'চাল সরু (নাজির/মিনিকেট)',
          'মসুর ডাল',
          'গমের আটা (প্রিমিয়াম)'
        ],
        isVerified: true,
        openingHours: '৯:০০ AM - ১০:০০ PM',
      ),
      Shop(
        id: '5',
        name: 'ফ্রেশ মার্ট',
        address: 'উত্তরা, ঢাকা',
        phone: '01615678901',
        category: 'সুপার শপ',
        rating: 4.3,
        image: 'assets/image/5.jpg',
        availableProducts: ['পেঁয়াজ (দেশি)', 'রুই মাছ', 'গরুর দুধ'],
        isVerified: true,
        openingHours: '৮:৩০ AM - ১০:৩০ PM',
      ),
    ];
  }

  static List<Shop> searchShops(String query) {
    final shops = getMockShops();
    if (query.isEmpty) return shops;

    return shops
        .where((shop) =>
            shop.name.toLowerCase().contains(query.toLowerCase()) ||
            shop.address.toLowerCase().contains(query.toLowerCase()) ||
            shop.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static List<Shop> getShopsByProduct(String productName) {
    final shops = getMockShops();
    return shops
        .where((shop) => shop.availableProducts.any((product) =>
            product.toLowerCase().contains(productName.toLowerCase())))
        .toList();
  }
}
