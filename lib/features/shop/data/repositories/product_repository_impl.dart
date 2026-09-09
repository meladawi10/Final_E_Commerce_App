import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:t_store/core/api/ecommerce_api_client.dart';

import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final EcommerceApiClient apiClient;

  ProductRepositoryImpl(this.apiClient);

  // ============================================================
  // CATEGORY MAPPING
  // ============================================================

  String? _mapCategoryToDummyJson(String category) {
    final value = category
        .toLowerCase()
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    switch (value) {
      // ----------------------------------------------------------
      // SHIRTS
      // ----------------------------------------------------------

      case 'shirts':
      case 'shirt':
      case 'mens shirts':
      case 'men shirts':
      case "men's shirts":
        return 'mens-shirts';

      // ----------------------------------------------------------
      // BEAUTY
      // ----------------------------------------------------------

      case 'beauty':
      case 'beauty products':
        return 'beauty';

      // ----------------------------------------------------------
      // LAPTOP
      // ----------------------------------------------------------

      case 'laptop':
      case 'laptops':
      case 'computer':
      case 'computers':
        return 'laptops';

      // ----------------------------------------------------------
      // MOBILE
      // ----------------------------------------------------------

      case 'mobile':
      case 'mobiles':
      case 'mobile phones':
      case 'phone':
      case 'phones':
      case 'smartphone':
      case 'smartphones':
        return 'smartphones';

      // ----------------------------------------------------------
      // FURNITURE
      // ----------------------------------------------------------

      case 'furniture':
      case 'home furniture':
        return 'furniture';

      // ----------------------------------------------------------
      // SPORTS
      // ----------------------------------------------------------

      case 'sports':
      case 'sport':
      case 'sports accessories':
      case 'sport accessories':
        return 'sports-accessories';

      // ----------------------------------------------------------
      // ALREADY DUMMYJSON SLUGS
      // ----------------------------------------------------------

      case 'mens-shirts':
        return 'mens-shirts';

      case 'sports-accessories':
        return 'sports-accessories';

      default:
        return null;
    }
  }

  // ============================================================
  // CREATE PRODUCT ENTITY
  // ============================================================

  ProductEntity _mapProduct(
    Map<String, dynamic> json,
  ) {
    final double price =
        (json['price'] as num?)?.toDouble() ?? 0.0;

    final double discount =
        (json['discountPercentage'] as num?)?.toDouble() ?? 0.0;

    final double? salePrice = discount > 0
        ? price - (price * (discount / 100))
        : null;

    return ProductEntity(
      id: json['id']?.toString() ?? '',

      name: json['title']?.toString() ?? 'بدون اسم',

      description: json['description']?.toString(),

      price: price,

      salePrice: salePrice,

      // DummyJSON category
      categoryId:
          json['category']?.toString() ?? 'general',

      stock:
          (json['stock'] as num?)?.toInt() ?? 0,

      images: (json['images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      thumbnail:
          json['thumbnail']?.toString(),

      brandId:
          json['brand']?.toString(),

      rating:
          (json['rating'] as num?)?.toDouble() ?? 0.0,

      reviewsCount:
          json['reviews'] is List
              ? (json['reviews'] as List).length
              : 0,

      // Any product with a discount is considered featured
      isFeatured: discount > 0,

      isActive: true,
    );
  }

  // ============================================================
  // GET PRODUCTS
  // ============================================================

  @override
  Future<Either<String, List<ProductEntity>>> getProducts({
    required int page,
    required int limit,
    String? categoryId,
    String? brandId,
    bool? isFeatured,
    String? sortBy,
    required bool ascending,
  }) async {
    try {
      // ==========================================================
      // CHECK ALL PRODUCTS
      // ==========================================================

      final bool isAll =
          categoryId == null ||
          categoryId.trim().isEmpty ||
          categoryId.toLowerCase().trim() == 'all';

      String url;

      String? dummyCategory;

      // ==========================================================
      // ALL PRODUCTS
      // ==========================================================

      if (isAll) {
        url =
            'https://dummyjson.com/products?limit=150';

        print('==========================================');
        print('PRODUCT API REQUEST');
        print('TYPE: ALL PRODUCTS');
        print('URL: $url');
        print('==========================================');
      }

      // ==========================================================
      // CATEGORY PRODUCTS
      // ==========================================================

      else {
        dummyCategory =
            _mapCategoryToDummyJson(categoryId);

        // --------------------------------------------------------
        // UNKNOWN CATEGORY
        // --------------------------------------------------------

        if (dummyCategory == null) {
          print('==========================================');
          print('⚠️ UNKNOWN CATEGORY');
          print('Received: $categoryId');
          print('==========================================');

          return const Right([]);
        }

        // --------------------------------------------------------
        // CATEGORY ENDPOINT
        // --------------------------------------------------------

        url =
            'https://dummyjson.com/products/category/$dummyCategory?limit=150';

        print('==========================================');
        print('PRODUCT API REQUEST');
        print('TYPE: CATEGORY');
        print('ORIGINAL CATEGORY: $categoryId');
        print(
          'DUMMYJSON CATEGORY: $dummyCategory',
        );
        print('URL: $url');
        print('==========================================');
      }

      // ==========================================================
      // API REQUEST
      // ==========================================================

      final response =
          await Dio().get(url);

      if (response.statusCode != 200) {
        return const Left(
          'فشل في جلب المنتجات من السيرفر',
        );
      }

      // ==========================================================
      // RESPONSE
      // ==========================================================

      final dynamic responseData =
          response.data;

      final List data =
          responseData['products'] as List? ?? [];

      // ==========================================================
      // CONVERT TO PRODUCT ENTITY
      // ==========================================================

      List<ProductEntity> products =
          data
              .map<ProductEntity>(
                (json) => _mapProduct(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList();

      // ==========================================================
      // STRICT CATEGORY FILTER
      // ==========================================================

      if (!isAll &&
          dummyCategory != null) {
        products =
            products.where((product) {
          final String productCategory =
              product.categoryId
                  .toLowerCase()
                  .trim();

          final String requestedCategory =
              dummyCategory!
                  .toLowerCase()
                  .trim();

          final bool matches =
              productCategory ==
                  requestedCategory;

          if (!matches) {
            print(
              '❌ FILTERED OUT: '
              '${product.name} '
              '(${product.categoryId})',
            );
          }

          return matches;
        }).toList();
      }

      // ==========================================================
      // BRAND FILTER
      // ==========================================================

      if (brandId != null &&
          brandId.trim().isNotEmpty) {
        final String requestedBrand =
            brandId.toLowerCase().trim();

        products =
            products.where((product) {
          final String productBrand =
              product.brandId
                      ?.toLowerCase()
                      .trim() ??
                  '';

          return productBrand ==
              requestedBrand;
        }).toList();
      }

      // ==========================================================
      // DEAL OF THE DAY / FEATURED FILTER
      // ==========================================================
      //
      // Deal of the Day:
      //
      // 1. Only products with a real discount
      // 2. Sort by highest discount
      // 3. Keep the best 6 products
      //
      // ==========================================================

      if (isFeatured == true) {
        // --------------------------------------------------------
        // ONLY DISCOUNTED PRODUCTS
        // --------------------------------------------------------

        products =
            products.where((product) {
          return product.hasDiscount;
        }).toList();

        // --------------------------------------------------------
        // SORT BY DISCOUNT
        // Highest discount first
        // --------------------------------------------------------

        products.sort(
          (a, b) =>
              b.discountPercentage.compareTo(
            a.discountPercentage,
          ),
        );

        // --------------------------------------------------------
        // KEEP TOP 6
        // --------------------------------------------------------

        if (products.length > 6) {
          products =
              products.take(6).toList();
        }

        // --------------------------------------------------------
        // DEBUG
        // --------------------------------------------------------

        print('==========================================');
        print(
          '🔥 DEAL OF THE DAY: '
          '${products.length}',
        );

        for (final product in products) {
          print(
            '🔥 DEAL: ${product.name} '
            '| DISCOUNT: '
            '${product.discountPercentage.toStringAsFixed(1)}% '
            '| PRICE: ${product.price} '
            '| SALE PRICE: ${product.salePrice}',
          );
        }

        print('==========================================');
      }

      // ==========================================================
      // SORT
      // ==========================================================

      if (sortBy != null &&
          sortBy.trim().isNotEmpty) {
        switch (sortBy) {
          // ------------------------------------------------------
          // PRICE
          // ------------------------------------------------------

          case 'price':
            products.sort((a, b) {
              final result =
                  a.effectivePrice.compareTo(
                b.effectivePrice,
              );

              return ascending
                  ? result
                  : -result;
            });

            break;

          // ------------------------------------------------------
          // NAME
          // ------------------------------------------------------

          case 'name':
            products.sort((a, b) {
              final result =
                  a.name
                      .toLowerCase()
                      .compareTo(
                        b.name.toLowerCase(),
                      );

              return ascending
                  ? result
                  : -result;
            });

            break;

          // ------------------------------------------------------
          // RATING
          // ------------------------------------------------------

          case 'rating':
            products.sort((a, b) {
              final result =
                  a.rating.compareTo(
                b.rating,
              );

              return ascending
                  ? result
                  : -result;
            });

            break;
        }
      }

      // ==========================================================
      // DEBUG
      // ==========================================================

      print('==========================================');
      print(
        '✅ PRODUCTS FOUND: ${products.length}',
      );

      if (!isAll) {
        print(
          'CATEGORY: $categoryId → $dummyCategory',
        );
      }

      if (isFeatured == true) {
        print(
          '🔥 DEAL OF THE DAY: TOP 6 DISCOUNTS',
        );
      }

      print('==========================================');

      for (final product in products) {
        print(
          'PRODUCT: ${product.name} '
          '| CATEGORY: ${product.categoryId} '
          '| PRICE: ${product.price} '
          '| SALE PRICE: ${product.salePrice} '
          '| DISCOUNT: '
          '${product.discountPercentage.toStringAsFixed(1)}%',
        );
      }

      print('==========================================');

      // ==========================================================
      // RETURN
      // ==========================================================

      return Right(products);
    }

    // ============================================================
    // DIO ERROR
    // ============================================================

    on DioException catch (e) {
      print('==========================================');
      print('❌ DIO ERROR');
      print('MESSAGE: ${e.message}');
      print('TYPE: ${e.type}');
      print(
        'STATUS: ${e.response?.statusCode}',
      );
      print(
        'DATA: ${e.response?.data}',
      );
      print('==========================================');

      return Left(
        'API Error: ${e.message}',
      );
    }

    // ============================================================
    // GENERAL ERROR
    // ============================================================

    catch (e) {
      print('==========================================');
      print('❌ PRODUCT ERROR');
      print('$e');
      print('==========================================');

      return Left(
        'Unexpected Error: $e',
      );
    }
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  @override
  Future<bool> addProduct({
    required String name,
    required double price,
    required String description,
  }) async {
    return false;
  }

  // ============================================================
  // GET PRODUCT BY ID
  // ============================================================

  @override
  Future<Either<String, ProductEntity>>
      getProductById(
    String id,
  ) async {
    try {
      print(
        '🔄 Loading product by ID: $id',
      );

      final response =
          await Dio().get(
        'https://dummyjson.com/products/$id',
      );

      if (response.statusCode != 200) {
        return const Left(
          'Failed to load product',
        );
      }

      final Map<String, dynamic> json =
          Map<String, dynamic>.from(
        response.data,
      );

      final product =
          _mapProduct(json);

      return Right(product);
    }

    on DioException catch (e) {
      return Left(
        'API Error: ${e.message}',
      );
    }

    catch (e) {
      return Left(
        'Failed to load product: $e',
      );
    }
  }

  // ============================================================
  // SEARCH PRODUCTS
  // ============================================================

  @override
  Future<Either<String, List<ProductEntity>>>
      searchProducts(
    String query,
  ) async {
    try {
      final String searchQuery =
          query.trim();

      if (searchQuery.isEmpty) {
        return const Right([]);
      }

      print(
        '🔍 Searching products: $searchQuery',
      );

      final response =
          await Dio().get(
        'https://dummyjson.com/products/search',
        queryParameters: {
          'q': searchQuery,
          'limit': 150,
        },
      );

      if (response.statusCode != 200) {
        return const Left(
          'Failed to search products',
        );
      }

      final List data =
          response.data['products']
              as List? ??
          [];

      final products =
          data
              .map<ProductEntity>(
                (json) => _mapProduct(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList();

      print(
        '✅ Search results: '
        '${products.length}',
      );

      return Right(products);
    }

    on DioException catch (e) {
      return Left(
        'Search API Error: ${e.message}',
      );
    }

    catch (e) {
      return Left(
        'Search error: $e',
      );
    }
  }

  // ============================================================
  // GET PRODUCTS BY CATEGORY
  // ============================================================

  @override
  Future<Either<String, List<ProductEntity>>>
      getProductsByCategory(
    String categoryId,
  ) async {
    return getProducts(
      page: 0,
      limit: 150,
      categoryId: categoryId,
      ascending: true,
    );
  }
}