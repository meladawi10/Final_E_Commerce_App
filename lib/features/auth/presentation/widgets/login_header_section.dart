import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/colors.dart';

class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: TSizes.xl),
        
        Text.rich(
          TextSpan(
            children: [
              // كلمة Welcome ومسافة (بدون نزول سطر)
              TextSpan(
                text: "Welcome ", 
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 32, // نفس المقاس عشان التناسق
                      color: TColors.textPrimary,
                    ),
              ),
              
              // كلمة NEXORA (بولد بلون البراند)
              TextSpan(
                text: "NEXORA",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 32, // نفس المقاس
                      color: TColors.primary,
                      letterSpacing: 1.5,
                    ),
              ),
            ],
          ),
        ),
        
        const SizedBox(
          height: TSizes.spaceBtwSections,
        ),
      ],
    );
  }
}