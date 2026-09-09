import 'package:t_store/features/shop/domain/repositories/product_repository.dart';

class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  Future<bool> call({
    required String name,
    required double price,
    required String description,
  }) async {
    return await repository.addProduct(
      name: name,
      price: price,
      description: description,
    );
  }
}
