import 'package:dartz/dartz.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

abstract class ProductRepository {
  // الدالة الجديدة لإضافة منتج عبر الـ API
  Future<bool> addProduct({
    required String name,
    required double price,
    required String description,
  });

  // دالة جلب المنتجات بالمتغيرات المظبوطة
  Future<Either<String, List<ProductEntity>>> getProducts({
    required int page,
    required int limit,
    String? categoryId,
    String? brandId,
    bool? isFeatured,
    String? sortBy,
    required bool ascending,
  });

  // باقي الدوال الأساسية
  Future<Either<String, ProductEntity>> getProductById(String id);
  
  Future<Either<String, List<ProductEntity>>> searchProducts(String query);
  
  Future<Either<String, List<ProductEntity>>> getProductsByCategory(String categoryId);
}