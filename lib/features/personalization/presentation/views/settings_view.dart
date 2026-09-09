import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/cubits/theme_cubit/theme_cubit.dart';
import 'package:t_store/core/cubits/locale_cubit/locale_cubit.dart';
import 'package:t_store/core/utils/localizations/app_localizations.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/personalization/presentation/views/profile_view.dart';
import 'package:t_store/features/personalization/presentation/views/static_info_view.dart';
import 'package:t_store/features/personalization/presentation/views/user_addresses_view.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_state.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..getProfile(),
      child: const SettingsViewBody(),
    );
  }
}

class SettingsViewBody extends StatelessWidget {
  const SettingsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'settings'.tr(context),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: TColors.primary,
        backgroundColor: isDark ? TColors.darkContainer : Colors.white,
        onRefresh: () async {
          context.read<ProfileCubit>().getProfile();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'account'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // =========================
              // PROFILE
              // =========================
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  String displayName = 'جاري التحميل...';
                  String displayEmail = '';
                  String avatarUrl = '';

                  if (state is ProfileLoaded) {
                    displayName = state.user.fullName;
                    displayEmail = state.user.email;
                    avatarUrl = state.user.avatarUrl;
                  } else if (state is ProfileUpdated) {
                    displayName = state.user.fullName;
                    displayEmail = state.user.email;
                    avatarUrl = state.user.avatarUrl;
                  } else if (state is ProfileError) {
                    displayName = 'خطأ في جلب البيانات';
                    displayEmail = state.message;
                  }

                  return Material(
                    color: isDark
                        ? TColors.darkContainer
                        : TColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        TSizes.cardRadiusLg,
                      ),
                      side: BorderSide(
                        color: isDark
                            ? TColors.darkerGrey
                            : TColors.borderPrimary,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () async {
                        THelperFunctions.navigateToScreen(
                          context,
                          const ProfileView(),
                        );

                        if (context.mounted) {
                          context.read<ProfileCubit>().getProfile();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(TSizes.md),
                        child: Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 55,
                                height: 55,
                                child: avatarUrl.isNotEmpty
                                    ? Image.network(
                                        avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                              size: 35,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                          size: 35,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(
                              width: TSizes.spaceBtwItems,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    displayEmail,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? TColors.darkGrey
                                          : Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: TColors.darkGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // =========================
              // SETTINGS SECTION
              // =========================
              Text(
                'setting_section'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Addresses
              _buildSettingTile(
                icon: Iconsax.safe_home,
                title: 'Addresses',
                dark: isDark,
                onTap: () => THelperFunctions.navigateToScreen(
                  context,
                  const UserAddressesView(),
                ),
              ),

              // Notifications
              _buildSettingTile(
                icon: Iconsax.notification,
                title: 'notification'.tr(context),
                dark: isDark,
                onTap: () {},
              ),

              // Language
              BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  final isArabic = locale.languageCode == 'ar';

                  return _buildSettingTile(
                    icon: Iconsax.global,
                    title: 'language'.tr(context),
                    trailingText:
                        isArabic ? 'العربية' : 'English',
                    dark: isDark,
                    onTap: () {
                      final newLang =
                          isArabic ? 'en' : 'ar';

                      context
                          .read<LocaleCubit>()
                          .changeLanguage(newLang);
                    },
                  );
                },
              ),

              // Dark Mode
              _buildSwitchTile(
                icon: Iconsax.moon,
                title: 'dark_mode'.tr(context),
                value: isDark,
                dark: isDark,
                onChanged: (value) {
                  context
                      .read<ThemeCubit>()
                      .toggleTheme(value);
                },
              ),

              // =========================
              // PRIVACY POLICY
              // =========================
              _buildSettingTile(
                icon: Iconsax.security_card,
                title: 'privacy'.tr(context),
                dark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StaticInfoView(
                      title: 'Privacy Policy',
                      content: '''Your Privacy Matters

At Nexora, we value your privacy and are committed to protecting your personal information.

We may collect basic information such as your name, email address, delivery address, and account details to provide and improve our services.

How We Use Your Information

• To create and manage your account
• To process and manage orders
• To provide a personalized shopping experience
• To communicate important updates about your account and orders
• To improve our app and services

Your Data

We keep your information secure and do not sell your personal information to third parties. Your data is handled responsibly and only used when necessary to provide our services.

By using Nexora, you agree to this Privacy Policy.''',
                    ),
                  ),
                ),
              ),

              // =========================
              // HELP CENTER
              // =========================
              _buildSettingTile(
                icon: Iconsax.headphone,
                title: 'help_center'.tr(context),
                dark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StaticInfoView(
                      title: 'Help Center & Contact Us',
                      content: '''How can we help you?
Find answers to common questions or contact our support team for assistance.

Orders

How can I track my order?
How can I cancel an order?
What should I do if my order is delayed?

Payments

What payment methods are available?
Why did my payment fail?

Delivery

How long does delivery take?
Can I change my delivery address?

Account

How can I change my account information?
I forgot my password. What should I do?

Wishlist & Cart

How do I add a product to my wishlist?
How can I remove an item from my cart?

Still need help?

Our support team is here to help.

Contact Support
📧 support@nexora.com''',
                    ),
                  ),
                ),
              ),

              // =========================
              // ABOUT US
              // =========================
              _buildSettingTile(
                icon: Iconsax.info_circle,
                title: 'about_us'.tr(context),
                dark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StaticInfoView(
                      title: 'About Nexora',
                      content: '''Nexora is a modern e-commerce platform designed to make online shopping simple, convenient, and enjoyable.

Our goal is to provide customers with a smooth shopping experience where they can easily discover products, compare options, save favorites, and manage their purchases in one place.

Our Mission

To create a simple and reliable shopping experience by combining a user-friendly interface with convenient features and quality products.

What We Offer

• Easy and convenient shopping
• Fast product search and filtering
• Personalized wishlist
• Simple order management
• Secure account management
• Clean and user-friendly experience

Nexora — Your next shopping experience.''',
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SETTING TILE
  // ============================================================

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required bool dark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: TSizes.spaceBtwItems,
      ),
      child: Material(
        color: dark
            ? TColors.darkContainer
            : TColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            TSizes.cardRadiusLg,
          ),
          side: BorderSide(
            color: dark
                ? TColors.darkerGrey
                : TColors.borderPrimary,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: ListTile(
          leading: Icon(
            icon,
            color: dark
                ? Colors.white
                : Colors.black,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Text(
                  trailingText,
                  style: TextStyle(
                    color: dark
                        ? TColors.darkGrey
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              if (trailingText != null)
                const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: TColors.darkGrey,
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  // ============================================================
  // SWITCH TILE
  // ============================================================

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required bool dark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: TSizes.spaceBtwItems,
      ),
      child: Material(
        color: dark
            ? TColors.darkContainer
            : TColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            TSizes.cardRadiusLg,
          ),
          side: BorderSide(
            color: dark
                ? TColors.darkerGrey
                : TColors.borderPrimary,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: SwitchListTile(
          secondary: Icon(
            icon,
            color: dark
                ? Colors.white
                : Colors.black,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeThumbColor: TColors.primary,
        ),
      ),
    );
  }
}

