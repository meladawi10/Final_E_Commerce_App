import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class AllProductsView extends StatelessWidget {
  final String title;
  final String? categoryId;
  final bool? isFeatured;

  const AllProductsView({
    super.key,
    required this.title,
    this.categoryId,
    this.isFeatured,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = THelperFunctions.isDarkMode(context);

    return BlocProvider(
      // 🌟 تمرير الـ categoryId والـ isFeatured للـ Cubit ليقوم بطلب المنتجات المفلترة من الـ API
      create: (context) => sl<ProductsCubit>()..getProducts(
        categoryId: categoryId,
        isFeatured: isFeatured,
        refresh: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (state is ProductsLoaded) {
              final products = state.products;

              if (products.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد منتجات متاحة في هذا القسم حالياً',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: TSizes.spaceBtwItems,
                  crossAxisSpacing: TSizes.spaceBtwItems,
                  childAspectRatio: 0.72,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  final double salePrice = (product.salePrice ?? 0).toDouble();
                  // ignore: dead_code, dead_null_aware_expression
                  final double price = (product.price ?? 0).toDouble();
                  final displayPrice = salePrice > 0 ? salePrice : price;

                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? TColors.darkContainer : Colors.white,
                      borderRadius: BorderRadius.circular(TSizes.productImageRadius),
                      border: Border.all(
                        color: isDark ? TColors.darkerGrey : TColors.borderPrimary,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(TSizes.productImageRadius),
                            ),
                            child: (product.thumbnail != null && product.thumbnail!.isNotEmpty)
                                ? Image.network(
                                    product.thumbnail!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 40),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$displayPrice \$',
                                style: const TextStyle(
                                  color: TColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}