import 'package:equatable/equatable.dart';

import 'package:t_store/features/cart/domain/entities/cart_item_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;

  const CartLoaded(
    this.items,
  );

  int get itemCount {
    return items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  double get subtotal {
    return items.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  double get shippingFee {
    if (items.isEmpty) {
      return 0.0;
    }

    return subtotal > 50.0 ? 0.0 : 5.0;
  }

  double get taxFee {
    return 0.0;
  }

  double get totalPrice {
    return subtotal + shippingFee + taxFee;
  }

  bool get isEmpty {
    return items.isEmpty;
  }

  @override
  List<Object?> get props => [
        items,
      ];
}

class CartError extends CartState {
  final String message;

  const CartError(
    this.message,
  );

  @override
  List<Object?> get props => [
        message,
      ];
}

class CartItemAdded extends CartState {
  final CartItemEntity item;

  const CartItemAdded(
    this.item,
  );

  @override
  List<Object?> get props => [
        item,
      ];
}

class CartItemUpdated extends CartState {
  final CartItemEntity item;

  const CartItemUpdated(
    this.item,
  );

  @override
  List<Object?> get props => [
        item,
      ];
}

class CartItemRemoved extends CartState {
  final String itemId;

  const CartItemRemoved(
    this.itemId,
  );

  @override
  List<Object?> get props => [
        itemId,
      ];
}

class CartCleared extends CartState {
  const CartCleared();
}