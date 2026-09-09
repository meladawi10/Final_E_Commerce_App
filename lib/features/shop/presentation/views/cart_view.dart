import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/presentation/cubit/cart_cubit.dart';
import 'package:t_store/features/shop/presentation/views/checkout_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.lightContainer,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Cart',
          style: TextStyle(
            color: dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        bloc: CartCubit(),
        builder: (context, state) {
          final cubit = CartCubit();
          final items = cubit.cartItems;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.bag, size: 80, color: TColors.darkGrey),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(
                    'Your Cart is Empty!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: TSizes.spaceBtwItems),
              itemBuilder: (context, index) {
                final item = items[index];

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: dark ? TColors.darkContainer : TColors.white,
                    borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                    border: Border.all(
                      color: dark ? TColors.darkerGrey : TColors.borderPrimary,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () => cubit.removeFromCart(index),
                          icon: const Icon(Iconsax.trash,
                              color: Colors.redAccent, size: 18),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 75,
                            height: 75,
                            padding: const EdgeInsets.all(TSizes.sm),
                            decoration: BoxDecoration(
                              color: dark ? TColors.dark : TColors.lightContainer,
                              borderRadius:
                                  BorderRadius.circular(TSizes.borderRadiusMd),
                            ),
                            child: item.image.startsWith('assets')
                                ? Image.asset(item.image, fit: BoxFit.contain)
                                : Image.network(
                                    item.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Image.asset(
                                      'assets/images/products/product-shirt.png',
                                    ),
                                  ),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: dark ? Colors.white : Colors.black,
                                  ),
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.brandName.isEmpty
                                      ? 'Nexora'
                                      : item.brandName,
                                  style: TextStyle(
                                    color: dark
                                        ? TColors.darkGrey
                                        : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.price,
                                      style: const TextStyle(
                                        color: TColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _buildQtyButton(
                                          icon: Icons.remove,
                                          dark: dark,
                                          onPressed: () =>
                                              cubit.updateQuantity(index, -1),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Text(
                                            item.quantity
                                                .toString()
                                                .padLeft(2, '0'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        _buildQtyButton(
                                          icon: Icons.add,
                                          dark: dark,
                                          isPrimary: true,
                                          onPressed: () =>
                                              cubit.updateQuantity(index, 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        bloc: CartCubit(),
        builder: (context, state) {
          final cubit = CartCubit();
          final subtotal = cubit.calculateSubtotal();
          final discount = subtotal > 0 ? 4.0 : 0.0;
          final delivery = subtotal > 0 ? 2.0 : 0.0;
          final total = subtotal > 0 ? (subtotal - discount + delivery) : 0.0;

          return Container(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            decoration: BoxDecoration(
              color: dark ? TColors.darkContainer : TColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(TSizes.cardRadiusLg),
                topRight: Radius.circular(TSizes.cardRadiusLg),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: dark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    _buildSummaryRow(
                        'Items', cubit.cartItems.length.toString(), dark),
                    const SizedBox(height: 6),
                    _buildSummaryRow('Subtotal',
                        '\$${subtotal.toStringAsFixed(0)}', dark),
                    const SizedBox(height: 6),
                    _buildSummaryRow('Discount',
                        '\$${discount.toStringAsFixed(0)}', dark),
                    const SizedBox(height: 6),
                    _buildSummaryRow('Delivery Charges',
                        '\$${delivery.toStringAsFixed(0)}', dark),
                    Divider(
                      height: 16,
                      color: dark ? TColors.darkerGrey : Colors.grey[300],
                    ),
                    _buildSummaryRow('Total',
                        '\$${total.toStringAsFixed(0)}', dark,
                        isTotal: true),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusLg),
                      ),
                    ),
                    onPressed: () {
                      if (cubit.cartItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Your cart is empty! Add items first.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutView(),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Check Out \$${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required bool dark,
    bool isPrimary = false,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 26,
      height: 26,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isPrimary
              ? TColors.primary
              : (dark ? TColors.darkerGrey : Colors.grey[200]),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        icon: Icon(
          icon,
          size: 14,
          color: isPrimary ? Colors.white : (dark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, bool dark,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isTotal
                ? (dark ? Colors.white : Colors.black)
                : (dark ? TColors.darkGrey : Colors.grey[600]),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 14 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? TColors.primary
                : (dark ? Colors.white : Colors.black),
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16 : 13,
          ),
        ),
      ],
    );
  }
}