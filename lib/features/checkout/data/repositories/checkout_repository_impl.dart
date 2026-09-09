import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final SupabaseService supabaseService;

  CheckoutRepositoryImpl({required this.supabaseService});

  String get _userId => supabaseService.currentUser?.id ?? '';

  @override
  Future<Either<String, String>> createOrder({
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required String paymentMethod,
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      if (_userId.isEmpty) {
        return const Left('يرجى تسجيل الدخول أولاً');
      }

      // 1. Insert Order
      final orderResponse = await supabaseService.client
          .from(SupabaseTables.orders)
          .insert({
            'user_id': _userId,
            'status': 'pending',
            'subtotal': subtotal,
            'shipping_fee': shippingFee,
            'total_amount': totalAmount,
            'payment_method': paymentMethod,
            'payment_status': 'paid',
            'shipping_address': shippingAddress,
          })
          .select('id')
          .single();

      final orderId = orderResponse['id'] as String;

      // 2. Insert Order Items
      final orderItemsData = items.map((item) => {
            'order_id': orderId,
            'product_id': item['product_id'],
            'quantity': item['quantity'],
            'price': item['price'],
            'selected_attributes': item['selected_attributes'],
          }).toList();

      await supabaseService.client.from(SupabaseTables.orderItems).insert(orderItemsData);

      return Right(orderId);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
