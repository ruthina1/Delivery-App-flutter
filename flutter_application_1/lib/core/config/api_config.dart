/// API Configuration
class ApiConfig {
  // Base URL - Update this with your actual API endpoint
  // For development, you can use a local server or a mock API service
  // 
  // Platform-specific URLs:
  // - Android Emulator: http://10.0.2.2:3000/api/v1
  // - iOS Simulator: http://localhost:3000/api/v1
  // - Web: http://localhost:3000/api/v1
  // - Physical Device: http://YOUR_COMPUTER_IP:3000/api/v1
  // 
  // You can also set via command line:
  // flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1', // Local backend server
  );

  // API Endpoints
  static const String products = '/products';
  static const String categories = '/categories';
  static const String auth = '/auth';
  static const String users = '/users';
  static const String orders = '/orders';
  static const String addresses = '/addresses';
  static const String favorites = '/favorites';
  static const String cart = '/cart';

  // Timeout duration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

