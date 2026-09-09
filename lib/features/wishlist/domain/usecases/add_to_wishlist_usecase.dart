import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/domain/repositories/wishlist_repository.dart';

class AddToWishlistUsecase implements UseCase<WishlistItemEntity, ProductEntity> {
  final WishlistRepository repository;

  AddToWishlistUsecase(this.repository);

  @override
  Future<Either<String, WishlistItemEntity>> call(ProductEntity product) async {
    return await repository.addToWishlist(product);
  }
}