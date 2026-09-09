import 'package:t_store/features/shop/domain/entities/product_entity.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<ProductEntity> products;
  final List<ProductEntity> featuredProducts;
  final List<ProductEntity> popularProducts;
  final List<ProductEntity> newArrivals;
  final bool hasReachedMax;
  final int currentPage;

  ProductsLoaded({
    required this.products,
    required this.featuredProducts,
    required this.popularProducts,
    required this.newArrivals,
    required this.hasReachedMax,
    required this.currentPage,
  });

  ProductsLoaded copyWith({
    List<ProductEntity>? products,
    List<ProductEntity>? featuredProducts,
    List<ProductEntity>? popularProducts,
    List<ProductEntity>? newArrivals,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      popularProducts: popularProducts ?? this.popularProducts,
      newArrivals: newArrivals ?? this.newArrivals,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}

class ProductDetailLoading extends ProductsState {}

class ProductDetailLoaded extends ProductsState {
  final ProductEntity product;
  ProductDetailLoaded(this.product);
}

class ProductDetailError extends ProductsState {
  final String message;
  ProductDetailError(this.message);
}

class ProductsSearching extends ProductsState {}

class ProductsSearchResult extends ProductsState {
  final List<ProductEntity> products;
  final String query;
  ProductsSearchResult({required this.products, required this.query});
}