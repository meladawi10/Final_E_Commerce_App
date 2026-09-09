import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';

class ProductMetadata extends StatelessWidget {
  const ProductMetadata({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // السعر والخصم
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: TColors.warning.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
              ),
              child: const Text('25%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            const Text(
              '\$250',
              style: TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough, color: TColors.darkGrey),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            const Text(
              '\$175',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TColors.primary),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 1.5),
        
        // العنوان
        const Text(
          'Women Printed Kurta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 1.5),

        // حالة التوفر
        Row(
          children: [
            const Text('Stock: ', style: TextStyle(color: TColors.darkGrey)),
            Text('In Stock', style: TextStyle(fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black)),
          ],
        ),
      ],
    );
  }
}