import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';

import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

import 'package:t_store/features/shop/presentation/views/product_details_view.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WishlistCubit>().getWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.lightContainer,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Wishlist',
          style: TextStyle(
            color: dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<WishlistCubit, WishlistState>(
        listener: (context, state) {
          if (state is WishlistError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is WishlistItemRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Removed from Wishlist'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        builder: (context, state) {
          // =========================
          // LOADING / INITIAL
          // (فيكس: نعرض اللودينج بدل ما يفلاش "Empty" غلط)
          // =========================
          if (state is WishlistLoading || state is WishlistInitial) {
            return const Center(
              child: CircularProgressIndicator(color: TColors.primary),
            );
          }

          // =========================
          // LOADED
          // =========================
          if (state is WishlistLoaded) {
            // فيكس: نستبعد أي عنصر مالوش product مرتبط بيه
            // بدل ما نسيبه فاضي جوه الـ Grid
            final items =
                state.items.where((e) => e.product != null).toList();

            if (items.isEmpty) {
              return RefreshIndicator(
                color: TColors.primary,
                onRefresh: () async =>
                    await context.read<WishlistCubit>().getWishlist(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.heart,
                                size: 80, color: TColors.darkGrey),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            Text(
                              'Your Wishlist is Empty!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: dark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: TColors.primary,
              onRefresh: () async =>
                  await context.read<WishlistCubit>().getWishlist(),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: TSizes.gridViewSpacing,
                    crossAxisSpacing: TSizes.gridViewSpacing,
                    mainAxisExtent: 270,
                  ),
                  itemBuilder: (context, index) {
                    final wishlistItem = items[index];
                    final product = wishlistItem.product!;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsView(product: product),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: dark
                              ? TColors.darkContainer
                              : TColors.white,
                          borderRadius: BorderRadius.circular(
                            TSizes.productImageRadius,
                          ),
                          border: Border.all(
                            color: dark
                                ? TColors.darkerGrey
                                : TColors.borderPrimary,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // IMAGE
                            Container(
                              height: 130,
                              width: double.infinity,
                              padding: const EdgeInsets.all(TSizes.sm),
                              decoration: BoxDecoration(
                                color: dark
                                    ? TColors.dark
                                    : TColors.lightContainer,
                                borderRadius: BorderRadius.circular(
                                  TSizes.borderRadiusMd,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: product.thumbnail != null &&
                                            product.thumbnail!.isNotEmpty
                                        ? Image.network(
                                            product.thumbnail!,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, st) {
                                              return const Icon(
                                                Icons.shopping_bag,
                                                size: 50,
                                                color: TColors.primary,
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.shopping_bag,
                                            size: 50,
                                            color: TColors.primary,
                                          ),
                                  ),
                                  // REMOVE BUTTON
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: dark
                                            ? TColors.darkContainer
                                            : Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () async {
                                          await context
                                              .read<WishlistCubit>()
                                              .removeFromWishlist(
                                                product.id,
                                              );
                                        },
                                        icon: const Icon(
                                          Iconsax.heart5,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: TSizes.spaceBtwItems / 2,
                            ),
                            // PRODUCT NAME
                            Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: dark ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            // BRAND
                            Text(
                              product.brandName ?? 'Nexora',
                              style: TextStyle(
                                color: dark
                                    ? TColors.darkGrey
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            // PRICE
                            Text(
                              '\$${product.price}',
                              style: const TextStyle(
                                color: TColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          // =========================
          // ERROR (بدل ما نسيب رسالة عمومية غامضة)
          // =========================
          if (state is WishlistError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: Colors.red),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<WishlistCubit>().getWishlist(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}