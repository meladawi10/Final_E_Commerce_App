import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/shop/domain/usecases/add_product_usecase.dart';
import 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final AddProductUseCase addProductUseCase;

  AddProductCubit(this.addProductUseCase) : super(AddProductInitial());

  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
  }) async {
    emit(AddProductLoading());
    
    final isSuccess = await addProductUseCase(
      name: name,
      price: price,
      description: description,
    );

    if (isSuccess) {
      emit(AddProductSuccess());
    } else {
      emit(AddProductError('??? ????? ??????? ???? ?????? ?? ???????? ?? ??????? ?????????.'));
    }
  }
}
