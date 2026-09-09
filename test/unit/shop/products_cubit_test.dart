import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_product_by_id_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class MockGetProductsUsecase extends Mock implements GetProductsUsecase {}
class MockGetProductByIdUsecase extends Mock implements GetProductByIdUsecase {}
class MockSearchProductsUsecase extends Mock implements SearchProductsUsecase {}

class FakeGetProductsParams extends Fake implements GetProductsParams {}

void main() {
  late ProductsCubit productsCubit;
  late MockGetProductsUsecase mockGetProductsUsecase;
  late MockGetProductByIdUsecase mockGetProductByIdUsecase;
  late MockSearchProductsUsecase mockSearchProductsUsecase;

  final testProducts = [
    const ProductEntity(
      id: 'product-1',
      name: 'Test Product 1',
      description: 'Description 1',
      price: 99.99,
      salePrice: 79.99,
      categoryId: 'smartphones',
      brandId: 'brand-1',
      stock: 10,
      images: ['image1.jpg', 'image2.jpg'],
      thumbnail: 'thumb1.jpg',
      rating: 4.8,
      reviewsCount: 10,
      isFeatured: true,
    ),
    const ProductEntity(
      id: 'product-2',
      name: 'Test Product 2',
      description: 'Description 2',
      price: 149.99,
      categoryId: 'mens-shirts',
      stock: 5,
      images: ['image3.jpg'],
      rating: 3.8,
      reviewsCount: 5,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeGetProductsParams());
  });

  setUp(() {
    mockGetProductsUsecase = MockGetProductsUsecase();
    mockGetProductByIdUsecase = MockGetProductByIdUsecase();
    mockSearchProductsUsecase = MockSearchProductsUsecase();

    when(() => mockGetProductsUsecase(any())).thenAnswer((_) async => Right(testProducts));

    productsCubit = ProductsCubit(
      getProductsUsecase: mockGetProductsUsecase,
      getProductByIdUsecase: mockGetProductByIdUsecase,
      searchProductsUsecase: mockSearchProductsUsecase,
    );
  });

  tearDown(() {
    productsCubit.close();
  });

  group('ProductsCubit Tests', () {
    test('initial state triggers getProducts and loads successfully', () {
      expect(productsCubit.state, isA<ProductsLoaded>());
    });

    group('getProducts', () {
      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductsLoading, ProductsLoaded] when getProducts succeeds',
        build: () {
          when(() => mockGetProductsUsecase(any()))
              .thenAnswer((_) async => Right(testProducts));
          return productsCubit;
        },
        act: (cubit) => cubit.getProducts(refresh: true),
        expect: () => [
          ProductsLoading(),
          ProductsLoaded(
            products: testProducts,
            featuredProducts: testProducts.where((p) => p.rating >= 4.7).toList(),
            popularProducts: testProducts.where((p) => p.categoryId == 'mens-shirts' || p.categoryId == 'smartphones').toList(),
            newArrivals: testProducts.reversed.take(6).toList(),
            hasReachedMax: true,
            currentPage: 1,
          ),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductsLoading, ProductsError] when getProducts fails',
        build: () {
          when(() => mockGetProductsUsecase(any()))
              .thenAnswer((_) async => const Left('Failed to fetch products'));
          return productsCubit;
        },
        act: (cubit) => cubit.getProducts(refresh: true),
        expect: () => [
          ProductsLoading(),
          ProductsError('Failed to fetch products'),
        ],
      );
    });

    group('Local Sorting and Filtering', () {
      blocTest<ProductsCubit, ProductsState>(
        'sorts products locally by price (low to high)',
        build: () => productsCubit,
        seed: () => ProductsLoaded(
          products: testProducts,
          featuredProducts: testProducts.where((p) => p.rating >= 4.7).toList(),
          popularProducts: testProducts.where((p) => p.categoryId == 'mens-shirts' || p.categoryId == 'smartphones').toList(),
          newArrivals: testProducts.reversed.take(6).toList(),
          currentPage: 1,
          hasReachedMax: true,
        ),
        act: (cubit) => cubit.sortProductsLocally('low_to_high'),
        expect: () => [
          isA<ProductsLoaded>().having(
            (s) => s.products.first.price,
            'first product price',
            99.99,
          ),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'filters discounted products locally',
        build: () => productsCubit,
        seed: () => ProductsLoaded(
          products: testProducts,
          featuredProducts: testProducts.where((p) => p.rating >= 4.7).toList(),
          popularProducts: testProducts.where((p) => p.categoryId == 'mens-shirts' || p.categoryId == 'smartphones').toList(),
          newArrivals: testProducts.reversed.take(6).toList(),
          currentPage: 1,
          hasReachedMax: true,
        ),
        act: (cubit) => cubit.toggleDiscountFilterLocally(true),
        expect: () => [
          isA<ProductsLoaded>().having(
            (s) => s.products.length,
            'discounted products count',
            1,
          ),
        ],
      );
    });
  });
}