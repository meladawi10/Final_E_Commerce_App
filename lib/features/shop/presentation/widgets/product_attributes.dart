import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';

class ProductAttributes extends StatelessWidget {
  const ProductAttributes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: TSizes.spaceBtwItems),
        const Text('Colors:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildColorChoice('Red', Colors.red, true),
            const SizedBox(width: 8),
            _buildColorChoice('Blue', Colors.blue, false),
            const SizedBox(width: 8),
            _buildColorChoice('Black', Colors.black, false),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        const Text('Sizes:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildSizeChoice('EU 34', true),
            _buildSizeChoice('EU 36', false),
            _buildSizeChoice('EU 38', false),
          ],
        ),
      ],
    );
  }

  Widget _buildColorChoice(String name, Color color, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? TColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        border: Border.all(color: selected ? TColors.primary : TColors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color, radius: 8),
          const SizedBox(width: 6),
          Text(name, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildSizeChoice(String size, bool selected) {
    return ChoiceChip(
      label: Text(size),
      selected: selected,
      selectedColor: TColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
      onSelected: (value) {},
    );
  }
}