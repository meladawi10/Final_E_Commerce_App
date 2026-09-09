import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'app_locale';

  // بيبدأ بالإنجليزي كافتراضي، وبعدين يقرأ المحفوظ
  LocaleCubit() : super(const Locale('en')) {
    _loadLocale();
  }

  // دالة تغيير اللغة وحفظها
  void changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    emit(Locale(languageCode)); 
  }

  // دالة قراءة اللغة أول ما التطبيق يفتح
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_localeKey) ?? 'en';
    emit(Locale(langCode));
  }
}