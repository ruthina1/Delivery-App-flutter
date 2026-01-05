# Data Flow Summary

This document explains which parts of the app use static mock data and which use real API data flow.

## Static Mock Data (No API Calls)

The following features use **static mock data** from `lib/data/mock/mock_data.dart`:

### 1. **Products & Categories**
- **Home Screen** (`lib/features/home/home_screen.dart`)
  - Categories display
  - Popular products
  - Featured products
  
- **Menu Screen** (`lib/features/menu/menu_screen.dart`)
  - All categories
  - Products filtered by category
  - Product sorting and filtering
  
- **Search Screen** (`lib/features/search/search_screen.dart`)
  - All products for search
  - All categories for filtering
  - Search results

- **Favorites Screen** (`lib/features/profile/favorites_screen.dart`)
  - Product list (filtered by favorites)
  - Note: Favorites themselves are still synced with API

## Real Data Flow (API Integration)

The following features use **real API calls** and data persistence:

### 1. **Authentication** (`lib/services/auth_service.dart`)
- User signup
- User login
- Session management
- Profile updates
- **Fallback**: Local authentication when API is unavailable

### 2. **Cart** (`lib/services/cart_service.dart`)
- Add/remove items
- Update quantities
- Cart persistence (SharedPreferences)
- Cart calculations

### 3. **Favorites** (`lib/services/favorite_service.dart`)
- Add/remove favorites
- Sync with API
- Local persistence

### 4. **Addresses** (`lib/services/repository/data_repository.dart`)
- Get user addresses
- Create new address
- Update address
- Delete address
- API integration with local caching

### 5. **Orders** (`lib/services/api/order_api_service.dart`)
- Create orders
- Get order history
- Order tracking
- Order cancellation

### 6. **Notifications** (`lib/services/notification_service.dart`)
- Notification management
- Mark as read/unread
- Delete notifications

## Architecture

```
┌─────────────────────────────────────────┐
│         UI Screens                      │
├─────────────────────────────────────────┤
│  Home/Menu/Search → MockData (Static)  │
│  Cart/Orders/Favorites → Real API       │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│      Services Layer                     │
├─────────────────────────────────────────┤
│  • AuthService (API + Local Fallback)   │
│  • CartService (Local Persistence)      │
│  • FavoriteService (API Sync)          │
│  • NotificationService (Local)          │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│      Data Repository                    │
├─────────────────────────────────────────┤
│  • Addresses (API + Cache)              │
│  • Orders (API)                         │
│  • Favorites (API + Cache)              │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│      API Services                       │
├─────────────────────────────────────────┤
│  • AuthApiService                       │
│  • AddressApiService                    │
│  • OrderApiService                      │
│  • FavoriteApiService                   │
└─────────────────────────────────────────┘
```

## Benefits

1. **Fast Product Display**: Products and categories load instantly without API calls
2. **Real User Data**: User-specific data (cart, orders, favorites, addresses) syncs with backend
3. **Offline Support**: Cart and favorites work offline with local persistence
4. **Flexible**: Easy to switch products/categories to API later if needed

## Future Enhancements

To make products/categories dynamic:
1. Replace `MockData.products` with `_dataRepository.getProducts()`
2. Replace `MockData.categories` with `_dataRepository.getCategories()`
3. Add loading states where needed
4. Update the affected screens

