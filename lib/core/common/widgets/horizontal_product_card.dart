import 'package:flutter/material.dart';

class HorizontalProductCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String oldPrice;
  final String discount;
  final String imageUrl;

  const HorizontalProductCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 178, // العرض الثابت للكارت
      decoration: BoxDecoration(
        color: dark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الجزء الخاص بالصورة العلوية
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                // 👈 قراءة الصورة من النت
                SizedBox(
                  height: 130, // ارتفاع الصورة
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    // لو الصورة فيها مشكلة تظهر أيكونة بدل إيرور أحمر
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                // بادج الخصم (بيظهر بس لو في خصم)
                if (discount.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        discount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // 2. الجزء الخاص بالنصوص (استخدمنا Expanded عشان نمنع الـ Overflow)
          Expanded( 
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المنتج
                  Text(
                    title,
                    style: TextStyle(
                      color: dark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1, // سطر واحد كحد أقصى
                    overflow: TextOverflow.ellipsis, // يختم بنقط لو النص طويل
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // وصف المنتج
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                    maxLines: 2, // سطرين للوصف
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(), // بيزق الأسعار لتحت عشان الكارت يبقى متناسق
                  
                  // الأسعار
                  Row(
                    children: [
                      // السعر الحالي
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // السعر القديم (لو موجود)
                      if (oldPrice.isNotEmpty)
                        Text(
                          oldPrice,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough, // خط فوق السعر القديم
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}