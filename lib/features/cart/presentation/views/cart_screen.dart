import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';

import 'package:t_store/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_state.dart';

import 'package:t_store/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:t_store/features/checkout/presentation/views/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<CartCubit>().getCartItems();
      }
    });

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.lightContainer,

      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),

      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: TColors.primary,
              ),
            );
          }

          if (state is CartLoaded) {
            final items = state.items;

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.shopping_cart,
                      size: 70,
                      color: dark
                          ? Colors.white54
                          : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Cart is Empty!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dark
                            ? Colors.white
                            : TColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final product = item.product;

                      final image =
                          product?.thumbnail?.isNotEmpty == true
                              ? product!.thumbnail!
                              : '';

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(12),
                          color: dark
                              ? TColors.darkContainer
                              : TColors.white,
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            Container(
                              width: 60,
                              height: 60,
                              padding:
                                  const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(10),
                                color: dark
                                    ? TColors.dark
                                    : TColors.lightContainer,
                              ),
                              child: image.isNotEmpty
                                  ? Image.network(
                                      image,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.shopping_bag,
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.shopping_bag,
                                    ),
                            ),

                            const SizedBox(width: 12),

                            // Product Information
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product?.name ?? 'Product',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: dark
                                          ? TColors.textWhite
                                          : TColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: TColors.primary,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  // Quantity
                                  Row(
                                    children: [
                                      IconButton(
                                        padding:
                                            EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints(
                                          minWidth: 30,
                                          minHeight: 30,
                                        ),
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<CartCubit>()
                                              .decrementQuantity(
                                                item.id,
                                              );
                                        },
                                      ),

                                      Container(
                                        width: 30,
                                        alignment:
                                            Alignment.center,
                                        child: Text(
                                          item.quantity
                                              .toString(),
                                          style:
                                              const TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        padding:
                                            EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints(
                                          minWidth: 30,
                                          minHeight: 30,
                                        ),
                                        icon: const Icon(
                                          Icons.add,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<CartCubit>()
                                              .incrementQuantity(
                                                item.id,
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Delete Button
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(
                                Iconsax.trash,
                                color: Colors.red,
                                size: 19,
                              ),
                              onPressed: () async {
                                final shouldDelete =
                                    await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (dialogContext) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Remove Item',
                                      ),
                                      content: const Text(
                                        'Are you sure you want to remove this item from your cart?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                              dialogContext,
                                              false,
                                            );
                                          },
                                          child: const Text(
                                            'Cancel',
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                              dialogContext,
                                              true,
                                            );
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (shouldDelete == true &&
                                    context.mounted) {
                                  await context
                                      .read<CartCubit>()
                                      .removeFromCart(
                                        item.id,
                                      );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark
                        ? TColors.darkContainer
                        : TColors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text(
                            '\$${state.subtotal.toStringAsFixed(2)}',
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Shipping
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Shipping'),
                          Text(
                            state.shippingFee == 0
                                ? 'FREE'
                                : '\$${state.shippingFee.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: state.shippingFee == 0
                                  ? Colors.green
                                  : null,
                              fontWeight:
                                  state.shippingFee == 0
                                      ? FontWeight.bold
                                      : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Divider(),

                      const SizedBox(height: 4),

                      // Total
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${state.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Checkout
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          minimumSize:
                              const Size(double.infinity, 45),
                        ),
                        onPressed: () {
                          THelperFunctions.navigateToScreen(
                            context,
                            BlocProvider(
                              create: (context) =>
                                  sl<CheckoutCubit>(),
                              child: CheckoutScreen(
                                cartItems: items,
                                subtotal: state.subtotal,
                                shippingFee:
                                    state.shippingFee,
                                totalAmount:
                                    state.totalPrice,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('No cart items found'),
          );
        },
      ),
    );
  }
}