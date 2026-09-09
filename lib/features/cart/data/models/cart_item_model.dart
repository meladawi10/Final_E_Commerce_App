import 'package:t_store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:t_store/features/shop/data/models/product_model.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.userId,
    required super.productId,
    required super.quantity,
    super.selectedAttributes,
    super.createdAt,
    super.updatedAt,
    super.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final dynamic productJson = json['products'] ?? json['product'];

    return CartItemModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      selectedAttributes: json['selected_attributes'] is Map
          ? Map<String, dynamic>.from(json['selected_attributes'] as Map)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      product: productJson is Map<String, dynamic>
          ? ProductModel.fromJson(productJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'selected_attributes': selectedAttributes,
    };
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      userId: entity.userId,
      productId: entity.productId,
      quantity: entity.quantity,
      selectedAttributes: entity.selectedAttributes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      product: entity.product,
    );
  }
}