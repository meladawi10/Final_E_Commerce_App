import 'package:dartz/dartz.dart';

import 'package:t_store/features/cart/data/data_sources/cart_remote_data_source.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:t_store/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<String, List<CartItemEntity>>> getCartItems() async {
    final result = await remoteDataSource.getCartItems();

    return result.fold(
      (error) => Left(error.message),
      (models) => Right(models),
    );
  }

  @override
  Future<Either<String, CartItemEntity>> addToCart({
    required String productId,
    required int quantity,
    Map<String, dynamic>? selectedAttributes,
  }) async {
    final result = await remoteDataSource.addToCart(
      productId: productId,
      quantity: quantity,
      selectedAttributes: selectedAttributes,
    );

    return result.fold(
      (error) => Left(error.message),
      (model) => Right(model),
    );
  }

  @override
  Future<Either<String, CartItemEntity>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      final removeResult = await removeFromCart(
        cartItemId,
      );

      return removeResult.fold(
        (error) => Left(error),
        (_) => const Left('تم إزالة المنتج من السلة'),
      );
    }

    final result = await remoteDataSource.updateCartItem(
      cartItemId: cartItemId,
      quantity: quantity,
    );

    return result.fold(
      (error) => Left(error.message),
      (model) => Right(model),
    );
  }

  @override
  Future<Either<String, void>> removeFromCart(
    String cartItemId,
  ) async {
    final result = await remoteDataSource.removeFromCart(
      cartItemId,
    );

    return result.fold(
      (error) => Left(error.message),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<String, void>> clearCart() async {
    final result = await remoteDataSource.clearCart();

    return result.fold(
      (error) => Left(error.message),
      (_) => const Right(null),
    );
  }

  @override
  Stream<List<CartItemEntity>> get cartStream {
    return Stream.value([]);
  }
}