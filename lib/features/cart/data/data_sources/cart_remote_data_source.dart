import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:t_store/core/api/ecommerce_api_client.dart';
import 'package:t_store/core/utils/exceptions/exceptions.dart';
import 'package:t_store/features/cart/data/models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<Either<TExceptions, List<CartItemModel>>> getCartItems();

  Future<Either<TExceptions, CartItemModel>> addToCart({
    required String productId,
    required int quantity,
    Map<String, dynamic>? selectedAttributes,
  });

  Future<Either<TExceptions, CartItemModel>> updateCartItem({
    required String cartItemId,
    required int quantity,
  });

  Future<Either<TExceptions, void>> removeFromCart(
    String cartItemId,
  );

  Future<Either<TExceptions, void>> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final EcommerceApiClient apiClient;

  CartRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<Either<TExceptions, List<CartItemModel>>> getCartItems() async {
    try {
      final response = await apiClient.dio.get(
        'api/cart',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        dynamic listData;

        if (responseData is List) {
          listData = responseData;
        } else if (responseData is Map<String, dynamic>) {
          listData = responseData['data'] ??
              responseData['items'] ??
              responseData['cart'] ??
              [];
        }

        if (listData is! List) {
          return Left(
            TExceptions('Invalid cart response'),
          );
        }

        final items = listData
            .whereType<Map>()
            .map(
              (item) => CartItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        return Right(items);
      }

      return Left(
        TExceptions.fromCode(
          response.statusCode?.toString() ?? '500',
        ),
      );
    } on DioException catch (e) {
      return Left(
        TExceptions(
          _getDioErrorMessage(e),
        ),
      );
    } catch (e) {
      return Left(
        TExceptions(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<TExceptions, CartItemModel>> addToCart({
    required String productId,
    required int quantity,
    Map<String, dynamic>? selectedAttributes,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'api/cart/add',
        data: {
          'product_id': productId,
          'quantity': quantity,
          'selected_attributes': selectedAttributes,
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final responseData = response.data;

        dynamic data;

        if (responseData is Map<String, dynamic>) {
          data = responseData['data'] ?? responseData;
        } else {
          data = responseData;
        }

        if (data is! Map) {
          return Left(
            TExceptions('Invalid add to cart response'),
          );
        }

        return Right(
          CartItemModel.fromJson(
            Map<String, dynamic>.from(data),
          ),
        );
      }

      return Left(
        TExceptions.fromCode(
          response.statusCode?.toString() ?? '500',
        ),
      );
    } on DioException catch (e) {
      return Left(
        TExceptions(
          _getDioErrorMessage(e),
        ),
      );
    } catch (e) {
      return Left(
        TExceptions(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<TExceptions, CartItemModel>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await apiClient.dio.put(
        'api/cart/update/$cartItemId',
        data: {
          'quantity': quantity,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        dynamic data;

        if (responseData is Map<String, dynamic>) {
          data = responseData['data'] ?? responseData;
        } else {
          data = responseData;
        }

        if (data is! Map) {
          return Left(
            TExceptions('Invalid update cart response'),
          );
        }

        return Right(
          CartItemModel.fromJson(
            Map<String, dynamic>.from(data),
          ),
        );
      }

      return Left(
        TExceptions.fromCode(
          response.statusCode?.toString() ?? '500',
        ),
      );
    } on DioException catch (e) {
      return Left(
        TExceptions(
          _getDioErrorMessage(e),
        ),
      );
    } catch (e) {
      return Left(
        TExceptions(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<TExceptions, void>> removeFromCart(
    String cartItemId,
  ) async {
    try {
      if (cartItemId.trim().isEmpty) {
        return Left(
          TExceptions('Cart item id is empty'),
        );
      }

      final response = await apiClient.dio.delete(
        'api/cart/remove/$cartItemId',
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        return const Right(null);
      }

      return Left(
        TExceptions.fromCode(
          response.statusCode?.toString() ?? '500',
        ),
      );
    } on DioException catch (e) {
      return Left(
        TExceptions(
          _getDioErrorMessage(e),
        ),
      );
    } catch (e) {
      return Left(
        TExceptions(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<TExceptions, void>> clearCart() async {
    try {
      final response = await apiClient.dio.delete(
        'api/cart/clear',
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        return const Right(null);
      }

      return Left(
        TExceptions.fromCode(
          response.statusCode?.toString() ?? '500',
        ),
      );
    } on DioException catch (e) {
      return Left(
        TExceptions(
          _getDioErrorMessage(e),
        ),
      );
    } catch (e) {
      return Left(
        TExceptions(
          e.toString(),
        ),
      );
    }
  }

  String _getDioErrorMessage(DioException error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;

      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] ??
            responseData['error'] ??
            responseData['detail'];

        if (message != null) {
          return message.toString();
        }
      }

      switch (statusCode) {
        case 400:
          return 'Invalid request';

        case 401:
          return 'Please login again';

        case 403:
          return 'You do not have permission';

        case 404:
          return 'Cart item not found';

        case 500:
          return 'Server error';

        default:
          return 'Request failed ($statusCode)';
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection';
    }

    return error.message ?? 'Network error';
  }
}