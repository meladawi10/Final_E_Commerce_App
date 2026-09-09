import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/presentation/cubit/cart_cubit.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  int selectedPaymentIndex = 0;

  final List<Map<String, String>> paymentMethods = [
    {
      'name': 'Visa',
      'icon': 'assets/icons/payment_methods/visa.png',
      'number': '********2109'
    },
    {
      'name': 'PayPal',
      'icon': 'assets/icons/payment_methods/paypal.png',
      'number': '********2109'
    },
    {
      'name': 'MasterCard',
      'icon': 'assets/icons/payment_methods/master-card.png',
      'number': '********2109'
    },
    {
      'name': 'Apple Pay',
      'icon': 'assets/icons/payment_methods/apple-pay.png',
      'number': '********2109'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final cubit = CartCubit();
    final subtotal = cubit.calculateSubtotal();
    final shipping = subtotal > 0 ? 30.0 : 0.0;
    final total = subtotal + shipping;

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.lightContainer,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Checkout',
          style: TextStyle(
            color: dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              decoration: BoxDecoration(
                color: dark ? TColors.darkContainer : TColors.white,
                borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                border: Border.all(
                  color: dark ? TColors.darkerGrey : TColors.borderPrimary,
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                      'Order', '₹${subtotal.toStringAsFixed(0)}', dark),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                      'Shipping', '₹${shipping.toStringAsFixed(0)}', dark),
                  Divider(
                    height: 24,
                    color: dark ? TColors.darkerGrey : Colors.grey[300],
                  ),
                  _buildSummaryRow(
                      'Total', '₹${total.toStringAsFixed(0)}', dark,
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Text(
              'Payment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: dark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paymentMethods.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: TSizes.spaceBtwItems),
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                final isSelected = selectedPaymentIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPaymentIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: dark ? TColors.darkContainer : TColors.white,
                      borderRadius:
                          BorderRadius.circular(TSizes.borderRadiusLg),
                      border: Border.all(
                        color: isSelected
                            ? TColors.primary
                            : (dark
                                ? TColors.darkerGrey
                                : TColors.borderPrimary),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              method['icon']!,
                              width: 36,
                              height: 24,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.payment, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              method['name']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: dark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          method['number']!,
                          style: TextStyle(
                            color: dark ? TColors.darkGrey : Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              padding: const EdgeInsets.symmetric(vertical: TSizes.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(TSizes.borderRadiusLg),
                  ),
                  backgroundColor:
                      dark ? TColors.darkContainer : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/payment_methods/successful_payment_icon.png',
                          width: 90,
                          height: 90,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.check_circle,
                            color: Colors.redAccent,
                            size: 80,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Payment done successfully.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    TSizes.cardRadiusMd),
                              ),
                            ),
                            onPressed: () {
                              cubit.cartItems.clear();
                              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                              cubit.emit(CartUpdated([]));
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('OK',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? TColors.primary
                : (dark ? Colors.white : Colors.black),
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }
}