import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';

import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';

import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  // ============================================================
  // CATEGORY NAME -> DUMMYJSON CATEGORY
  // ============================================================

  String _getCategorySlug(String categoryName) {
    final value = categoryName
        .toLowerCase()
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    switch (value) {
      case 'shirt':
      case 'shirts':
      case 'mens shirt':
      case 'mens shirts':
      case "men's shirt":
      case "men's shirts":
        return 'mens-shirts';

      case 'beauty':
      case 'beauty products':
        return 'beauty';

      case 'laptop':
      case 'laptops':
      case 'computer':
      case 'computers':
        return 'laptops';

      case 'mobile':
      case 'mobiles':
      case 'mobile phone':
      case 'mobile phones':
      case 'phone':
      case 'phones':
      case 'smartphone':
      case 'smartphones':
        return 'smartphones';

      case 'furniture':
      case 'home furniture':
        return 'furniture';

      case 'sport':
      case 'sports':
      case 'sport accessories':
      case 'sports accessories':
        return 'sports-accessories';

      default:
        debugPrint(
          'WARNING: Unknown category: $categoryName',
        );

        return value.replaceAll(' ', '-');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        // ============================================================
        // LOADING
        // ============================================================

        if (state is CategoriesInitial ||
            state is CategoriesLoading) {
          return SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    right: TSizes.spaceBtwItems,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: dark
                              ? TColors.darkContainer
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 45,
                        height: 10,
                        decoration: BoxDecoration(
                          color: dark
                              ? TColors.darkContainer
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        // ============================================================
        // ERROR
        // ============================================================

        if (state is CategoriesError) {
          return SizedBox(
            height: 90,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }

        // ============================================================
        // LOADED
        // ============================================================

        if (state is CategoriesLoaded) {
          final categories = state.categories
              .where((category) => category.isActive)
              .toList();

          if (categories.isEmpty) {
            return SizedBox(
              height: 90,
              child: Center(
                child: Text(
                  'No categories available',
                  style: TextStyle(
                    color: dark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }

          return SizedBox(
            height: 90,
            child: ListView.builder(
              itemCount: categories.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final category = categories[index];

                final categorySlug =
                    _getCategorySlug(category.name);

                return GestureDetector(
                  onTap: () {
                    debugPrint('================================');
                    debugPrint('CATEGORY CLICKED');
                    debugPrint('Name: ${category.name}');
                    debugPrint('Supabase ID: ${category.id}');
                    debugPrint(
                      'DummyJSON Slug: $categorySlug',
                    );
                    debugPrint('================================');

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SubCategoryView(
                          categoryTitle: category.name,

                          // IMPORTANT:
                          // Send DummyJSON slug
                          categoryName: categorySlug,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: TSizes.spaceBtwItems,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(
                            TSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: dark
                                ? TColors.darkContainer
                                : TColors.light,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: dark
                                  ? TColors.darkerGrey
                                  : TColors.borderPrimary,
                            ),
                          ),
                          child: Center(
                            child: _CategoryImage(
                              category: category,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: TSizes.spaceBtwItems / 2,
                        ),

                        SizedBox(
                          width: 60,
                          child: Text(
                            category.name,
                            style: TextStyle(
                              color: dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
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

        return const SizedBox.shrink();
      },
    );
  }
}

// ============================================================
// CATEGORY IMAGE
// ============================================================

class _CategoryImage extends StatelessWidget {
  final CategoryEntity category;

  const _CategoryImage({
    required this.category,
  });

  String? _getLocalFallbackImage() {
    switch (category.name.toLowerCase().trim()) {
      case 'shirts':
      case 'shirt':
        return 'assets/images/categories/mens-shirts.png';

      case 'beauty':
        return 'assets/icon/categories/beauty.png';

      case 'laptop':
      case 'laptops':
        return 'assets/icon/categories/laptop.png';

      case 'mobile':
      case 'mobiles':
      case 'smartphones':
        return 'assets/icon/categories/mobile.png';

      case 'furniture':
        return 'assets/icon/categories/furniture.png';

      case 'sports':
      case 'sports accessories':
        return 'assets/icon/categories/sports-accessories.png';

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkUrl = category.imageUrl;

    if (networkUrl != null && networkUrl.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          networkUrl,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          loadingBuilder: (
            context,
            child,
            loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }

            return const SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return _buildLocalFallback();
          },
        ),
      );
    }

    return _buildLocalFallback();
  }

  Widget _buildLocalFallback() {
    final imagePath = _getLocalFallbackImage();

    if (imagePath == null) {
      return const Icon(
        Icons.category_outlined,
        color: TColors.primary,
        size: 28,
      );
    }

    return ClipOval(
      child: Image.asset(
        imagePath,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Icon(
            Icons.category_outlined,
            color: TColors.primary,
            size: 28,
          );
        },
      ),
    );
  }
}