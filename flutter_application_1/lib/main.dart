import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/theme.dart';
import 'data/models/models.dart';
import 'services/services.dart';
import 'services/repository/data_repository.dart';

// Features imports - organized by page
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/main/main_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/checkout/checkout_screen.dart';
import 'features/orders/orders_screen.dart';
import 'features/orders/order_detail_screen.dart';
import 'features/orders/order_tracking_screen.dart';
import 'features/product/product_detail_screen.dart';
import 'features/search/search_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/profile/favorites_screen.dart';
import 'features/profile/addresses_screen.dart';
import 'features/profile/payment_methods_screen.dart';
import 'features/profile/help_center_screen.dart';
import 'features/profile/privacy_policy_screen.dart';
import 'features/profile/terms_conditions_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  runApp(const BurgerKnightApp());
}

Future<void> _initializeServices() async {
  // Initialize data repository
  await DataRepository().initialize();
  
  // Initialize auth service
  await AuthService().initialize();
  
  // Initialize cart service
  await CartService().initialize();
  
  // Initialize favorite service
  await FavoriteService().initialize();
  
  // Initialize order service
  await OrderService().initialize();
}

class BurgerKnightApp extends StatelessWidget {
  const BurgerKnightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Burger Knight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _createRoute(const SplashScreen());
          case '/onboarding':
            return _createRoute(const OnboardingScreen());
          case '/login':
            return _createRoute(const LoginScreen());
          case '/signup':
            return _createRoute(const SignUpScreen());
          case '/main':
            // Always create a fresh MainScreen instance to ensure proper state
            return _createRoute(const MainScreen());
          case '/cart':
            return _createSlideUpRoute(const CartScreen());
          case '/checkout':
            return _createRoute(const CheckoutScreen());
          case '/orders':
            return _createRoute(const OrdersScreen());
          case '/product':
            if (settings.arguments is ProductModel) {
              final product = settings.arguments as ProductModel;
              return _createRoute(ProductDetailScreen(product: product));
            } else if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              return _createRoute(ProductDetailScreen(
                product: args['product'] as ProductModel,
                heroTag: args['heroTag'] as String?,
              ));
            }
            return _createRoute(const SplashScreen());
          case '/search':
            return _createRoute(const SearchScreen());
          case '/order-detail':
            final orderId = settings.arguments as String;
            return _createRoute(OrderDetailScreen(orderId: orderId));
          case '/order-track':
            final orderId = settings.arguments as String;
            return _createRoute(OrderTrackingScreen(orderId: orderId));
          case '/notifications':
            return _createRoute(const NotificationsScreen());
          case '/edit-profile':
            return _createRoute(const EditProfileScreen());
          case '/favorites':
            return _createRoute(const FavoritesScreen());
          case '/addresses':
            return _createRoute(const AddressesScreen());
          case '/payment-methods':
            return _createRoute(const PaymentMethodsScreen());
          case '/help-center':
            return _createRoute(const HelpCenterScreen());
          case '/privacy-policy':
            return _createRoute(const PrivacyPolicyScreen());
          case '/terms-conditions':
            return _createRoute(const TermsConditionsScreen());
          default:
            return _createRoute(const SplashScreen());
        }
      },
    );
  }

  // Standard page transition
  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Slide up transition for modals like cart
  PageRouteBuilder _createSlideUpRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
