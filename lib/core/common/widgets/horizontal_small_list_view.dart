import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';

class HorizontalSmallListView extends StatelessWidget {
  final List<ProductEntity> items;

  const HorizontalSmallListView({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 135,
      child: ListView.separated(
        itemCount: items.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsView(product: product),
                ),
              );
            },
            child: Container(
              width: 310, // توسيع العرض عشان الاسم يظهر كامل بدون قطع
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: dark ? TColors.darkerGrey : TColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // صورة المنتج بخلفية نظيفة
                  Container(
                    height: 118,
                    width: 118,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: dark ? TColors.dark : TColors.light,
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product.images.isNotEmpty && product.images.first.isNotEmpty
                            ? Image.network(
                                product.images.first,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, color: TColors.primary),
                              )
                            : const Icon(Icons.shopping_bag, color: TColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // تفاصيل المنتج (الاسم، البراند مع علامة صح، السعر، زر الإضافة)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : TColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              product.brandName ?? 'Nexora',
                              style: const TextStyle(color: TColors.darkGrey, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: TColors.primary, size: 12),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product.price}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: TColors.primary,
                              ),
                            ),
                            // زر الإضافة للسلة الصغير
                            Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: dark ? TColors.primary : TColors.dark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}