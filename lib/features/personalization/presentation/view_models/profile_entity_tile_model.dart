import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileEntityTileModel {
  final String title;
  final String value;
  final IconData? trailing; // السطر ده مهم، ضفنا علامة الاستفهام
  final VoidCallback onTap;

  ProfileEntityTileModel({
    required this.title,
    required this.value,
    required this.onTap,
    this.trailing = Iconsax.arrow_right_3, // القيمة الافتراضية سهم
  });
}