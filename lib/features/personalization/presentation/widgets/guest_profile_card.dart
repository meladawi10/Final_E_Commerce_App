import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart'; // تأكد من مسار صفحة تسجيل الدخول

class GuestProfileCard extends StatelessWidget {
  const GuestProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () {
        // عند الضغط، يوجه المستخدم لصفحة تسجيل الدخول مباشرة
        THelperFunctions.navigateToScreen(context, const LoginView());
      },
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          // خلفية راقية بتدرج لوني خفيف
          gradient: LinearGradient(
            colors: dark
                ? [TColors.darkContainer, TColors.darkerGrey]
                : [Colors.white, TColors.light],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(
            color: TColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. أيقونة المستخدم الافتراضية (بدل الصورة الشخصية)
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: TColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: TColors.primary.withValues(alpha: 0.5), width: 1),
              ),
              child: const Center(
                child: Icon(
                  Iconsax.user,
                  size: 28,
                  color: TColors.primary,
                ),
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            
            // 2. النصوص التحفيزية لتسجيل الدخول
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Guest',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white : TColors.dark,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Log in to view your profile',
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // 3. زر الدخول (شكل بصري لزيادة التفاعل)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}