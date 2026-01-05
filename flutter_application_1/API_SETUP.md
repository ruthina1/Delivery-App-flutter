# API Setup Guide

This app now uses real API calls instead of mock data. Follow these steps to configure your API endpoint.

## Configuration

### 1. Set Your API Base URL

The API base URL is configured in `lib/core/config/api_config.dart`. 

**Option 1: Default Configuration**
```dart
static const String baseUrl = 'https://api.burgerknight.app/api/v1';
```

**Option 2: Environment Variable (Recommended for Production)**
You can set the API URL using environment variables when running the app:
```bash
flutter run --dart-define=API_BASE_URL=https://your-api-url.com/api/v1
```

### 2. API Endpoints Expected

The app expects the following REST API endpoints:

#### Authentication
- `POST /auth/signup` - User registration
- `POST /auth/signin` - User login
- `GET /auth/me` - Get current user

#### Products
- `GET /products` - Get all products (supports query params: `categoryId`, `isPopular`, `isFeatured`)
- `GET /products/:id` - Get product by ID
- `GET /products/search?q=query` - Search products

#### Categories
- `GET /categories` - Get all categories
- `GET /categories/:id` - Get category by ID

#### Addresses
- `GET /addresses` - Get user addresses
- `POST /addresses` - Create address
- `PUT /addresses/:id` - Update address
- `DELETE /addresses/:id` - Delete address

#### Orders
- `GET /orders` - Get user orders
- `GET /orders/:id` - Get order by ID
- `POST /orders` - Create order
- `PUT /orders/:id/cancel` - Cancel order

#### Favorites
- `GET /favorites` - Get favorite product IDs
- `POST /favorites` - Add favorite (body: `{"productId": "..."}`)
- `DELETE /favorites/:productId` - Remove favorite

### 3. API Response Format

The API should return responses in the following format:

**Success Response:**
```json
{
  "data": {
    // Your data here
  }
}
```

**Or directly:**
```json
{
  // Your data here
}
```

**Error Response:**
```json
{
  "message": "Error message here"
}
```

### 4. Authentication

The app uses Bearer token authentication. After successful login/signup, the API should return:
```json
{
  "token": "your-jwt-token",
  "user": {
    "id": "user_id",
    "name": "User Name",
    "email": "user@example.com",
    "phone": "+1234567890",
    "avatarUrl": "https://...",
    "favoriteProductIds": []
  }
}
```

### 5. Data Models

Ensure your API returns data matching these models:

- **ProductModel**: id, name, description, image, price, originalPrice, rating, reviewCount, categoryId, ingredients[], isPopular, isFeatured, preparationTime, calories
- **CategoryModel**: id, name, icon, image
- **AddressModel**: id, label, fullAddress, street, city, zipCode, latitude, longitude, isDefault
- **OrderModel**: id, orderNumber, items[], deliveryAddress, subtotal, deliveryFee, discount, total, status, createdAt, estimatedDelivery, driverName, driverPhone

### 6. Offline Support

The app includes offline support with local caching:
- Data is cached using SharedPreferences
- If API calls fail, cached data is used
- Cart and favorites are persisted locally

### 7. Testing Without API

If you want to test the app without a backend API, you can:
1. Use a mock API service like [JSONPlaceholder](https://jsonplaceholder.typicode.com/) or [MockAPI](https://mockapi.io/)
2. Use a local development server
3. The app will gracefully handle API errors and use cached data

### 8. Error Handling

The app handles:
- Network errors
- API errors (4xx, 5xx)
- Timeout errors
- Invalid data format errors

All errors are logged and the app falls back to cached data when available.

## Next Steps

1. Update `lib/core/config/api_config.dart` with your API URL
2. Ensure your backend API matches the expected endpoints and response formats
3. Test authentication flow
4. Test data fetching (products, categories, etc.)
5. Test cart and order creation

## Notes

- The app uses HTTP (not HTTPS) by default. For production, ensure your API uses HTTPS.
- All API calls include proper error handling and timeout configuration (30 seconds).
- The app automatically retries with cached data if API calls fail.

