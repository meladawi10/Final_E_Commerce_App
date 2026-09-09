import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'is_dark_mode';

  // بيبدأ بالثيم الافتراضي للنظام، وبعدين بيعمل Load للمحفوظ
  ThemeCubit() : super(const ThemeState(ThemeMode.system)) {
    _loadTheme();
  }

  // الدالة دي بتتنفذ لما اليوزر يدوس على السويتش
  void toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    // 1. يغير الثيم فوراً في التطبيق
    emit(ThemeState(newMode));
    
    // 2. يحفظ الاختيار في الذاكرة
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  // الدالة دي بتقرأ الذاكرة أول ما التطبيق يفتح
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey);
    
    if (isDark != null) {
      emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
    }
  }
}