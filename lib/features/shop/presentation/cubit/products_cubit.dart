import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_product_by_id_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/search_products_usecase.dart';

import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUsecase getProductsUsecase;
  final GetProductByIdUsecase getProductByIdUsecase;
  final SearchProductsUsecase searchProductsUsecase;

  ProductsCubit({
    required this.getProductsUsecase,
    required this.getProductByIdUsecase,
    required this.searchProductsUsecase,
  }) : super(ProductsInitial());

  // ============================================================
  // VARIABLES
  // ============================================================

  List<ProductEntity> _allProducts = [];

  String? _currentCategoryId;

  int _currentPage = 0;

  bool _isLoading = false;

  static const int _limit = 50;

  // ============================================================
  // CATEGORY NORMALIZATION
  // ============================================================

  String _normalizeCategory(String? category) {
    if (category == null || category.trim().isEmpty) {
      return '';
    }

    final value = category
        .toLowerCase()
        .trim()
        .replaceAll('_', '-')
        .replaceAll(' ', '-');

    switch (value) {
      case 'shirt':
      case 'shirts':
      case 'mens-shirt':
      case 'mens-shirts':
      case "men's-shirt":
      case "men's-shirts":
      case 'men-shirt':
      case 'men-shirts':
        return 'mens-shirts';

      case 'beauty':
      case 'beauty-products':
        return 'beauty';

      case 'laptop':
      case 'laptops':
      case 'computer':
      case 'computers':
        return 'laptops';

      case 'mobile':
      case 'mobiles':
      case 'mobile-phone':
      case 'mobile-phones':
      case 'phone':
      case 'phones':
      case 'smartphone':
      case 'smartphones':
        return 'smartphones';

      case 'furniture':
      case 'home-furniture':
        return 'furniture';

      case 'sport':
      case 'sports':
      case 'sport-accessories':
      case 'sports-accessories':
      case 'sport-accessory':
      case 'sports-accessory':
        return 'sports-accessories';

      default:
        return value;
    }
  }

  // ============================================================
  // GET PRODUCTS
  // ============================================================

  Future<void> getProducts({
    String? categoryId,
    String? brandId,
    bool? isFeatured,
    String? sortBy,
    bool ascending = true,
    bool refresh = false,
  }) async {
    if (_isLoading || isClosed) {
      return;
    }

    final String requestedCategory =
        _normalizeCategory(categoryId);

    final bool isCategoryRequest =
        requestedCategory.isNotEmpty &&
        requestedCategory != 'all';

    // ==========================================================
    // DEBUG
    // ==========================================================

    print('==============================================');
    print('PRODUCTS CUBIT');
    print('Original category: $categoryId');
    print('Normalized category: $requestedCategory');
    print('Is category request: $isCategoryRequest');
    print('Is Featured request: $isFeatured');
    print('==============================================');

    // ==========================================================
    // RESET WHEN CATEGORY CHANGES
    // ==========================================================

    final bool categoryChanged =
        _currentCategoryId != requestedCategory;

    if (refresh || categoryChanged) {
      _currentPage = 0;
      _allProducts = [];

      _currentCategoryId =
          isCategoryRequest
              ? requestedCategory
              : null;
    }

    // ==========================================================
    // LOADING
    // ==========================================================

    _isLoading = true;

    if (_currentPage == 0 && !isClosed) {
      emit(ProductsLoading());
    }

    // ==========================================================
    // API REQUEST
    // ==========================================================

    final result = await getProductsUsecase(
      GetProductsParams(
        page: _currentPage,
        limit: _limit,
        categoryId: isCategoryRequest
            ? requestedCategory
            : null,
        brandId: brandId,
        isFeatured: isFeatured,
        sortBy: sortBy,
        ascending: ascending,
      ),
    );

    _isLoading = false;

    if (isClosed) {
      return;
    }

    // ==========================================================
    // RESULT
    // ==========================================================

    result.fold(
      (error) {
        if (!isClosed) {
          emit(
            ProductsError(error),
          );
        }
      },
      (products) {
        if (isClosed) {
          return;
        }

        // ========================================================
        // COPY API PRODUCTS
        // ========================================================

        List<ProductEntity> filteredProducts =
            List<ProductEntity>.from(products);

        // ========================================================
        // CATEGORY FILTER
        // ========================================================

        if (isCategoryRequest) {
          filteredProducts =
              filteredProducts.where((product) {
            final productCategory =
                _normalizeCategory(
              product.categoryId,
            );

            return productCategory ==
                requestedCategory;
          }).toList();
        }

        // ========================================================
        // FEATURED / DEAL OF THE DAY FILTER
        // ========================================================

        if (isFeatured == true) {
          filteredProducts =
              filteredProducts.where((product) {
            return product.hasDiscount;
          }).toList();
        }

        // ========================================================
        // BRAND FILTER
        // ========================================================

        if (brandId != null &&
            brandId.trim().isNotEmpty) {
          final requestedBrand =
              brandId.toLowerCase().trim();

          filteredProducts =
              filteredProducts.where((product) {
            final productBrand =
                product.brandId
                        ?.toLowerCase()
                        .trim() ??
                    '';

            return productBrand ==
                requestedBrand;
          }).toList();
        }

        // ========================================================
        // DEBUG
        // ========================================================

        print('----------------------------------------------');
        print(
          'API returned: ${products.length}',
        );
        print(
          'After category filter: '
          '${filteredProducts.length}',
        );

        if (isFeatured == true) {
          print(
            '🔥 DEAL OF THE DAY PRODUCTS: '
            '${filteredProducts.length}',
          );
        }

        for (final product in filteredProducts) {
          print(
            'Product: ${product.name} | '
            'Category: ${product.categoryId} | '
            'Price: ${product.price} | '
            'Sale: ${product.salePrice} | '
            'Discount: ${product.hasDiscount}',
          );
        }

        print('----------------------------------------------');

        // ========================================================
        // SAVE PRODUCTS
        // ========================================================

        if (isCategoryRequest || isFeatured == true) {
          _allProducts = [
            ...filteredProducts,
          ];
        } else {
          _allProducts = [
            ..._allProducts,
            ...filteredProducts,
          ];
        }

        // ========================================================
        // REMOVE DUPLICATES
        // ========================================================

        final Map<String, ProductEntity>
            uniqueProducts = {};

        for (final product in _allProducts) {
          uniqueProducts[product.id] = product;
        }

        _allProducts =
            uniqueProducts.values.toList();

        // ========================================================
        // PAGE
        // ========================================================

        _currentPage++;

        // ========================================================
        // EMIT
        // ========================================================

        _emitProducts(
          _allProducts,
          hasReachedMax:
              isCategoryRequest ||
              isFeatured == true ||
              filteredProducts.length < _limit,
        );
      },
    );
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  Future<void> loadMoreProducts({
    String? categoryId,
    String? brandId,
    bool? isFeatured,
    String? sortBy,
    bool ascending = true,
  }) async {
    if (state is! ProductsLoaded) {
      return;
    }

    final currentState =
        state as ProductsLoaded;

    if (currentState.hasReachedMax ||
        _isLoading ||
        isClosed) {
      return;
    }

    final requestedCategory =
        _normalizeCategory(categoryId);

    // Category and Deal of the Day use
    // the full filtered API result.
    if ((requestedCategory.isNotEmpty &&
            requestedCategory != 'all') ||
        isFeatured == true) {
      return;
    }

    await getProducts(
      categoryId: categoryId,
      brandId: brandId,
      isFeatured: isFeatured,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  // ============================================================
  // EMIT PRODUCTS
  // ============================================================

  void _emitProducts(
    List<ProductEntity> products, {
    bool? hasReachedMax,
  }) {
    if (isClosed) {
      return;
    }

    List<ProductEntity> finalProducts =
        List<ProductEntity>.from(products);

    // ==========================================================
    // CATEGORY PROTECTION
    // ==========================================================

    if (_currentCategoryId != null &&
        _currentCategoryId!.isNotEmpty &&
        _currentCategoryId != 'all') {
      final requestedCategory =
          _normalizeCategory(
        _currentCategoryId,
      );

      finalProducts =
          finalProducts.where((product) {
        final productCategory =
            _normalizeCategory(
          product.categoryId,
        );

        return productCategory ==
            requestedCategory;
      }).toList();
    }

    // ==========================================================
    // REMOVE DUPLICATES
    // ==========================================================

    final Map<String, ProductEntity>
        uniqueProducts = {};

    for (final product in finalProducts) {
      uniqueProducts[product.id] = product;
    }

    finalProducts =
        uniqueProducts.values.toList();

    // ==========================================================
    // DEAL OF THE DAY
    // ==========================================================
    //
    // IMPORTANT:
    // ONLY PRODUCTS WITH REAL DISCOUNTS
    //
    // price = 100
    // salePrice = 80
    // hasDiscount = true
    //
    // price = 100
    // salePrice = null
    // hasDiscount = false
    //
    // ==========================================================

    final List<ProductEntity> featured =
        finalProducts
            .where(
              (product) => product.hasDiscount,
            )
            .toList();

    // ==========================================================
    // POPULAR
    // ==========================================================

    final List<ProductEntity> popular =
        finalProducts.where(
      (product) {
        final category =
            _normalizeCategory(
          product.categoryId,
        );

        return category == 'mens-shirts' ||
            category == 'smartphones';
      },
    ).toList();

    // ==========================================================
    // NEW ARRIVALS
    // ==========================================================

    final List<ProductEntity> newItems =
        finalProducts.reversed
            .take(6)
            .toList();

    // ==========================================================
    // DEBUG
    // ==========================================================

    print('==============================================');
    print('EMITTING PRODUCTS');
    print(
      'Current category: $_currentCategoryId',
    );
    print(
      'Final products count: '
      '${finalProducts.length}',
    );
    print(
      '🔥 Deal of the Day count: '
      '${featured.length}',
    );
    print(
      '⭐ Popular count: '
      '${popular.length}',
    );
    print(
      '🆕 New arrivals count: '
      '${newItems.length}',
    );
    print('==============================================');

    // ==========================================================
    // EMIT
    // ==========================================================

    emit(
      ProductsLoaded(
        products: finalProducts,
        featuredProducts: featured,
        popularProducts: popular,
        newArrivals: newItems,
        hasReachedMax:
            hasReachedMax ?? true,
        currentPage: _currentPage,
      ),
    );
  }

  // ============================================================
  // SORT PRODUCTS LOCALLY
  // ============================================================

  void sortProductsLocally(
    String sortType,
  ) {
    if (_allProducts.isEmpty ||
        isClosed) {
      return;
    }

    final products =
        List<ProductEntity>.from(
      _allProducts,
    );

    _sortList(
      products,
      sortType,
    );

    _emitProducts(
      products,
      hasReachedMax: true,
    );
  }

  // ============================================================
  // APPLY FILTERS LOCALLY
  // ============================================================

  void applyFiltersLocally({
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    bool onlyDiscounted = false,
    String sortType = 'none',
  }) {
    if (_allProducts.isEmpty ||
        isClosed) {
      return;
    }

    List<ProductEntity> filtered =
        List<ProductEntity>.from(
      _allProducts,
    );

    // ==========================================================
    // CATEGORY
    // ==========================================================

    if (categoryId != null &&
        categoryId.trim().isNotEmpty) {
      final requestedCategory =
          _normalizeCategory(categoryId);

      filtered =
          filtered.where((product) {
        final productCategory =
            _normalizeCategory(
          product.categoryId,
        );

        return productCategory ==
            requestedCategory;
      }).toList();
    }

    // ==========================================================
    // BRAND
    // ==========================================================

    if (brandId != null &&
        brandId.trim().isNotEmpty) {
      filtered =
          filtered.where((product) {
        return product.brandId ==
            brandId;
      }).toList();
    }

    // ==========================================================
    // MIN PRICE
    // ==========================================================

    if (minPrice != null) {
      filtered =
          filtered.where((product) {
        return product.effectivePrice >=
            minPrice;
      }).toList();
    }

    // ==========================================================
    // MAX PRICE
    // ==========================================================

    if (maxPrice != null) {
      filtered =
          filtered.where((product) {
        return product.effectivePrice <=
            maxPrice;
      }).toList();
    }

    // ==========================================================
    // DISCOUNT
    // ==========================================================

    if (onlyDiscounted) {
      filtered =
          filtered.where((product) {
        return product.hasDiscount;
      }).toList();
    }

    // ==========================================================
    // SORT
    // ==========================================================

    _sortList(
      filtered,
      sortType,
    );

    // ==========================================================
    // EMIT
    // ==========================================================

    _emitProducts(
      filtered,
      hasReachedMax: true,
    );
  }

  // ============================================================
  // RESET FILTERS
  // ============================================================

  void resetFilters() {
    if (_allProducts.isEmpty ||
        isClosed) {
      return;
    }

    _emitProducts(
      _allProducts,
      hasReachedMax: true,
    );
  }

  // ============================================================
  // DISCOUNT FILTER
  // ============================================================

  void toggleDiscountFilterLocally(
    bool showOnlyDiscounted,
  ) {
    if (_allProducts.isEmpty ||
        isClosed) {
      return;
    }

    if (showOnlyDiscounted) {
      final discounted =
          _allProducts
              .where(
                (product) =>
                    product.hasDiscount,
              )
              .toList();

      _emitProducts(
        discounted,
        hasReachedMax: true,
      );
    } else {
      _emitProducts(
        _allProducts,
        hasReachedMax: true,
      );
    }
  }

  // ============================================================
  // SORT LIST
  // ============================================================

  void _sortList(
    List<ProductEntity> products,
    String sortType,
  ) {
    switch (sortType) {
      case 'low_to_high':
        products.sort(
          (a, b) =>
              a.effectivePrice.compareTo(
            b.effectivePrice,
          ),
        );
        break;

      case 'high_to_low':
        products.sort(
          (a, b) =>
              b.effectivePrice.compareTo(
            a.effectivePrice,
          ),
        );
        break;

      case 'name_a_z':
        products.sort(
          (a, b) =>
              a.name
                  .toLowerCase()
                  .compareTo(
                    b.name.toLowerCase(),
                  ),
        );
        break;

      case 'rating':
        products.sort(
          (a, b) =>
              b.rating.compareTo(
            a.rating,
          ),
        );
        break;

      case 'newest':
        products.sort(
          (a, b) {
            final aDate =
                a.createdAt ??
                    DateTime(2000);

            final bDate =
                b.createdAt ??
                    DateTime(2000);

            return bDate.compareTo(
              aDate,
            );
          },
        );
        break;
    }
  }

  // ============================================================
  // GET PRODUCT BY ID
  // ============================================================

  Future<void> getProductById(
    String id,
  ) async {
    if (isClosed) {
      return;
    }

    emit(ProductDetailLoading());

    final result =
        await getProductByIdUsecase(id);

    if (isClosed) {
      return;
    }

    result.fold(
      (error) {
        if (!isClosed) {
          emit(
            ProductDetailError(error),
          );
        }
      },
      (product) {
        if (!isClosed) {
          emit(
            ProductDetailLoaded(product),
          );
        }
      },
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> searchProducts(
    String query,
  ) async {
    if (isClosed) {
      return;
    }

    if (query.trim().isEmpty) {
      _emitProducts(
        _allProducts,
        hasReachedMax: true,
      );
      return;
    }

    emit(ProductsSearching());

    final result =
        await searchProductsUsecase(query);

    if (isClosed) {
      return;
    }

    result.fold(
      (error) {
        if (!isClosed) {
          emit(
            ProductsError(error),
          );
        }
      },
      (products) {
        if (!isClosed) {
          emit(
            ProductsSearchResult(
              products: products,
              query: query,
            ),
          );
        }
      },
    );
  }

  // ============================================================
  // RESET PRODUCTS
  // ============================================================

  void resetProducts() {
    _currentPage = 0;

    _allProducts = [];

    _currentCategoryId = null;

    _isLoading = false;

    if (!isClosed) {
      emit(ProductsInitial());
    }
  }
}