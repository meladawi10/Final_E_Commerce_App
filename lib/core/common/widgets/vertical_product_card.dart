import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class VerticalProductCard extends StatelessWidget {
  final ProductEntity product;

  const VerticalProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

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
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 9,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: dark ? TColors.darkerGrey : TColors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail, Badge & Wishlist Icon
            Container(
              height: 180,
              padding: const EdgeInsets.all(TSizes.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TSizes.productImageRadius),
                color: dark ? TColors.dark : TColors.light,
              ),
              child: Stack(
                children: [
                  // Product Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(TSizes.productImageRadius),
                      child: product.images.isNotEmpty && product.images.first.isNotEmpty
                          ? Image.network(
                              product.images.first,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, size: 80, color: TColors.primary),
                            )
                          : const Icon(Icons.shopping_bag, size: 80, color: TColors.primary),
                    ),
                  ),

                  // Sale Tag / Badge
                  Positioned(
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs / 2),
                      decoration: BoxDecoration(
                        color: TColors.secondary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(TSizes.sm),
                      ),
                      child: const Text(
                        '25% OFF',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Wishlist Icon Button — دلوقتي شغالة وبتحدث الويشليست فعليًا
                  Positioned(
                    top: 0,
                    right: 0,
                    child: BlocBuilder<WishlistCubit, WishlistState>(
                      builder: (context, state) {
                        final wishlistCubit = context.read<WishlistCubit>();
                        final inWishlist = wishlistCubit.isInWishlist(product.id);

                        return CircleAvatar(
                          radius: 16,
                          backgroundColor: dark ? TColors.dark.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              inWishlist ? Iconsax.heart5 : Iconsax.heart,
                              color: inWishlist ? Colors.red : (dark ? Colors.white : Colors.black),
                              size: 18,
                            ),
                            onPressed: () async {
                              final wasInWishlist = wishlistCubit.isInWishlist(product.id);

                              await wishlistCubit.toggleWishlist(product);

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    wasInWishlist ? 'Removed from Wishlist' : 'Added to Wishlist',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),

            // Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white : TColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),

                  // Brand Name
                  Row(
                    children: [
                      Text(
                        product.brandName ?? 'Nexora',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(color: TColors.darkGrey, fontSize: 11),
                      ),
                      const SizedBox(width: TSizes.xs),
                      const Icon(Icons.verified, color: TColors.primary, size: 12),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Price Row
            Padding(
              padding: const EdgeInsets.only(left: TSizes.sm, right: TSizes.sm, bottom: TSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.primary),
                  ),

                  // Add to Cart Button Container
                  Container(
                    decoration: const BoxDecoration(
                      color: TColors.dark,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(TSizes.cardRadiusMd),
                        bottomRight: Radius.circular(TSizes.productImageRadius),
                      ),
                    ),
                    child: const SizedBox(
                      width: TSizes.iconLg * 1.2,
                      height: TSizes.iconLg * 1.2,
                      child: Center(child: Icon(Icons.add, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}