import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/domain/usecases/get_wishlist_usecase.dart';
import 'package:t_store/features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';
import 'package:t_store/features/wishlist/domain/usecases/remove_from_wishlist_usecase.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final GetWishlistUsecase getWishlistUsecase;
  final AddToWishlistUsecase addToWishlistUsecase;
  final RemoveFromWishlistUsecase removeFromWishlistUsecase;

  WishlistCubit({
    required this.getWishlistUsecase,
    required this.addToWishlistUsecase,
    required this.removeFromWishlistUsecase,
  }) : super(WishlistInitial());

  List<WishlistItemEntity> _items = [];
  Set<String> _productIds = {};

  List<WishlistItemEntity> get items => List.unmodifiable(_items);

  Future<void> getWishlist() async {
    if (isClosed) return;
    emit(WishlistLoading());

    final result = await getWishlistUsecase(const NoParams());
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(WishlistError(error));
      },
      (items) {
        _items = items;
        _productIds = items.map((e) => e.productId).toSet();
        if (!isClosed) emit(WishlistLoaded(List.from(_items)));
      },
    );
  }

  // فيكس: بناخد المنتج كامل مش الـ id بس
  Future<void> addToWishlist(ProductEntity product) async {
    if (isClosed) return;

    final result = await addToWishlistUsecase(product);
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(WishlistError(error));
      },
      (item) async {
        if (isClosed) return;
        _productIds.add(product.id);
        emit(WishlistItemAdded(item));
        await getWishlist();
      },
    );
  }

  Future<void> removeFromWishlist(String productId) async {
    if (isClosed) return;

    final result = await removeFromWishlistUsecase(productId);
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(WishlistError(error));
      },
      (_) async {
        if (isClosed) return;
        _productIds.remove(productId);
        emit(WishlistItemRemoved(productId));
        await getWishlist();
      },
    );
  }

  Future<void> toggleWishlist(ProductEntity product) async {
    if (isClosed) return;

    if (isInWishlist(product.id)) {
      await removeFromWishlist(product.id);
    } else {
      await addToWishlist(product);
    }
  }

  bool isInWishlist(String productId) => _productIds.contains(productId);

  int get itemCount => _items.length;
}