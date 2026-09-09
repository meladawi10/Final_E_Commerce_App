import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/features/personalization/presentation/views/settings_view.dart';
import 'package:t_store/features/shop/presentation/views/home_view.dart';
import 'package:t_store/features/shop/presentation/views/cart_view.dart';
import 'package:t_store/features/shop/presentation/views/wishlist_view.dart';
import 'package:t_store/features/shop/presentation/views/search_view.dart'; // استيراد شاشة البحث الحقيقية
import 'package:t_store/core/utils/localizations/app_localizations.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int selectedIndex = 0;

  // لستة الشاشات بعد ربط شاشة البحث الحقيقية
  final screens = [
    const HomeView(),     // 0: Home
    const WishlistView(), // 1: Wishlist
    const CartView(),     // 2: Cart
    const SearchView(),   // 3: Search (تم ربطها هنا بنجاح)
    const SettingsView(), // 4: Setting
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: Container(
        height: 75,
        decoration: BoxDecoration(
          color: dark ? TColors.dark : TColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 1. Home
            _buildNavItem(
              icon: Iconsax.home,
              label: 'home'.tr(context),
              index: 0,
              dark: dark,
            ),
            // 2. Wishlist
            _buildNavItem(
              icon: Iconsax.heart,
              label: 'wishlist'.tr(context),
              index: 1,
              dark: dark,
            ),
            // 3. Cart (الزرار البارز في المنتصف)
            Transform.translate(
              offset: const Offset(0, -15),
              child: GestureDetector(
                onTap: () => setState(() => selectedIndex = 2),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: dark ? TColors.darkContainer : TColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: selectedIndex == 2 
                          ? TColors.primary 
                          : (dark ? TColors.darkerGrey : TColors.borderPrimary),
                      width: selectedIndex == 2 ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    Iconsax.shopping_cart,
                    color: selectedIndex == 2 ? TColors.primary : (dark ? TColors.white : TColors.black),
                    size: 26,
                  ),
                ),
              ),
            ),
            // 4. Search
            _buildNavItem(
              icon: Iconsax.search_normal,
              label: 'search'.tr(context),
              index: 3,
              dark: dark,
            ),
            // 5. Setting
            _buildNavItem(
              icon: Iconsax.setting,
              label: 'settings'.tr(context),
              index: 4,
              dark: dark,
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء عناصر الشريط العادية مع دعم الترجمة
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool dark,
  }) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? TColors.primary : (dark ? TColors.darkGrey : Colors.grey),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? TColors.primary : (dark ? TColors.darkGrey : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}