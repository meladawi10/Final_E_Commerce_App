import 'package:dartz/dartz.dart';

abstract class CheckoutRepository {
  Future<Either<String, String>> createOrder({
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required String paymentMethod,
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
  });
}
