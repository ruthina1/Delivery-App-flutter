/// API Configuration
class ApiConfig {
  // Base URL - Update this with your actual API endpoint
  // For development, you can use a local server or a mock API service
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.burgerknight.app/api/v1',
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

