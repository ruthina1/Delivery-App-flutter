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
      image: 'assets/images/categories/burgers.png',
    ),
    CategoryModel(
      id: 'cat_2',
      name: 'Sides',
      icon: '🍟',
      image: 'assets/images/categories/sides.png',
    ),
    CategoryModel(
      id: 'cat_3',
      name: 'Drinks',
      icon: '🥤',
      image: 'assets/images/categories/drinks.png',
    ),
    CategoryModel(
      id: 'cat_4',
      name: 'Desserts',
      icon: '🍦',
      image: 'assets/images/categories/desserts.png',
    ),
    CategoryModel(
      id: 'cat_5',
      name: 'Combos',
      icon: '🍱',
      image: 'assets/images/categories/combos.png',
    ),
    CategoryModel(
      id: 'cat_6',
      name: 'Salads',
      icon: '🥗',
      image: 'assets/images/categories/salads.png',
    ),
  ];

  // Products - Prices in ETB (Ethiopian Birr)
  static const List<ProductModel> products = [
    // Burgers
    ProductModel(
      id: 'prod_1',
      name: 'Classic Smash Burger',
      description: 'Our signature smashed patty with American cheese, caramelized onions, pickles, and our special sauce on a brioche bun.',
      image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
      price: 450,
      originalPrice: 550,
      rating: 4.8,
      reviewCount: 324,
      categoryId: 'cat_1',
      ingredients: ['Beef Patty', 'American Cheese', 'Caramelized Onions', 'Pickles', 'Special Sauce', 'Brioche Bun'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 12,
      calories: 650,
    ),
    ProductModel(
      id: 'prod_2',
      name: 'Double Bacon Knight',
      description: 'Two juicy beef patties, crispy bacon strips, cheddar cheese, lettuce, tomato, and mayo.',
      image: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800&q=80',
      price: 650,
      rating: 4.9,
      reviewCount: 256,
      categoryId: 'cat_1',
      ingredients: ['Double Beef Patty', 'Crispy Bacon', 'Cheddar Cheese', 'Lettuce', 'Tomato', 'Mayo'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 15,
      calories: 920,
    ),
    ProductModel(
      id: 'prod_3',
      name: 'Spicy Jalapeño Fury',
      description: 'Fire-grilled patty with pepper jack cheese, fresh jalapeños, spicy mayo, and crispy onion rings.',
      image: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&q=80',
      price: 520,
      rating: 4.6,
      reviewCount: 189,
      categoryId: 'cat_1',
      ingredients: ['Beef Patty', 'Pepper Jack Cheese', 'Jalapeños', 'Spicy Mayo', 'Onion Rings'],
      isPopular: true,
      preparationTime: 13,
      calories: 780,
    ),
    ProductModel(
      id: 'prod_4',
      name: 'Mushroom Swiss Deluxe',
      description: 'Premium beef patty topped with sautéed mushrooms, Swiss cheese, and truffle aioli.',
      image: 'https://images.unsplash.com/photo-1553979459-d2229ba7433f?w=800&q=80',
      price: 600,
      rating: 4.7,
      reviewCount: 167,
      categoryId: 'cat_1',
      ingredients: ['Beef Patty', 'Swiss Cheese', 'Sautéed Mushrooms', 'Truffle Aioli', 'Arugula'],
      isFeatured: true,
      preparationTime: 14,
      calories: 720,
    ),
    ProductModel(
      id: 'prod_5',
      name: 'BBQ Ranch Burger',
      description: 'Smoky BBQ sauce, crispy bacon, cheddar cheese, and creamy ranch on a toasted sesame bun.',
      image: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800&q=80',
      price: 550,
      rating: 4.5,
      reviewCount: 203,
      categoryId: 'cat_1',
      ingredients: ['Beef Patty', 'BBQ Sauce', 'Bacon', 'Cheddar', 'Ranch', 'Sesame Bun'],
      preparationTime: 13,
      calories: 830,
    ),
    ProductModel(
      id: 'prod_6',
      name: 'Veggie Garden Burger',
      description: 'Plant-based patty with avocado, roasted peppers, mixed greens, and herb mayo.',
      image: 'https://images.unsplash.com/photo-1525059696034-4967a7290025?w=800&q=80',
      price: 500,
      rating: 4.4,
      reviewCount: 145,
      categoryId: 'cat_1',
      ingredients: ['Plant-Based Patty', 'Avocado', 'Roasted Peppers', 'Mixed Greens', 'Herb Mayo'],
      preparationTime: 12,
      calories: 480,
    ),
    
    // Sides
    ProductModel(
      id: 'prod_7',
      name: 'Crispy Fries',
      description: 'Golden crispy fries seasoned with our signature spice blend.',
      image: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=800&q=80',
      price: 150,
      rating: 4.6,
      reviewCount: 412,
      categoryId: 'cat_2',
      ingredients: ['Potatoes', 'Signature Spices', 'Sea Salt'],
      isPopular: true,
      preparationTime: 6,
      calories: 320,
    ),
    ProductModel(
      id: 'prod_8',
      name: 'Loaded Cheese Fries',
      description: 'Crispy fries topped with melted cheese sauce, bacon bits, and green onions.',
      image: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=800&q=80',
      price: 250,
      rating: 4.7,
      reviewCount: 289,
      categoryId: 'cat_2',
      ingredients: ['Fries', 'Cheese Sauce', 'Bacon Bits', 'Green Onions'],
      preparationTime: 8,
      calories: 520,
    ),
    ProductModel(
      id: 'prod_9',
      name: 'Onion Rings',
      description: 'Thick-cut onion rings with a crispy golden batter.',
      image: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=800&q=80',
      price: 180,
      rating: 4.5,
      reviewCount: 198,
      categoryId: 'cat_2',
      ingredients: ['Onions', 'Crispy Batter', 'Spices'],
      preparationTime: 7,
      calories: 380,
    ),
    ProductModel(
      id: 'prod_10',
      name: 'Chicken Nuggets',
      description: '8-piece crispy chicken nuggets with your choice of dipping sauce.',
      image: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=800&q=80',
      price: 280,
      rating: 4.6,
      reviewCount: 267,
      categoryId: 'cat_2',
      ingredients: ['Chicken Breast', 'Crispy Coating', 'Dipping Sauce'],
      isPopular: true,
      preparationTime: 8,
      calories: 420,
    ),
    
    // Drinks
    ProductModel(
      id: 'prod_11',
      name: 'Classic Milkshake',
      description: 'Thick and creamy milkshake. Choose from Vanilla, Chocolate, or Strawberry.',
      image: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=800&q=80',
      price: 200,
      rating: 4.8,
      reviewCount: 356,
      categoryId: 'cat_3',
      ingredients: ['Ice Cream', 'Milk', 'Whipped Cream'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 4,
      calories: 450,
    ),
    ProductModel(
      id: 'prod_12',
      name: 'Fresh Lemonade',
      description: 'Freshly squeezed lemonade with a hint of mint.',
      image: 'https://images.unsplash.com/photo-1523677011781-c91d1bbe2fdc?w=800&q=80',
      price: 120,
      rating: 4.5,
      reviewCount: 178,
      categoryId: 'cat_3',
      ingredients: ['Fresh Lemons', 'Sugar', 'Mint', 'Sparkling Water'],
      preparationTime: 3,
      calories: 120,
    ),
    ProductModel(
      id: 'prod_13',
      name: 'Iced Coffee',
      description: 'Cold brew coffee served over ice with your choice of milk.',
      image: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=800&q=80',
      price: 150,
      rating: 4.6,
      reviewCount: 234,
      categoryId: 'cat_3',
      ingredients: ['Cold Brew Coffee', 'Ice', 'Milk'],
      preparationTime: 2,
      calories: 80,
    ),
    
    // Desserts
    ProductModel(
      id: 'prod_14',
      name: 'Chocolate Brownie',
      description: 'Warm chocolate brownie served with vanilla ice cream and chocolate sauce.',
      image: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=800&q=80',
      price: 220,
      rating: 4.9,
      reviewCount: 289,
      categoryId: 'cat_4',
      ingredients: ['Chocolate Brownie', 'Vanilla Ice Cream', 'Chocolate Sauce'],
      isFeatured: true,
      preparationTime: 5,
      calories: 580,
    ),
    ProductModel(
      id: 'prod_15',
      name: 'Apple Pie Bites',
      description: 'Mini apple pie bites with cinnamon sugar and caramel dipping sauce.',
      image: 'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=800&q=80',
      price: 180,
      rating: 4.7,
      reviewCount: 167,
      categoryId: 'cat_4',
      ingredients: ['Apple', 'Pie Crust', 'Cinnamon Sugar', 'Caramel'],
      preparationTime: 6,
      calories: 340,
    ),
    
    // Combos
    ProductModel(
      id: 'prod_16',
      name: 'Knight Combo',
      description: 'Classic Smash Burger + Crispy Fries + Medium Drink. The perfect meal deal!',
      image: 'https://images.unsplash.com/photo-1551782450-17144efb9c50?w=800&q=80',
      price: 700,
      originalPrice: 850,
      rating: 4.8,
      reviewCount: 445,
      categoryId: 'cat_5',
      ingredients: ['Classic Burger', 'Fries', 'Drink'],
      isPopular: true,
      isFeatured: true,
      preparationTime: 15,
      calories: 1100,
    ),
    ProductModel(
      id: 'prod_17',
      name: 'Family Feast',
      description: '4 Classic Burgers + 2 Large Fries + 4 Drinks. Feed the whole family!',
      image: 'https://images.unsplash.com/photo-1551782450-17144efb9c50?w=800&q=80',
      price: 2200,
      originalPrice: 2600,
      rating: 4.7,
      reviewCount: 178,
      categoryId: 'cat_5',
      ingredients: ['4 Classic Burgers', '2 Large Fries', '4 Drinks'],
      preparationTime: 25,
      calories: 3800,
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
