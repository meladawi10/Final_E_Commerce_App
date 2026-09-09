import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/utils/localizations/app_localizations.dart';

import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/cart_cubit.dart';

import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class ProductDetailsView extends StatelessWidget {
  final ProductEntity product;

  const ProductDetailsView({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit(),
      child: ProductDetailsViewBody(
        product: product,
      ),
    );
  }
}

class ProductDetailsViewBody extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsViewBody({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsViewBody> createState() =>
      _ProductDetailsViewBodyState();
}

class _ProductDetailsViewBodyState
    extends State<ProductDetailsViewBody> {
  String selectedSize = 'S';

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor:
          dark ? TColors.dark : TColors.lightContainer,

      // ============================================================
      // BOTTOM CART BAR
      // ============================================================

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(
          TSizes.defaultSpace / 1.5,
        ),
        decoration: BoxDecoration(
          color: dark
              ? TColors.darkerGrey
              : TColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(
              TSizes.cardRadiusLg,
            ),
            topRight: Radius.circular(
              TSizes.cardRadiusLg,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              // ==================================================
              // PRICE
              // ==================================================

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'checkout'.tr(context),
                    style: TextStyle(
                      fontSize: 12,
                      color: dark
                          ? Colors.white60
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${widget.product.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
                  ),
                ],
              ),

              // ==================================================
              // ADD TO CART
              // ==================================================

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: TSizes.spaceBtwItems,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(
                        TSizes.md,
                      ),
                      backgroundColor:
                          TColors.primary,
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: TColors.primary,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          TSizes.cardRadiusMd,
                        ),
                      ),
                    ),
                    onPressed: widget.product.stock <= 0
                        ? null
                        : () {
                            context
                                .read<CartCubit>()
                                .addToCart(
                                  CartItemModel(
                                    title:
                                        widget.product.name,
                                    price:
                                        '\$${widget.product.price}',
                                    image: widget
                                            .product
                                            .images
                                            .isNotEmpty
                                        ? widget.product
                                            .images.first
                                        : '',
                                    brandName:
                                        widget.product
                                                .brandName ??
                                            'Nexora',
                                  ),
                                );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Added to Cart Successfully! 🚀',
                                ),
                                duration:
                                    Duration(
                                  seconds: 1,
                                ),
                              ),
                            );
                          },
                    child: Text(
                      widget.product.stock <= 0
                          ? 'Out of Stock'
                          : 'add_to_cart'.tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ======================================================
            // PRODUCT IMAGE
            // ======================================================

            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: dark
                    ? TColors.darkContainer
                    : TColors.white,
                borderRadius:
                    const BorderRadius.only(
                  bottomLeft:
                      Radius.circular(30),
                  bottomRight:
                      Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // ==================================================
                  // IMAGE
                  // ==================================================

                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        TSizes.defaultSpace * 2,
                      ),
                      child: Center(
                        child: _buildProductImage(),
                      ),
                    ),
                  ),

                  // ==================================================
                  // TOP BUTTONS
                  // ==================================================

                  Positioned(
                    top: TSizes.spaceBtwSections,
                    left: TSizes.defaultSpace,
                    right: TSizes.defaultSpace,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        // BACK
                        _buildCircleButton(
                          context: context,
                          dark: dark,
                          icon: Icons.arrow_back,
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },
                        ),

                        // WISHLIST
                        BlocBuilder<
                            WishlistCubit,
                            WishlistState>(
                          builder:
                              (context, state) {
                            final wishlistCubit =
                                context.read<
                                    WishlistCubit>();

                            final inWishlist =
                                wishlistCubit
                                    .isInWishlist(
                              widget.product.id,
                            );

                            return _buildCircleButton(
                              context: context,
                              dark: dark,
                              icon: inWishlist
                                  ? Iconsax.heart5
                                  : Iconsax.heart,
                              iconColor:
                                  inWishlist
                                      ? Colors.red
                                      : (dark
                                          ? Colors.white
                                          : Colors.black),
                              onPressed: () async {
                                final wasInWishlist =
                                    wishlistCubit
                                        .isInWishlist(
                                  widget.product.id,
                                );

                                await wishlistCubit
                                    .toggleWishlist(
                                  widget.product,
                                );

                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger
                                        .of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      wasInWishlist
                                          ? 'Removed from Wishlist'
                                          : 'Added to Wishlist',
                                    ),
                                    duration:
                                        const Duration(
                                      seconds: 1,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // PRODUCT INFORMATION
            // ======================================================

            Padding(
              padding: const EdgeInsets.all(
                TSizes.defaultSpace,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // NAME + BRAND
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                            color: dark
                                ? Colors.white
                                : TColors.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color: TColors.primary
                              .withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            6,
                          ),
                        ),
                        child: Text(
                          widget.product.brandName ??
                              'Nexora',
                          style: const TextStyle(
                            color:
                                TColors.primary,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: TSizes.spaceBtwItems,
                  ),

                  // ==================================================
                  // RATING + STOCK
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.5',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              color: dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const Text(
                            ' (20)',
                            style: TextStyle(
                              color:
                                  TColors.darkGrey,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        widget.product.stock > 0
                            ? 'In Stock (${widget.product.stock})'
                            : 'Out of Stock',
                        style: TextStyle(
                          color: widget.product.stock > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),

                  // ==================================================
                  // DESCRIPTION TITLE
                  // ==================================================

                  Text(
                    _isArabic(context)
                        ? 'وصف المنتج'
                        : 'Product Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color: dark
                          ? Colors.white
                          : TColors.textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height:
                        TSizes.spaceBtwItems / 2,
                  ),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================

                  Text(
                    widget.product.description
                            ?.trim()
                            .isNotEmpty ==
                        true
                        ? widget.product.description!
                        : _isArabic(context)
                            ? 'لا يوجد وصف متاح لهذا المنتج.'
                            : 'No description available for this product.',
                    style: TextStyle(
                      color: dark
                          ? Colors.white70
                          : TColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),

                  // ==================================================
                  // SIZE TITLE
                  // ==================================================

                  Text(
                    _isArabic(context)
                        ? 'المقاس'
                        : 'Size',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color: dark
                          ? Colors.white
                          : TColors.textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: TSizes.spaceBtwItems,
                  ),

                  // ==================================================
                  // SIZES
                  // ==================================================

                  Row(
                    children: [
                      _buildSizeChip(
                        'S',
                        dark,
                      ),
                      const SizedBox(width: 8),
                      _buildSizeChip(
                        'M',
                        dark,
                      ),
                      const SizedBox(width: 8),
                      _buildSizeChip(
                        'L',
                        dark,
                      ),
                      const SizedBox(width: 8),
                      _buildSizeChip(
                        'XL',
                        dark,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                        TSizes.spaceBtwSections * 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // PRODUCT IMAGE
  // ==============================================================

  Widget _buildProductImage() {
    if (widget.product.images.isEmpty ||
        widget.product.images.first.trim().isEmpty) {
      return const Icon(
        Icons.shopping_bag,
        size: 120,
        color: TColors.primary,
      );
    }

    return Image.network(
      widget.product.images.first,
      fit: BoxFit.contain,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return const Icon(
          Icons.shopping_bag,
          size: 120,
          color: TColors.primary,
        );
      },
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: TColors.primary,
          ),
        );
      },
    );
  }

  // ==============================================================
  // CIRCLE BUTTON
  // ==============================================================

  Widget _buildCircleButton({
    required BuildContext context,
    required bool dark,
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return CircleAvatar(
      backgroundColor: dark
          ? TColors.dark
          : TColors.white,
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ??
              (dark
                  ? Colors.white
                  : Colors.black),
        ),
        onPressed: onPressed,
      ),
    );
  }

  // ==============================================================
  // SIZE CHIP
  // ==============================================================

  Widget _buildSizeChip(
    String size,
    bool dark,
  ) {
    final isSelected =
        selectedSize == size;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = size;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: isSelected
              ? TColors.primary
              : (dark
                  ? TColors.darkContainer
                  : Colors.white),
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? TColors.primary
                : (dark
                    ? TColors.darkerGrey
                    : TColors.borderPrimary),
          ),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (dark
                      ? Colors.white
                      : Colors.black),
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // ARABIC CHECK
  // ==============================================================

  bool _isArabic(BuildContext context) {
    final locale =
        Localizations.localeOf(context);

    return locale.languageCode == 'ar';
  }
}