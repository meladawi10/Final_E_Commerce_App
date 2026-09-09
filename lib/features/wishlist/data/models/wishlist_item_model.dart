import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class WishlistItemModel extends WishlistItemEntity {
  const WishlistItemModel({
    required super.id,
    required super.userId,
    required super.productId,
    super.createdAt,
    super.product,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    // فيكس: نبني الـ ProductEntity من الأعمدة المخزّنة في wishlist نفسها
    // (product_name, product_thumbnail, product_price, product_brand)
    // بدل ما نعتمد على join مع جدول products
    final productId = json['product_id'] as String;

    final product = ProductEntity(
      id: productId,
      name: json['product_name'] as String? ?? 'منتج',
      price: (json['product_price'] as num?)?.toDouble() ?? 0.0,
      categoryId: '',
      stock: 0,
      images: json['product_thumbnail'] != null
          ? [json['product_thumbnail'] as String]
          : const [],
      thumbnail: json['product_thumbnail'] as String?,
      brandName: json['product_brand'] as String?,
    );

    return WishlistItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: productId,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      product: product,
    );
  }
}