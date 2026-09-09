import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/checkout/domain/repositories/checkout_repository.dart';

class CreateOrderParams {
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final String paymentMethod;
  final Map<String, dynamic> shippingAddress;
  final List<Map<String, dynamic>> items;

  const CreateOrderParams({
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.items,
  });
}

class CreateOrderUsecase implements UseCase<String, CreateOrderParams> {
  final CheckoutRepository repository;

  CreateOrderUsecase(this.repository);

  @override
  Future<Either<String, String>> call(CreateOrderParams params) async {
    return await repository.createOrder(
      subtotal: params.subtotal,
      shippingFee: params.shippingFee,
      totalAmount: params.totalAmount,
      paymentMethod: params.paymentMethod,
      shippingAddress: params.shippingAddress,
      items: params.items,
    );
  }
}
