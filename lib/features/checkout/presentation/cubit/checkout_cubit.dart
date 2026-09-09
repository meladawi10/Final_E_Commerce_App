import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/checkout/domain/usecases/create_order_usecase.dart';
import 'package:t_store/features/checkout/presentation/cubit/checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CreateOrderUsecase createOrderUsecase;

  CheckoutCubit({required this.createOrderUsecase}) : super(CheckoutInitial());

  Map<String, dynamic> selectedAddress = {
    'full_name': 'John Doe',
    'phone': '+20 123 456 7890',
    'address_line1': '123 E-Commerce St',
    'city': 'Cairo',
    'state': 'Cairo',
  };

  String selectedPaymentMethod = 'Cash on Delivery';

  void selectAddress(Map<String, dynamic> address) {
    selectedAddress = address;
    emit(CheckoutAddressSelected(address));
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod = method;
    emit(CheckoutPaymentSelected(method));
  }

  Future<void> placeOrder({
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    emit(CheckoutLoading());

    final result = await createOrderUsecase(CreateOrderParams(
      subtotal: subtotal,
      shippingFee: shippingFee,
      totalAmount: totalAmount,
      paymentMethod: selectedPaymentMethod,
      shippingAddress: selectedAddress,
      items: items,
    ));

    result.fold(
      (error) => emit(CheckoutError(error)),
      (orderId) => emit(CheckoutSuccess(orderId)),
    );
  }
}
