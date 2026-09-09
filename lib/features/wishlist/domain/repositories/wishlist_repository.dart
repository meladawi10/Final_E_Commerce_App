import 'package:dartz/dartz.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';

abstract class WishlistRepository {
  Future<Either<String, List<WishlistItemEntity>>> getWishlist();

  // فيكس: دلوقتي بناخد المنتج كامل مش بس الـ id،
  // عشان نحفظ نسخة (snapshot) من بياناته جوه wishlist
  Future<Either<String, WishlistItemEntity>> addToWishlist(ProductEntity product);

  Future<Either<String, void>> removeFromWishlist(String productId);

  Future<Either<String, bool>> isInWishlist(String productId);

  Future<Either<String, void>> toggleWishlist(ProductEntity product);
}