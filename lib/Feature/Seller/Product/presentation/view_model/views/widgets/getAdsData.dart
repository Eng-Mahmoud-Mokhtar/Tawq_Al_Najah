class DataProvider {
  static List<Map<String, dynamic>> getAdsData() {
    return [
      {
        'images': [
          'Assets/black-friday-sales-arrangement-with-tags.jpg',
          'Assets/discount-jacket-podium.jpg',
          'Assets/front-view-screaming-male-chef-holding-up-sale-sign-burger-kitchen.jpg',
        ],
        'name': 'تخفيضات الجمعة السوداء',
        'description': 'عروض مذهلة على المنتجات المختارة.',
        'price': 99.99,
        'currency': 'ر.س',
        'rating': 4.5,
        'reviewCount': 120,
        'delivery': true,
        'installment': true,
        'reviews': [
          {'user': 'محمد', 'comment': 'عرض رائع!', 'rating': 5},
          {'user': 'أحمد', 'comment': 'جيد جدا', 'rating': 4},
        ],
        'seller': {
          'name': 'متجر الجمعة السوداء',
          'address': 'الرياض، المملكة العربية السعودية',
          'image': 'Assets/seller_black_friday.png',
          'instagram': "https://www.instagram.com/",
          'whatsapp': '+201080519199',
          'facebook': 'https://www.facebook.com/blackfridayshop',
        },
        'performance': 0.95,
        'location': 'الرياض',
        'category': 'الكترونيات',
        'country': 'السعودية',
      },
      {
        'images': [
          'Assets/discount-jacket-podium.jpg',
          'Assets/black-friday-sales-arrangement-with-tags.jpg',
          'Assets/hands-holding-modern-smartphone.jpg',
        ],
        'name': 'جاكيت شتوي',
        'description': 'جاكيت أنيق بتخفيض خاص. مصنوع من مواد عالية الجودة.',
        'price': 149.99,
        'currency': 'ر.س',
        'rating': 4.2,
        'reviewCount': 85,
        'delivery': true,
        'installment': false,
        'reviews': [
          {'user': 'فاطمة', 'comment': 'مريح جدا', 'rating': 4},
          {'user': 'علي', 'comment': 'جودة عالية', 'rating': 5},
        ],
        'seller': {
          'name': 'متجر الأزياء',
          'address': 'جدة، المملكة العربية السعودية',
          'image': 'Assets/seller_fashion.png',
          'instagram': "https://www.instagram.com/",
          'whatsapp': '+201080519199',
          'snapchat': 'https://www.snapchat.com/add/fashionstore',
        },
        'performance': 0.88,
        'location': 'جدة',
        'category': 'أزياء',
        'country': 'السعودية',
      },
      {
        'images': [
          'Assets/front-view-screaming-male-chef-holding-up-sale-sign-burger-kitchen.jpg',
          'Assets/man-giving-some-keys-woman.jpg',
          'Assets/discount-jacket-podium.jpg',
        ],
        'name': 'عرض البرجر',
        'description': 'وجبة برجر شهية بسعر مميز. تحتوي على مكونات طازجة.',
        'price': 29.99,
        'currency': 'ر.س',
        'rating': 4.8,
        'reviewCount': 200,
        'delivery': false,
        'installment': true,
        'reviews': [
          {'user': 'سارة', 'comment': 'لذيذ!', 'rating': 5},
          {'user': 'خالد', 'comment': 'سعر جيد', 'rating': 4},
        ],
        'seller': {
          'name': 'مطعم البرجر',
          'address': 'الدمام، المملكة العربية السعودية',
          'image': 'Assets/seller_burger.png',
          'instagram': "https://www.instagram.com/",
          'facebook': 'https://www.facebook.com/burgerstore',
          'snapchat': 'https://www.snapchat.com/add/burgerstore',
        },
        'performance': 0.92,
        'location': 'الدمام',
        'category': 'مطبخ',
        'country': 'السعودية',
      },
      {
        'images': [
          'Assets/hands-holding-modern-smartphone.jpg',
          'Assets/black-friday-sales-arrangement-with-tags.jpg',
          'Assets/front-view-screaming-male-chef-holding-up-sale-sign-burger-kitchen.jpg',
        ],
        'name': 'هاتف ذكي',
        'description': 'هاتف بتقنية حديثة. يدعم أحدث الميزات.',
        'price': 1999.99,
        'currency': 'ر.س',
        'rating': 4.7,
        'reviewCount': 150,
        'delivery': true,
        'installment': true,
        'reviews': [
          {'user': 'نور', 'comment': 'أداء ممتاز', 'rating': 5},
          {'user': 'يوسف', 'comment': 'بطارية طويلة', 'rating': 4},
        ],
        'seller': {
          'name': 'متجر الإلكترونيات',
          'address': 'مكة، المملكة العربية السعودية',
          'image': 'Assets/seller_electronics.png',
          'whatsapp': '+201080519199',
        },
        'performance': 0.90,
        'location': 'مكة',
        'category': 'الكترونيات',
        'country': 'السعودية',
      },
      {
        'images': [
          'Assets/man-giving-some-keys-woman.jpg',
          'Assets/discount-jacket-podium.jpg',
          'Assets/hands-holding-modern-smartphone.jpg',
        ],
        'name': 'مفاتيح سيارة',
        'description': 'عرض خاص على إكسسوارات السيارات. متينة وسهلة الاستخدام.',
        'price': 49.99,
        'currency': 'ر.س',
        'rating': 3.9,
        'reviewCount': 60,
        'delivery': true,
        'installment': false,
        'reviews': [
          {'user': 'لينا', 'comment': 'عملية', 'rating': 4},
          {'user': 'حسن', 'comment': 'سعر مناسب', 'rating': 3},
        ],
        'seller': {
          'name': 'متجر السيارات',
          'address': 'المدينة المنورة، المملكة العربية السعودية',
          'image': 'Assets/seller_car.png',
          'instagram': "https://www.instagram.com/",
          'whatsapp': '+201080519199',
          'facebook': 'https://www.facebook.com/caraccessories',
        },
        'performance': 0.85,
        'location': 'المدينة المنورة',
        'category': 'ألعاب',
        'country': 'مصر',
      },
    ];
  }

  /// 🔹 تصفية حسب الفئة
  static List<Map<String, dynamic>> getAdsByCategory(String category) {
    return getAdsData().where((ad) => ad['category'] == category).toList();
  }

  /// 🔹 بيانات المتاجر
  static List<Map<String, dynamic>> getStoresData() {
    final ads = getAdsData();
    final List<Map<String, dynamic>> stores = [
      {
        'name': 'محمود مختار',
        'image': 'Assets/hands-holding-modern-smartphone.jpg',
        'address': 'السعودية، الرياض',
        'category': 'ملابس',
        'ads': ads.sublist(0, 2),
      },
      {
        'name': 'حسن أحمد',
        'image': 'Assets/discount-jacket-podium.jpg',
        'address': 'مصر، القاهرة',
        'category': 'أثاث',
        'ads': ads.sublist(2, 4),
      },
      {
        'name': 'إبراهيم خالد',
        'image': 'Assets/front-view-screaming-male-chef-holding-up-sale-sign-burger-kitchen.jpg',
        'address': 'مصر، الدقهلية - المنصورة',
        'category': 'طعام',
        'ads': ads.sublist(4),
      },
    ];

    for (Map<String, dynamic> store in stores) {
      List<dynamic> adsList = store['ads'];
      for (var ad in adsList) {
        if (ad['seller'] is Map<String, dynamic>) {
          ad['seller']['name'] = store['name'];
          ad['seller']['address'] = store['address'];
          ad['seller']['image'] = store['image'];
        }
      }
    }

    return stores;
  }
}