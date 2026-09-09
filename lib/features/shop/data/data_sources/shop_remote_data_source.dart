import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:t_store/core/api/ecommerce_api_client.dart';
import 'package:t_store/core/utils/exceptions/exceptions.dart';
import 'package:t_store/features/shop/data/models/category_model.dart';
import 'package:t_store/features/shop/data/models/product_model.dart';
import 'package:t_store/features/shop/data/models/review_model.dart';

abstract class ShopRemoteDataSource {
  Future<Either<TExceptions, List<ProductModel>>> getProductsList(
      {int page = 1, int limit = 10});

  Future<Either<TExceptions, ProductModel>> getProductById(
      {required dynamic productId});

  Future<Either<TExceptions, List<ProductModel>>> getProductsByCategory(
      {required String categoryId});
      
  Future<Either<TExceptions, List<ProductModel>>> getProductsBySearch(
      {String? search});

  Future<Either<TExceptions, List<CategoryModel>>> getCategories();

  Future<Either<TExceptions, List<ReviewModel>>> getProductReviews(
      {required String productId});

  Future<Either<TExceptions, List<ProductModel>>> getSortedProducts({
    required String sortBy,
    required String sortType,
  });
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final EcommerceApiClient apiClient;
  ShopRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Either<TExceptions, ProductModel>> getProductById(
      {required dynamic productId}) async {
    try {
      var response = await apiClient.dio.get('api/products/$productId');
      if (response.statusCode == 200) {
        var data = response.data['data'] ?? response.data;
        var product = ProductModel.fromJson(data);
        return Right(product);
      } else {
        return Left(TExceptions.fromCode(response.statusCode.toString()));
      }
    } on DioException catch (e) {
      return Left(TExceptions(e.error?.toString() ?? e.message ?? 'Network error'));
    } catch (e) {
      return Left(TExceptions(e.toString()));
    }
  }

  @override
  Future<Either<TExceptions, List<ProductModel>>> getProductsList(
      {int page = 1, int limit = 10}) async {
    try {
      var response = await apiClient.dio
          .get('api/products', queryParameters: {'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        var data = response.data;
        var rawList = data is List ? data : (data['data'] ?? data['products'] ?? []);
        var list = (rawList as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();
        return Right(list);
      } else {
        return Left(TExceptions.fromCode(response.statusCode.toString()));
      }
    } on DioException catch (e) {
      return Left(TExceptions(e.error?.toString() ?? e.message ?? 'Network error'));
    } catch (e) {
      return Left(TExceptions(e.toString()));
    }
  }

  @override
  Future<Either<TExceptions, List<ProductModel>>> getProductsByCategory(
      {required String categoryId}) async {
    try {
      // 🌟 المسار ده هو اللي بيجيب منتجات القسم ده بالذات من الـ API
      var response = await apiClient.dio.get('api/categories/$categoryId/products');
      if (response.statusCode == 200) {
        var data = response.data;
        var rawList = data is List ? data : (data['data'] ?? data['products'] ?? []);
        var list = (rawList as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();
        return Right(list);
      } else {
        return Left(TExceptions.fromCode(response.statusCode.toString()));
      }
    } on DioException catch (e) {
      return Left(TExceptions(e.error?.toString() ?? e.message ?? 'Network error'));
    } catch (e) {
      return Left(TExceptions(e.toString()));
    }
  }

  @override
  Future<Either<TExceptions, List<ProductModel>>> getProductsBySearch(
      {String? search}) async {
    try {
      var response = await apiClient.dio
          .get('api/products/search', queryParameters: {'q': search});
      if (response.statusCode == 200) {
        var data = response.data;
        var rawList = data is List ? data : (data['data'] ?? data['products'] ?? []);
        var list = (rawList as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();
        return Right(list);
      } else {
        return Left(TExceptions.fromCode(response.statusCode.toString()));
      }
    } on DioException catch (e) {
      return Left(TExceptions(e.error?.toString() ?? e.message ?? 'Network error'));
    } catch (e) {
      return Left(TExceptions(e.toString()));
    }
  }

  @override
  Future<Either<TExceptions, List<CategoryModel>>> getCategories() async {
    try {
      var response = await apiClient.dio.get('api/categories');
      if (response.statusCode == 200) {
        var data = response.data;
        var rawList = data is List ? data : (data['data'] ?? data['categories'] ?? []);
        var list = (rawList as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();
        return Right(list);
      } else {
        return Left(TExceptions.fromCode(response.statusCode.toString()));
      }
    } on DioException catch (e) {
      return Left(TExceptions(e.error?.toString() ?? e.message ?? 'Network error'));
    } catch (e) {
      return Left(TExceptions(e.toString()));
    }
  }

  @override
  Future<Either<TExceptions, List<ReviewModel>>> getProductReviews(
      {required String productId}) async {
    try {
      var response = await apiClient.dio.get('api/products/$productId/reviews');
      if (response.statusCode == 200) {
        var data = response.data;
        var rawList = data is List ? data : (data['data'] ?? []);
        var list = (rawList as List)
            .map((e) => ReviewModel.fromJson(e))
            .toList();
        return Right(list);
      } else {
        return Left(TExceptions.fromCode(response.statusCode.toString()));
      }
    } on DioException catch (e) {
      return Left(TExceptions(e.error?.toString() ?? e.message ?? 'Network error'));
    } catch (e) {
      return Left(TExceptions(e.toString()));
    }
  }

  @override
  Future<Either<TExceptions, List<ProductModel>>> getSortedProducts(
      {required String sortBy, required String sortType}) async {
    return getProductsList();
  }
}