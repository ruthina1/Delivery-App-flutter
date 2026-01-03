import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/constants.dart';
import '../../services/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👤', style: TextStyle(fontSize: 80)),
              const SizedBox(height: AppSizes.paddingL),
              Text('Please login', style: AppTextStyles.heading3),
              const SizedBox(height: AppSizes.paddingL),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.only(
                top: 60,
                bottom: AppSizes.paddingL,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8F5C)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Top Actions
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.profile,
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingL),

                  // User Info
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: user.avatarUrl != null && 
                             user.avatarUrl!.isNotEmpty &&
                             (user.avatarUrl!.startsWith('http://') || 
                              user.avatarUrl!.startsWith('https://'))
                          ? Image.network(
                              user.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Text('👤', style: TextStyle(fontSize: 55)),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                            )
                          : const Center(
                              child: Text('👤', style: TextStyle(fontSize: 55)),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // User Name
                  Text(
                    user.name,
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Edit Profile Button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      AppStrings.editProfile,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListenableBuilder(
                  listenable: FavoriteService(),
                  builder: (context, child) {
                    final favoriteService = FavoriteService();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('15', 'Orders'),
                        _buildDivider(),
                        _buildStatItem(favoriteService.count.toString(), 'Favorites'),
                        _buildDivider(),
                        _buildStatItem('2', 'Addresses'),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.receipt_long_outlined,
                      title: AppStrings.myOrders,
                      onTap: () => Navigator.pushNamed(context, '/orders'),
                    ),
                    _buildMenuDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.favorite_border,
                      title: AppStrings.favorites,
                      onTap: () {
                        Navigator.pushNamed(context, '/favorites');
                      },
                    ),
                    _buildMenuDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.location_on_outlined,
                      title: AppStrings.addresses,
                      onTap: () {
                        Navigator.pushNamed(context, '/addresses');
                      },
                    ),
                    _buildMenuDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.credit_card_outlined,
                      title: AppStrings.paymentMethods,
                      onTap: () {
                        Navigator.pushNamed(context, '/payment-methods');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: AppStrings.notifications,
                      onTap: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeTrackColor: AppColors.primaryLight,
                        activeColor: AppColors.primary,
                      ),
                    ),
                    _buildMenuDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      title: AppStrings.helpCenter,
                      onTap: () {
                        Navigator.pushNamed(context, '/help-center');
                      },
                    ),
                    _buildMenuDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: AppStrings.privacyPolicy,
                      onTap: () {
                        Navigator.pushNamed(context, '/privacy-policy');
                      },
                    ),
                    _buildMenuDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.description_outlined,
                      title: AppStrings.termsConditions,
                      onTap: () {
                        Navigator.pushNamed(context, '/terms-conditions');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: AppStrings.logout,
                  iconColor: AppColors.error,
                  titleColor: AppColors.error,
                  showArrow: false,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppStrings.cancel,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _authService.signOut();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.border,
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: titleColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else if (showArrow)
              Icon(
                Icons.chevron_right,
                color: AppColors.textLight,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }
}

