import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // مكتبة النقط الأساسية
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/auth/presentation/view_models/on_boarding_model.dart';
import 'package:t_store/features/auth/presentation/logic/on_boarding/on_boarding_cubit.dart';
import 'package:t_store/features/auth/presentation/widgets/on_boarding_page.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/local_preferences_helper.dart'; 

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int currentPage = 0; // عشان نتابع إحنا في أي صفحة ونغير الأرقام والزراير

  @override
  Widget build(BuildContext context) {
    final onBoardingCubit = context.read<OnBoardingCubit>();
    final pageController = onBoardingCubit.pageController;

    return Scaffold(
      backgroundColor: TColors.light, // أبيض ناصع زي التصميم
      appBar: AppBar(
        backgroundColor: TColors.light,
        elevation: 0,
        automaticallyImplyLeading: false,
        // رقم الصفحة على الشمال (1/3)
        title: Text(
          '${currentPage + 1}/3',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: TColors.textPrimary,
          ),
        ),
        actions: [
          // زرار Skip على اليمين
          TextButton(
            onPressed: () async {
              await sl<LocalPreferencesHelper>().setHasSeenOnboarding(true);
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              }
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary, // أسود زي التصميم
              ),
            ),
          ),
          const SizedBox(width: TSizes.defaultSpace),
        ],
      ),
      body: Column(
        children: [
          // الـ PageView اللي بتتحرك
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
                onBoardingCubit.updatePageIndicator(index);
              },
              physics: const BouncingScrollPhysics(),
              children: [
                OnBoardingPage(
                  onBoardingModel: OnBoardingModel(
                    image: TImages.onBoardingImage1,
                    title: TTexts.onBoardingTitle1,
                    subTitle: TTexts.onBoardingSubTitle1,
                  ),
                ),
                OnBoardingPage(
                  onBoardingModel: OnBoardingModel(
                    image: TImages.onBoardingImage2,
                    title: TTexts.onBoardingTitle2,
                    subTitle: TTexts.onBoardingSubTitle2,
                  ),
                ),
                OnBoardingPage(
                  onBoardingModel: OnBoardingModel(
                    image: TImages.onBoardingImage3,
                    title: TTexts.onBoardingTitle3,
                    subTitle: TTexts.onBoardingSubTitle3,
                  ),
                ),
              ],
            ),
          ),
          
          // الشريط اللي تحت (Prev - Dots - Next)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TSizes.defaultSpace, 
              vertical: TSizes.defaultSpace,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زرار Prev
                TextButton(
                  onPressed: currentPage == 0
                      ? null // مقفول لو إحنا في أول صفحة
                      : () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                  child: Text(
                    'Prev',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: currentPage == 0
                          ? Colors.grey.withValues(alpha: 0.5) // باهت
                          : TColors.textSecondary, // رمادي غامق
                    ),
                  ),
                ),

                // النقط (Indicator)
                SmoothPageIndicator(
                  controller: pageController,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: TColors.textPrimary, // أسود للنقطة المفعلة
                    dotColor: TColors.borderPrimary, // رمادي فاتح للباقي
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3, // عشان النقطة تطول شوية زي التصميم
                  ),
                ),

                // زرار Next أو Get Started
                TextButton(
                  onPressed: () async {
                    if (currentPage == 2) {
                      await sl<LocalPreferencesHelper>().setHasSeenOnboarding(true);
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView()), 
                        );
                      }
                    } else {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    currentPage == 2 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColors.primary, // أحمر نكسورا
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
        ],
      ),
    );
  }
}