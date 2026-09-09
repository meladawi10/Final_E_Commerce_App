import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';

import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final SupabaseService supabaseService;

  WishlistRepositoryImpl({required this.supabaseService});

  String get _userId => supabaseService.currentUser?.id ?? '';

  // ============================================================
  // GET WISHLIST
  // ============================================================
  @override
  Future<Either<String, List<WishlistItemEntity>>> getWishlist() async {
    try {
      if (_userId.isEmpty) {
        return const Left('يرجى تسجيل الدخول أولاً');
      }

      // فيكس: مفيش join تاني، البيانات كلها متخزنة جوه الصف نفسه
      final response = await supabaseService.client
          .from(SupabaseTables.wishlist)
          .select('*')
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((json) => WishlistItemModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('❤️ [Wishlist] Total Items: ${items.length}');

      return Right(items);
    } catch (e, stackTrace) {
      debugPrint('❌ [Wishlist] Get Wishlist Error: $e');
      debugPrint(stackTrace.toString());
      return Left(e.toString());
    }
  }

  // ============================================================
  // ADD TO WISHLIST
  // ============================================================
  @override
  Future<Either<String, WishlistItemEntity>> addToWishlist(
    ProductEntity product,
  ) async {
    try {
      if (_userId.isEmpty) {
        return const Left('يرجى تسجيل الدخول أولاً');
      }

      final existing = await supabaseService.client
          .from(SupabaseTables.wishlist)
          .select()
          .eq('user_id', _userId)
          .eq('product_id', product.id)
          .maybeSingle();

      if (existing != null) {
        return const Left('المنتج موجود بالفعل في المفضلة');
      }

      // فيكس: بنحفظ snapshot من بيانات المنتج مع الـ id
      final response = await supabaseService.client
          .from(SupabaseTables.wishlist)
          .insert({
            'user_id': _userId,
            'product_id': product.id,
            'product_name': product.name,
            'product_thumbnail':
                product.thumbnail ?? (product.images.isNotEmpty ? product.images.first : null),
            'product_price': product.price,
            'product_brand': product.brandName,
          })
          .select()
          .single();

      final item = WishlistItemModel.fromJson(response);

      debugPrint('✅ [Wishlist] Added Successfully: ${item.product?.name}');

      return Right(item);
    } catch (e, stackTrace) {
      debugPrint('❌ [Wishlist] Add Error: $e');
      debugPrint(stackTrace.toString());
      return Left(e.toString());
    }
  }

  // ============================================================
  // REMOVE FROM WISHLIST
  // ============================================================
  @override
  Future<Either<String, void>> removeFromWishlist(String productId) async {
    try {
      if (_userId.isEmpty) {
        return const Left('يرجى تسجيل الدخول أولاً');
      }

      await supabaseService.client
          .from(SupabaseTables.wishlist)
          .delete()
          .eq('user_id', _userId)
          .eq('product_id', productId);

      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('❌ [Wishlist] Remove Error: $e');
      debugPrint(stackTrace.toString());
      return Left(e.toString());
    }
  }

  // ============================================================
  // CHECK IF PRODUCT IS IN WISHLIST
  // ============================================================
  @override
  Future<Either<String, bool>> isInWishlist(String productId) async {
    try {
      if (_userId.isEmpty) return const Right(false);

      final response = await supabaseService.client
          .from(SupabaseTables.wishlist)
          .select('id')
          .eq('user_id', _userId)
          .eq('product_id', productId)
          .maybeSingle();

      return Right(response != null);
    } catch (e, stackTrace) {
      debugPrint('❌ [Wishlist] Check Error: $e');
      debugPrint(stackTrace.toString());
      return Left(e.toString());
    }
  }

  // ============================================================
  // TOGGLE WISHLIST
  // ============================================================
  @override
  Future<Either<String, void>> toggleWishlist(ProductEntity product) async {
    try {
      final isInResult = await isInWishlist(product.id);

      return isInResult.fold(
        (error) => Left(error),
        (isIn) async {
          if (isIn) {
            return await removeFromWishlist(product.id);
          } else {
            final result = await addToWishlist(product);
            return result.fold(
              (error) => Left(error),
              (_) => const Right(null),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [Wishlist] Toggle Error: $e');
      debugPrint(stackTrace.toString());
      return Left(e.toString());
    }
  }
}