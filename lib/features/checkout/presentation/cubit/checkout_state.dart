import 'package:equatable/equatable.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutAddressSelected extends CheckoutState {
  final Map<String, dynamic> address;

  const CheckoutAddressSelected(this.address);

  @override
  List<Object?> get props => [address];
}

class CheckoutPaymentSelected extends CheckoutState {
  final String paymentMethod;

  const CheckoutPaymentSelected(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class CheckoutSuccess extends CheckoutState {
  final String orderId;

  const CheckoutSuccess(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}
