import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:t_store/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:t_store/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:t_store/features/checkout/presentation/views/order_success_screen.dart';
import 'package:t_store/features/checkout/presentation/widgets/checkout_payment_section.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartItemEntity> cartItems;
  final double subtotal, shippingFee, totalAmount;

  const CheckoutScreen({super.key, required this.cartItems, required this.subtotal, required this.shippingFee, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.lightContainer,
      appBar: AppBar(title: const Text('Order Review')),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is CheckoutSuccess) {
            context.read<CartCubit>().clearCart();
            THelperFunctions.navigateToScreen(context, const OrderSuccessScreen());
          }
        },
        builder: (context, state) {
          final cubit = context.read<CheckoutCubit>();
          final isLoading = state is CheckoutLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shipping', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: dark ? TColors.darkContainer : TColors.white),
                  child: Row(
                    children: [
                      const Icon(Iconsax.location, color: TColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cubit.selectedAddress['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(cubit.selectedAddress['address_line1'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                CheckoutPaymentSection(cubit: cubit, dark: dark),
                const SizedBox(height: 20),
                const Text('Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: dark ? TColors.darkContainer : TColors.white),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal'), Text('\$${subtotal.toStringAsFixed(2)}')]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Shipping'), Text(shippingFee == 0 ? 'Free' : '\$${shippingFee.toStringAsFixed(2)}')]),
                      const Divider(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)), Text('\$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: TColors.primary))]),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, minimumSize: const Size(double.infinity, 50)),
                  onPressed: isLoading ? null : () {
                    final items = cartItems.map((i) => {'product_id': i.productId, 'quantity': i.quantity, 'price': i.product?.effectivePrice ?? 0.0, 'selected_attributes': i.selectedAttributes}).toList();
                    cubit.placeOrder(subtotal: subtotal, shippingFee: shippingFee, totalAmount: totalAmount, items: items);
                  },
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Place Order'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
