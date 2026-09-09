import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/view_models/on_boarding_model.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.onBoardingModel,
  });
  
  final OnBoardingModel onBoardingModel;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // توسيط المحتوى
        children: [
          Image(
            width: THelperFunctions.screenWidth(context) * 0.8,
            height: THelperFunctions.screenHeight(context) * 0.5,
            image: AssetImage(onBoardingModel.image),
            fit: BoxFit.contain, // عشان الصورة متتمطش
          ),
          Text(
            onBoardingModel.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900, // خط عريض جداً زي التصميم
                  color: TColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: TSizes.spaceBtwItems,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0), // لم الكلمة شوية من الجناب
            child: Text(
              onBoardingModel.subTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TColors.textSecondary, // رمادي فاتح
                    height: 1.5, // مسافة بين السطور أريح للعين
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}