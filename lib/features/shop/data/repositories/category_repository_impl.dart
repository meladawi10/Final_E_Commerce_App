
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';

import 'package:t_store/features/shop/data/models/category_model.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final SupabaseService supabaseService;

  CategoryRepositoryImpl({
    required this.supabaseService,
  });

  // ============================================================
  // GET ALL CATEGORIES
  // ============================================================

  @override
  Future<Either<String, List<CategoryEntity>>> getCategories() async {
    try {
      debugPrint('==============================================');
      debugPrint('CATEGORY: Starting getCategories()');
      debugPrint(
        'CATEGORY: Table = ${SupabaseTables.categories}',
      );

      final response = await supabaseService.client
          .from(SupabaseTables.categories)
          .select()
          .order('sort_order', ascending: true);

      debugPrint('CATEGORY: Supabase response received');
      debugPrint('CATEGORY: Response type = ${response.runtimeType}');
      debugPrint('CATEGORY: Response = $response');

      final responseList = response as List;

      debugPrint(
        'CATEGORY: Number of categories = ${responseList.length}',
      );

      if (responseList.isEmpty) {
        debugPrint(
          'CATEGORY: WARNING -> Supabase returned EMPTY list!',
        );

        return const Right([]);
      }

      final categories = responseList.map((json) {
        debugPrint('CATEGORY ROW: $json');

        return CategoryModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
      }).toList();

      debugPrint(
        'CATEGORY: Parsed categories = ${categories.length}',
      );

      for (final category in categories) {
        debugPrint(
          'CATEGORY: ${category.name} | '
          'ID: ${category.id} | '
          'Active: ${category.isActive}',
        );
      }

      debugPrint('CATEGORY: getCategories() SUCCESS');
      debugPrint('==============================================');

      return Right(categories);
    } catch (e, stackTrace) {
      debugPrint('==============================================');
      debugPrint('CATEGORY ERROR: $e');
      debugPrint('CATEGORY STACK TRACE: $stackTrace');
      debugPrint('==============================================');

      return Left(
        'Failed to load categories: $e',
      );
    }
  }

  // ============================================================
  // GET CATEGORY BY ID
  // ============================================================

  @override
  Future<Either<String, CategoryEntity>> getCategoryById(
    String id,
  ) async {
    try {
      final response = await supabaseService.client
          .from(SupabaseTables.categories)
          .select()
          .eq('id', id)
          .single();

      return Right(
        CategoryModel.fromJson(
          Map<String, dynamic>.from(response),
        ),
      );
    } catch (e) {
      debugPrint(
        'CATEGORY BY ID ERROR: $e',
      );

      return Left(
        'Failed to load category: $e',
      );
    }
  }

  // ============================================================
  // GET PARENT CATEGORIES
  // ============================================================

  @override
  Future<Either<String, List<CategoryEntity>>>
      getParentCategories() async {
    try {
      final response = await supabaseService.client
          .from(SupabaseTables.categories)
          .select()
          .isFilter('parent_id', null)
          .order('sort_order', ascending: true);

      final responseList = response as List;

      final categories = responseList.map((json) {
        return CategoryModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
      }).toList();

      return Right(categories);
    } catch (e) {
      debugPrint(
        'PARENT CATEGORIES ERROR: $e',
      );

      return Left(
        'Failed to load parent categories: $e',
      );
    }
  }

  // ============================================================
  // GET SUB CATEGORIES
  // ============================================================

  @override
  Future<Either<String, List<CategoryEntity>>>
      getSubCategories(
    String parentId,
  ) async {
    try {
      final response = await supabaseService.client
          .from(SupabaseTables.categories)
          .select()
          .eq('parent_id', parentId)
          .order('sort_order', ascending: true);

      final responseList = response as List;

      final categories = responseList.map((json) {
        return CategoryModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
      }).toList();

      return Right(categories);
    } catch (e) {
      debugPrint(
        'SUB CATEGORIES ERROR: $e',
      );

      return Left(
        'Failed to load sub categories: $e',
      );
    }
  }
}
