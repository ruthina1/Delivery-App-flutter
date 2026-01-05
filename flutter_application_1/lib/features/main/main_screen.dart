import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../services/services.dart';
import '../home/home_screen.dart';
import '../menu/menu_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
    // Reset to home tab when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentIndex = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const MenuScreen(),
    const SizedBox(), // Placeholder for FAB
    const SizedBox(), // Orders - will navigate to separate screen
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    debugPrint('🔵 [MainScreen] _onTabTapped called with index: $index');
    if (!mounted) {
      debugPrint('🔴 [MainScreen] Widget not mounted, returning');
      return;
    }
    
    if (index == 2) {
      debugPrint('🟢 [MainScreen] Navigating to cart');
      Navigator.pushNamed(context, '/cart');
      return;
    }
    if (index == 3) {
      debugPrint('🟢 [MainScreen] Navigating to orders');
      try {
        Navigator.pushNamed(context, '/orders');
        debugPrint('✅ [MainScreen] Navigation to orders initiated successfully');
      } catch (e, stackTrace) {
        debugPrint('🔴 [MainScreen] ERROR navigating to orders: $e');
        debugPrint('🔴 [MainScreen] Stack trace: $stackTrace');
      }
      return;
    }
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure currentIndex is valid and reset to home if needed
    final safeIndex = _currentIndex.clamp(0, 4);
    final displayIndex = safeIndex == 4 ? 2 : (safeIndex > 1 ? safeIndex - 1 : safeIndex);
    
    return Scaffold(
      body: IndexedStack(
        index: displayIndex.clamp(0, 2),
        children: [
          _screens[0],
          _screens[1],
          _screens[4],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/cart'),
        elevation: 4,
        backgroundColor: AppColors.primary,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 26),
                    if (_cartService.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            _cartService.itemCount.toString(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: AppStrings.home,
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.restaurant_menu_outlined,
                  activeIcon: Icons.restaurant_menu,
                  label: 'Menu',
                  index: 1,
                ),
                const SizedBox(width: 60), // Space for FAB
                _buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: AppStrings.orders,
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: AppStrings.profile,
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = index < 2
        ? _currentIndex == index
        : index == 4
            ? _currentIndex == 4
            : false;

    return GestureDetector(
      onTap: () {
        debugPrint('🟢 [MainScreen] Nav item tapped - index: $index, label: $label');
        _onTabTapped(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textLight,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

