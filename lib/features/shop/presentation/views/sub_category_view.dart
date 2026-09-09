import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:t_store/core/dependency_injection/service_locator.dart';

import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class SubCategoryView extends StatelessWidget {
  final String categoryTitle;
  final String categoryName;

  const SubCategoryView({
    super.key,
    required this.categoryTitle,
    required this.categoryName,
  });

  // ============================================================
  // NORMALIZE CATEGORY
  // ============================================================

  String _normalizeCategory(String category) {
    final value = category
        .toLowerCase()
        .trim()
        .replaceAll('_', '-')
        .replaceAll(' ', '-');

    switch (value) {
      case 'shirt':
      case 'shirts':
      case 'mens-shirt':
      case 'mens-shirts':
      case "men's-shirt":
      case "men's-shirts":
        return 'mens-shirts';

      case 'beauty':
      case 'beauty-products':
        return 'beauty';

      case 'laptop':
      case 'laptops':
      case 'computer':
      case 'computers':
        return 'laptops';

      case 'mobile':
      case 'mobiles':
      case 'mobile-phone':
      case 'mobile-phones':
      case 'phone':
      case 'phones':
      case 'smartphone':
      case 'smartphones':
        return 'smartphones';

      case 'furniture':
      case 'home-furniture':
        return 'furniture';

      case 'sport':
      case 'sports':
      case 'sport-accessories':
      case 'sports-accessories':
        return 'sports-accessories';

      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestedCategory =
        _normalizeCategory(categoryName);

    debugPrint('================================');
    debugPrint('SUB CATEGORY VIEW');
    debugPrint('Title: $categoryTitle');
    debugPrint('Category received: $categoryName');
    debugPrint(
      'Category normalized: $requestedCategory',
    );
    debugPrint('================================');

    return BlocProvider(
      create: (_) => sl<ProductsCubit>()
        ..getProducts(
          // IMPORTANT:
          // Send the normalized DummyJSON slug
          categoryId: requestedCategory,
          refresh: true,
        ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
          ),
          title: Text(
            categoryTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            // ============================================================
            // LOADING
            // ============================================================

            if (state is ProductsInitial ||
                state is ProductsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ============================================================
            // ERROR
            // ============================================================

            if (state is ProductsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }

            // ============================================================
            // PRODUCTS
            // ============================================================

            if (state is ProductsLoaded) {
              // ==========================================================
              // FINAL PROTECTION
              // ==========================================================

              final List<ProductEntity> products =
                  state.products.where((product) {
                final productCategory =
                    _normalizeCategory(
                  product.categoryId,
                );

                final isMatch =
                    productCategory ==
                        requestedCategory;

                debugPrint(
                  'Product: ${product.name} | '
                  'Category: ${product.categoryId} | '
                  'Normalized: $productCategory | '
                  'Match: $isMatch',
                );

                return isMatch;
              }).toList();

              debugPrint(
                'FINAL PRODUCTS COUNT: ${products.length}',
              );

              if (products.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'عذراً، لا توجد منتجات متاحة في قسم $categoryTitle حالياً',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: products.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // IMAGE
                          // ==================================================

                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey.shade100,
                              child:
                                  product.thumbnail != null &&
                                          product.thumbnail!
                                              .isNotEmpty
                                      ? Image.network(
                                          product.thumbnail!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Icon(
                                              Icons
                                                  .image_not_supported,
                                              size: 50,
                                              color:
                                                  Colors.grey,
                                            );
                                          },
                                        )
                                      : const Icon(
                                          Icons
                                              .image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                            ),
                          ),

                          // ==================================================
                          // PRODUCT INFO
                          // ==================================================

                          Padding(
                            padding:
                                const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '\$${product.effectivePrice.toStringAsFixed(2)}',
                                        style:
                                            const TextStyle(
                                          color: Colors.blue,
                                          fontWeight:
                                              FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                      ),
                                    ),

                                    if (product.hasDiscount)
                                      const SizedBox(
                                        width: 4,
                                      ),

                                    if (product.hasDiscount)
                                      Expanded(
                                        child: Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.grey,
                                            fontSize: 11,
                                            decoration:
                                                TextDecoration
                                                    .lineThrough,
                                          ),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}