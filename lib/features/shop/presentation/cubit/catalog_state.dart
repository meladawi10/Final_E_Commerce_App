import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;

  const CatalogLoaded({
    required this.products,
    required this.categories,
    this.selectedCategoryId,
  });

  @override
  List<Object?> get props => [products, categories, selectedCategoryId];

  CatalogLoaded copyWith({
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
  }) {
    return CatalogLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}

class CatalogActionInProgress extends CatalogState {}

class CatalogActionSuccess extends CatalogState {
  final String message;

  const CatalogActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}