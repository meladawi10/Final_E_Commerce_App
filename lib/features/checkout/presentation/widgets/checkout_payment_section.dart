import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/features/checkout/presentation/cubit/checkout_cubit.dart';

class CheckoutPaymentSection extends StatelessWidget {
  final CheckoutCubit cubit;
  final bool dark;

  const CheckoutPaymentSection({super.key, required this.cubit, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _btn(cubit, 'COD', dark)),
        const SizedBox(width: 12),
        Expanded(child: _btn(cubit, 'Card', dark)),
      ],
    );
  }

  Widget _btn(CheckoutCubit c, String m, bool d) {
    final sel = c.selectedPaymentMethod == m;
    return GestureDetector(
      onTap: () => c.selectPaymentMethod(m),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? TColors.primary : Colors.grey),
          color: d ? TColors.darkContainer : TColors.white,
        ),
        child: Center(child: Text(m, style: const TextStyle(fontWeight: FontWeight.bold))),
      ),
    );
  }
}
