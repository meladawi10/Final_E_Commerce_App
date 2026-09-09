import 'package:flutter/material.dart';

import 'package:t_store/core/common/view_models/horizontal_small_list_view_item_view_model.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';

class HorizontalSmallListViewItem extends StatelessWidget {
  const HorizontalSmallListViewItem({
    super.key,
    required this.item,
  });

  final HorizontalSmallListViewItemModel item;

  /// تحويل اسم الـ Category إلى الـ slug
  /// الذي يفهمه DummyJSON
  String _getCategoryId(String title) {
    final value = title.toLowerCase().trim();

    switch (value) {
      // Shirts
      case 'shirts':
      case 'shirt':
      case 'mens shirts':
      case "men's shirts":
      case 'mens-shirts':
        return 'mens-shirts';

      // Beauty
      case 'beauty':
        return 'beauty';

      // Laptop
      case 'laptop':
      case 'laptops':
        return 'laptops';

      // Mobile
      case 'mobile':
      case 'mobiles':
      case 'smartphone':
      case 'smartphones':
        return 'smartphones';

      // Furniture
      case 'furniture':
        return 'furniture';

      // Sports
      case 'sports':
      case 'sports accessories':
      case 'sports-accessories':
        return 'sports-accessories';

      default:
        // مهم:
        // ما نرجعش smartphones كـ default
        // لأن ده كان بيخلي أي Category غير معروفة
        // تعرض منتجات الموبايلات.
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () {
        final categoryId = _getCategoryId(item.title);

        debugPrint('======================================');
        debugPrint('CATEGORY CLICKED');
        debugPrint('Title: ${item.title}');
        debugPrint('API Category ID: $categoryId');
        debugPrint('======================================');

        THelperFunctions.navigateToScreen(
          context,
          SubCategoryView(
            categoryTitle: item.title,
            categoryName: categoryId,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          right: TSizes.defaultSpace,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 56,
              width: 56,
              padding: const EdgeInsets.all(
                TSizes.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(100),
                ),
                color: item.backgroundColor ??
                    (dark ? TColors.white : TColors.black),
              ),
              child: Center(
                child: Image(
                  image: AssetImage(item.image),
                  fit: BoxFit.cover,
                  color: dark
                      ? TColors.black
                      : TColors.white,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Icon(
                      Icons.category_outlined,
                      color: dark
                          ? TColors.black
                          : TColors.white,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: TSizes.spaceBtwItems / 2,
            ),
            SizedBox(
              width: 55,
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .apply(
                      color: item.textColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}