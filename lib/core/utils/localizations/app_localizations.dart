import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  // 🛠️ التعديل هنا: تحديد النوع بوضوح لكي يفهمها فلاتر بسلاسة
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // 🌍 كل الكلمات هنا في مكان واحد
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'account': 'Account',
      'setting_section': 'General Settings',
      'notification': 'Notification',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'privacy': 'Privacy',
      'help_center': 'Help Center',
      'about_us': 'About Us',
      'home': 'Home',
      'wishlist': 'Wishlist',
      'search': 'Search',
      'profile': 'Profile',
      'name': 'Name',
      'delete_account': 'Delete Account',
      'cart': 'Shopping Cart',
      'checkout': 'Checkout',
      'place_order': 'Place Order',
      'add_to_cart': 'Add to Cart',
      
      // Profile Words
      'username': 'Username',
      'user_id': 'User ID',
      'email': 'Email',
      'phone_number': 'Phone Number',
      'not_registered': 'Not Registered',
      'gender': 'Gender',
      'male': 'Male',
      'date_of_birth': 'Date Of Birth',
      'change_picture': 'Change Profile Picture',
      'profile_info': 'Profile Information',
      'personal_info': 'Personal Information',
      'logout': 'Logout',
    },
    'ar': {
      'settings': 'الإعدادات',
      'account': 'الحساب',
      'setting_section': 'الإعدادات العامة',
      'notification': 'الإشعارات',
      'language': 'اللغة',
      'dark_mode': 'الوضع الداكن',
      'privacy': 'الخصوصية',
      'help_center': 'مركز المساعدة',
      'about_us': 'من نحن',
      'home': 'الرئيسية',
      'wishlist': 'المفضلة',
      'search': 'بحث',
      'profile': 'الملف الشخصي',
      'name': 'الاسم',
      'delete_account': 'حذف الحساب',
      'cart': 'سلة التسوق',
      'checkout': 'إتمام الشراء',
      'place_order': 'تأكيد الطلب',
      'add_to_cart': 'أضف إلى السلة',
      
      // Profile Words
      'username': 'اسم المستخدم',
      'user_id': 'معرف المستخدم',
      'email': 'البريد الإلكتروني',
      'phone_number': 'رقم الهاتف',
      'not_registered': 'غير مسجل',
      'gender': 'الجنس',
      'male': 'ذكر',
      'date_of_birth': 'تاريخ الميلاد',
      'change_picture': 'تغيير صورة الملف الشخصي',
      'profile_info': 'معلومات الملف الشخصي',
      'personal_info': 'المعلومات الشخصية',
      'logout': 'تسجيل الخروج',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key; 
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// 🔥 الاختصار السحري اللي بيخليك تترجم أي كلمة بسهولة
extension LocalizationExtension on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context).translate(this);
  }
}