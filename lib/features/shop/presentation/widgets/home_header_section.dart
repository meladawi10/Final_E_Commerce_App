import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 👈 استدعاء الـ Bloc
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart'; // 👈 استدعاء الـ Service Locator

// ⚠️ تأكد من صحة مسارات الـ import دي عندك
import 'package:t_store/features/personalization/presentation/cubit/profile_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_state.dart';
import 'package:t_store/features/personalization/presentation/views/profile_view.dart';

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.defaultSpace,
        vertical: TSizes.spaceBtwItems,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. اللوجو واسم الماركة (Nexora)
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/logos/nexoralogo.jpg',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ), 
              const SizedBox(width: TSizes.spaceBtwItems / 2),
              const Text(
                'Nexora',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: TColors.primary, 
                ),
              ),
            ],
          ),
          
          // 2. زرار صورة البروفايل الديناميكية 🚀
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileView()),
              );
            },
            child: BlocProvider(
              // بنشغل الكيوبت هنا عشان يجيب بيانات البروفايل أول ما الشاشة تفتح
              create: (context) => sl<ProfileCubit>()..getProfile(),
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  String avatarUrl = '';

                  // استخراج رابط الصورة لو البيانات رجعت بنجاح
                  if (state is ProfileLoaded) {
                    // ignore: dead_null_aware_expression, dead_code
                    avatarUrl = state.user.avatarUrl ?? '';
                  } else if (state is ProfileUpdated) {
                    // ignore: dead_null_aware_expression, dead_code
                    avatarUrl = state.user.avatarUrl ?? '';
                  }

                  return Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    // استخدام ClipOval عشان الصورة تاخد الشكل الدائري للكونتينر
                    child: ClipOval(
                      child: avatarUrl.isNotEmpty
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              // لو الصورة فيها مشكلة في التحميل، نعرض الأيقونة كبديل
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Iconsax.user, color: Colors.black54),
                            )
                          : const Icon(Iconsax.user, color: Colors.black54), // الأيقونة لو مفيش صورة
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}