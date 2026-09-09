// ignore_for_file: depend_on_referenced_packages

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/personalization/presentation/views/settings_view.dart';
import 'package:t_store/features/shop/presentation/views/home_view.dart';
import 'package:t_store/features/shop/presentation/views/store_view.dart';
import 'package:t_store/features/shop/presentation/views/wishlist_view.dart';

part 'navigation_menu_state.dart';
class NavigationMenuCubit extends Cubit<NavigationMenuState> {
  // 👈 شيلنا const من هنا عشان الإيرور يختفي
  NavigationMenuCubit() : super(NavigationMenuInitial()); 

  int selectedIndex = 0;

  final List<Widget> screensList = [
    const HomeView(),
    const WishlistView(),
    const StoreView(), // شاشة السلة
    const StoreView(), // شاشة البحث
    const SettingsView(), // شاشة الإعدادات
  ];

  void changeIndex(int index) {
    selectedIndex = index;
    emit(NavigationMenuChanged(
      selectedIndex: selectedIndex,
    ));
  }

  Widget getScreen() {
    return screensList[selectedIndex];
  }
}