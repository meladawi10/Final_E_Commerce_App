import 'package:flutter_bloc/flutter_bloc.dart';

class CartItemModel {
  final String title;
  final String price;
  final String image;
  final String brandName;
  int quantity;

  CartItemModel({
    required this.title,
    required this.price,
    required this.image,
    required this.brandName,
    this.quantity = 1,
  });
}

abstract class CartState {}

class CartInitial extends CartState {}

class CartUpdated extends CartState {
  final List<CartItemModel> items;
  CartUpdated(this.items);
}

class CartCubit extends Cubit<CartState> {
  // إنشاء نسخة واحدة ثابتة (Singleton) لكل التطبيق
  static final CartCubit _instance = CartCubit._internal();
  factory CartCubit() => _instance;
  CartCubit._internal() : super(CartInitial());

  final List<CartItemModel> cartItems = [];

  void addToCart(CartItemModel newItem) {
    final index = cartItems.indexWhere((item) => item.title == newItem.title);
    if (index >= 0) {
      cartItems[index].quantity += newItem.quantity;
    } else {
      cartItems.add(newItem);
    }
    emit(CartUpdated(List.from(cartItems)));
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
    emit(CartUpdated(List.from(cartItems)));
  }

  void updateQuantity(int index, int delta) {
    cartItems[index].quantity += delta;
    if (cartItems[index].quantity <= 0) {
      cartItems.removeAt(index);
    }
    emit(CartUpdated(List.from(cartItems)));
  }

  double calculateSubtotal() {
    double subtotal = 0;
    for (var item in cartItems) {
      final cleanPrice = double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      subtotal += cleanPrice * item.quantity;
    }
    return subtotal;
  }
}