import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<WishlistCubit>().getWishlist());

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.lightContainer,
      appBar: AppBar(title: const Text('Wishlist')),
      body: BlocConsumer<WishlistCubit, WishlistState>(
        listener: (context, state) {
          if (state is WishlistError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is WishlistItemRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed')));
          }
        },
        builder: (context, state) {
          if (state is WishlistLoading) {
            return const Center(child: CircularProgressIndicator(color: TColors.primary));
          }
          if (state is WishlistLoaded) {
            final items = state.items;
            if (items.isEmpty) return const Center(child: Text('Your Wishlist is Empty!'));
            return RefreshIndicator(
              color: TColors.primary,
              onRefresh: () async => await context.read<WishlistCubit>().getWishlist(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 220,
                  ),
                  itemBuilder: (context, index) {
                    final product = items[index].product;
                    if (product == null) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => THelperFunctions.navigateToScreen(context, ProductDetailsView(product: product)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: dark ? TColors.darkContainer : TColors.white,
                          border: Border.all(color: dark ? TColors.darkerGrey : TColors.borderPrimary),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 110, width: double.infinity, padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: dark ? TColors.dark : TColors.lightContainer,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                              ),
                              child: Stack(
                                children: [
                                  Center(child: Image.network(product.thumbnail ?? '', fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag))),
                                  Positioned(
                                    top: 0, right: 0,
                                    child: GestureDetector(
                                      onTap: () => context.read<WishlistCubit>().removeFromWishlist(product.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(color: dark ? TColors.dark : TColors.white, shape: BoxShape.circle),
                                        child: const Icon(Iconsax.heart5, color: Colors.red, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark ? TColors.textWhite : TColors.textPrimary), maxLines: 1),
                                  const SizedBox(height: 2),
                                  Text(product.brandName ?? 'Nexora', style: const TextStyle(fontSize: 10, color: TColors.textSecondary), maxLines: 1),
                                  const SizedBox(height: 4),
                                  Text('\$${product.price}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark ? TColors.textWhite : TColors.textPrimary)),
                                ],
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
          return const Center(child: Text('No favorites yet'));
        },
      ),
    );
  }
}
