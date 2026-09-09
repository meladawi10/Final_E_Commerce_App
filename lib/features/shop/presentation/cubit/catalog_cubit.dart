import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/shop/data/data_sources/shop_remote_data_source.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final ShopRemoteDataSource remoteDataSource;

  CatalogCubit({required this.remoteDataSource}) : super(CatalogInitial());

  List<ProductEntity> _allProducts = [];
  List<CategoryEntity> _allCategories = [];
  String? _selectedCategoryId;

  Future<void> loadCatalog() async {
    emit(CatalogLoading());

    final categoriesResult = await remoteDataSource.getCategories();
    final productsResult = await remoteDataSource.getProductsList();

    categoriesResult.fold(
      (error) => emit(CatalogError(error.message)),
      (categories) {
        _allCategories = categories;
        productsResult.fold(
          (error) => emit(CatalogError(error.message)),
          (products) {
            _allProducts = products;
            emit(CatalogLoaded(
              products: _allProducts,
              categories: _allCategories,
              selectedCategoryId: _selectedCategoryId,
            ));
          },
        );
      },
    );
  }

  Future<void> selectCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;
    if (state is CatalogLoaded) {
      if (categoryId == null || categoryId.isEmpty) {
        emit(CatalogLoaded(
          products: _allProducts,
          categories: _allCategories,
          selectedCategoryId: null,
        ));
      } else {
        emit(CatalogActionInProgress());
        final filteredResult = await remoteDataSource.getProductsByCategory(categoryId: categoryId);
        filteredResult.fold(
          (error) => emit(CatalogError(error.message)),
          (filteredProducts) {
            emit(CatalogLoaded(
              products: filteredProducts,
              categories: _allCategories,
              selectedCategoryId: categoryId,
            ));
          },
        );
      }
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    emit(CatalogActionInProgress());
    try {
      final shopDataSource = remoteDataSource as ShopRemoteDataSourceImpl;
      final response = await shopDataSource.apiClient.dio.post('api/products', data: productData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(const CatalogActionSuccess('Product added successfully'));
        await loadCatalog();
      } else {
        emit(const CatalogError('Failed to add product'));
      }
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }

  Future<void> deleteProduct(String productId) async {
    emit(CatalogActionInProgress());
    try {
      final shopDataSource = remoteDataSource as ShopRemoteDataSourceImpl;
      final response = await shopDataSource.apiClient.dio.delete('api/products/$productId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(const CatalogActionSuccess('Product deleted successfully'));
        await loadCatalog();
      } else {
        emit(const CatalogError('Failed to delete product'));
      }
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
}