import '../models/models.dart';

/// Mock data for Burger Knight app
class MockData {
  MockData._();

  // Categories
  static const List<CategoryModel> categories = [
    CategoryModel(
      id: 'cat_1',
      name: 'Burgers',
      icon: '🍔',
      image: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400&q=80',
    ),
    CategoryModel(
      id: 'cat_2',
      name: 'Pizza',
      icon: '🍕',
      image: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80',
    ),
    CategoryModel(
      id: 'cat_3',
      name: 'Chips',
      icon: '🍟',
      image: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400&q=80',
    ),
    CategoryModel(
      id: 'cat_4',
      name: 'Ice Cream',
      icon: '🍦',
      image: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&q=80',
    ),
    CategoryModel(
      id: 'cat_5',
      name: 'Ethiopian',
      icon: '🍛',
      image: 'https://images.unsplash.com/photo-1541518763669-27fef04b14ea?w=400&q=80',
    ),
    CategoryModel(
      id: 'cat_6',
      name: 'Drinks',
      icon: '🥤',
      image: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400&q=80',
    ),
  ];

  // Products - Prices in ETB (Ethiopian Birr)
  static const List<ProductModel> products = [
    // Burgers
    ProductModel(
      id: 'prod_1',
      name: 'Classic Cheeseburger',
      description: 'Juicy beef patty with American cheese, fresh lettuce, tomato, pickles, and special sauce on a sesame bun.',
      image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
      price: 450,
      originalPrice: 550,
      rating: 4.8,
      reviewCount: 324,
      categoryId: 'cat_1',
      ingredients: ['Beef Patty', 'American Cheese', 'Lettuce', 'Tomato', 'Pickles', 'Special Sauce', 'Sesame Bun'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 12,
      calories: 650,
    ),
    ProductModel(
      id: 'prod_2',
      name: 'Bacon Double Burger',
      description: 'Two beef patties with crispy bacon, cheddar cheese, onion rings, and BBQ sauce.',
      image: 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=800&q=80',
      price: 650,
      rating: 4.9,
      reviewCount: 256,
      categoryId: 'cat_1',
      ingredients: ['Double Beef Patty', 'Crispy Bacon', 'Cheddar Cheese', 'Onion Rings', 'BBQ Sauce'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 15,
      calories: 920,
    ),
    ProductModel(
      id: 'prod_3',
      name: 'Veggie Burger',
      description: 'Plant-based patty with avocado, roasted peppers, mixed greens, and herb mayo.',
      image: 'https://th.bing.com/th/id/R.8408e6216a863c54288a126eccb7da1e?rik=grP%2fyxXSw%2fTinw&pid=ImgRaw&r=0',
      price: 500,
      rating: 4.6,
      reviewCount: 189,
      categoryId: 'cat_1',
      ingredients: ['Plant-Based Patty', 'Avocado', 'Roasted Peppers', 'Mixed Greens', 'Herb Mayo'],
      isPopular: true,
      preparationTime: 12,
      calories: 480,
    ),
    
    // Pizza
    ProductModel(
      id: 'prod_4',
      name: 'Margherita Pizza',
      description: 'Classic Italian pizza with fresh mozzarella, tomato sauce, and basil leaves.',
      image: 'https://images.unsplash.com/photo-1574126154517-d1e0d89ef734?w=800&q=80',
      price: 550,
      rating: 4.7,
      reviewCount: 412,
      categoryId: 'cat_2',
      ingredients: ['Pizza Dough', 'Mozzarella Cheese', 'Tomato Sauce', 'Fresh Basil'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 20,
      calories: 850,
    ),
    ProductModel(
      id: 'prod_5',
      name: 'Pepperoni Pizza',
      description: 'Classic pepperoni pizza with mozzarella cheese and tomato sauce.',
      image: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=800&q=80',
      price: 600,
      rating: 4.8,
      reviewCount: 356,
      categoryId: 'cat_2',
      ingredients: ['Pizza Dough', 'Pepperoni', 'Mozzarella Cheese', 'Tomato Sauce'],
      isPopular: true,
      preparationTime: 20,
      calories: 920,
    ),
    ProductModel(
      id: 'prod_6',
      name: 'BBQ Chicken Pizza',
      description: 'Grilled chicken with BBQ sauce, red onions, and mozzarella cheese.',
      image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
      price: 650,
      rating: 4.6,
      reviewCount: 234,
      categoryId: 'cat_2',
      ingredients: ['Pizza Dough', 'Grilled Chicken', 'BBQ Sauce', 'Red Onions', 'Mozzarella'],
      preparationTime: 22,
      calories: 980,
    ),
    
    // Chips
    ProductModel(
      id: 'prod_7',
      name: 'Crispy French Fries',
      description: 'Golden crispy fries seasoned with our signature spice blend.',
      image: 'https://images.unsplash.com/photo-1630384066252-11e4695c023d?w=800&q=80',
      price: 150,
      rating: 4.6,
      reviewCount: 412,
      categoryId: 'cat_3',
      ingredients: ['Potatoes', 'Signature Spices', 'Sea Salt'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 6,
      calories: 320,
    ),
    ProductModel(
      id: 'prod_8',
      name: 'Loaded Cheese Fries',
      description: 'Crispy fries topped with melted cheese sauce, bacon bits, and green onions.',
      image: 'https://images.unsplash.com/photo-1585109649139-366815a0d713?w=800&q=80',
      price: 250,
      rating: 4.7,
      reviewCount: 289,
      categoryId: 'cat_3',
      ingredients: ['Fries', 'Cheese Sauce', 'Bacon Bits', 'Green Onions'],
      isPopular: true,
      preparationTime: 8,
      calories: 520,
    ),
    ProductModel(
      id: 'prod_9',
      name: 'Sweet Potato Fries',
      description: 'Crispy sweet potato fries with a hint of cinnamon.',
      image: 'https://images.unsplash.com/photo-1600109312686-2187e5008518?w=800&q=80',
      price: 180,
      rating: 4.5,
      reviewCount: 198,
      categoryId: 'cat_3',
      ingredients: ['Sweet Potatoes', 'Cinnamon', 'Sea Salt'],
      preparationTime: 7,
      calories: 280,
    ),
    
    // Ice Cream
    ProductModel(
      id: 'prod_10',
      name: 'Vanilla Ice Cream',
      description: 'Creamy vanilla ice cream made with real vanilla beans.',
      image: 'https://images.unsplash.com/photo-1570197788417-0e82375c9371?w=800&q=80',
      price: 180,
      rating: 4.8,
      reviewCount: 356,
      categoryId: 'cat_4',
      ingredients: ['Cream', 'Vanilla Beans', 'Sugar', 'Eggs'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 2,
      calories: 250,
    ),
    ProductModel(
      id: 'prod_11',
      name: 'Chocolate Ice Cream',
      description: 'Rich and creamy chocolate ice cream with chocolate chips.',
      image: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=800&q=80',
      price: 200,
      rating: 4.9,
      reviewCount: 289,
      categoryId: 'cat_4',
      ingredients: ['Cream', 'Cocoa', 'Chocolate Chips', 'Sugar'],
      isPopular: true,
      preparationTime: 2,
      calories: 320,
    ),
    ProductModel(
      id: 'prod_12',
      name: 'Strawberry Ice Cream',
      description: 'Fresh strawberry ice cream with real fruit pieces.',
      image: 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=800&q=80',
      price: 190,
      rating: 4.7,
      reviewCount: 234,
      categoryId: 'cat_4',
      ingredients: ['Cream', 'Fresh Strawberries', 'Sugar', 'Eggs'],
      preparationTime: 2,
      calories: 280,
    ),
    
    // Ethiopian Foods
    ProductModel(
      id: 'prod_13',
      name: 'Doro Wet',
      description: 'Traditional Ethiopian spicy chicken stew with hard-boiled eggs, served with injera.',
      image: 'https://tse4.mm.bing.net/th/id/OIP.P0oYhMRCND5spHo9qHdFYgHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',
      price: 450,
      rating: 4.9,
      reviewCount: 567,
      categoryId: 'cat_5',
      ingredients: ['Chicken', 'Berbere', 'Onions', 'Garlic', 'Ginger', 'Hard-boiled Eggs', 'Injera'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 45,
      calories: 680,
    ),
    ProductModel(
      id: 'prod_14',
      name: 'Tire Siga',
      description: 'Ethiopian raw beef marinated in spices, served with mitmita and injera.',
      image: 'https://tse2.mm.bing.net/th/id/OIP.4BOpg8EUBP-N8USB6K8mMgHaIX?rs=1&pid=ImgDetMain&o=7&rm=3',
      price: 500,
      rating: 4.8,
      reviewCount: 423,
      categoryId: 'cat_5',
      ingredients: ['Raw Beef', 'Mitmita', 'Niter Kibbeh', 'Injera', 'Spices'],
      isPopular: true,
      preparationTime: 15,
      calories: 520,
    ),
    ProductModel(
      id: 'prod_15',
      name: 'Kitfo',
      description: 'Minced raw beef seasoned with mitmita and niter kibbeh, served with injera and ayib.',
      image: 'https://tse4.mm.bing.net/th/id/OIP.7rsQngx6jVnpg3fWs-0YvwHaDO?rs=1&pid=ImgDetMain&o=7&rm=3',
      price: 480,
      rating: 4.7,
      reviewCount: 389,
      categoryId: 'cat_5',
      ingredients: ['Minced Raw Beef', 'Mitmita', 'Niter Kibbeh', 'Injera', 'Ayib Cheese'],
      isPopular: true,
      preparationTime: 12,
      calories: 580,
    ),
    ProductModel(
      id: 'prod_16',
      name: 'Tibs',
      description: 'Sautéed beef or lamb with onions, peppers, and Ethiopian spices, served with injera.',
      image: 'https://tse2.mm.bing.net/th/id/OIP.yhFg8izBYONGF4_Rl4FJTwHaE7?rs=1&pid=ImgDetMain&o=7&rm=3',
      price: 420,
      rating: 4.8,
      reviewCount: 445,
      categoryId: 'cat_5',
      ingredients: ['Beef/Lamb', 'Onions', 'Bell Peppers', 'Berbere', 'Injera'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 25,
      calories: 620,
    ),
    
    // Drinks
    ProductModel(
      id: 'prod_17',
      name: 'Fresh Lemonade',
      description: 'Freshly squeezed lemonade with a hint of mint.',
      image: 'https://images.unsplash.com/photo-1523677011781-c91d1bbe2fdc?w=800&q=80',
      price: 120,
      rating: 4.5,
      reviewCount: 178,
      categoryId: 'cat_6',
      ingredients: ['Fresh Lemons', 'Sugar', 'Mint', 'Sparkling Water'],
      preparationTime: 3,
      calories: 120,
    ),
    ProductModel(
      id: 'prod_18',
      name: 'Iced Coffee',
      description: 'Cold brew coffee served over ice with your choice of milk.',
      image: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=800&q=80',
      price: 150,
      rating: 4.6,
      reviewCount: 234,
      categoryId: 'cat_6',
      ingredients: ['Cold Brew Coffee', 'Ice', 'Milk'],
      preparationTime: 2,
      calories: 80,
    ),
  ];

  // Addresses - Bahir Dar, Ethiopia
  static const List<AddressModel> addresses = [
    AddressModel(
      id: 'addr_1',
      label: 'Home',
      fullAddress: 'Kebele 14, Near Blue Nile Bridge, Bahir Dar, Ethiopia',
      street: 'Kebele 14, Near Blue Nile Bridge',
      city: 'Bahir Dar',
      zipCode: '1000',
      latitude: 11.5936,
      longitude: 37.3908,
      isDefault: true,
    ),
    AddressModel(
      id: 'addr_2',
      label: 'Work',
      fullAddress: 'Tana Sub City, Near Bahir Dar University, Bahir Dar, Ethiopia',
      street: 'Tana Sub City, Near Bahir Dar University',
      city: 'Bahir Dar',
      zipCode: '1000',
      latitude: 11.5742,
      longitude: 37.3614,
      isDefault: false,
    ),
  ];

  // Current User
  static const UserModel currentUser = UserModel(
    id: 'user_1',
    name: 'Ruth Gizat',
    email: 'ruthgizat32@gmail.com',
    phone: '+251 91 234 5678',
    avatarUrl: null,
    favoriteProductIds: ['prod_1', 'prod_2', 'prod_11'],
  );

  // Helper methods
  static List<ProductModel> get popularProducts =>
      products.where((p) => p.isPopular).toList();

  static List<ProductModel> get featuredProducts =>
      products.where((p) => p.isFeatured).toList();

  static List<ProductModel> getProductsByCategory(String categoryId) =>
      products.where((p) => p.categoryId == categoryId).toList();

  static ProductModel? getProductById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static CategoryModel? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
