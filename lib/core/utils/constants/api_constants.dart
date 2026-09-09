import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String dummyBaseUrl = 'https://dummyjson.com/products';

  static String getDummyProducts({int page = 1, int limit = 10}) =>
      '$dummyBaseUrl?limit=$limit&skip=${(page - 1) * limit}';
  static String getDummyProductById(int id) => '$dummyBaseUrl/$id';
  static String getDummyCategories() => '$dummyBaseUrl/categories';
  static String getDummyProductsBySearch({String? search}) =>
      '$dummyBaseUrl/search?q=$search';
  static String getDummyProductsByCategory({required String categoryName}) =>
      '$dummyBaseUrl/category/$categoryName';
  static String getDummySortedProducts(
          {required String sortBy, required String sortType}) =>
      '$dummyBaseUrl?sortBy=$sortBy&order=$sortType';
      
  static String get baseURL => dotenv.env['MASTER_API_BASE_URL'] ?? 'https://master-market.masool.net/api/';
  static String get registerUrl => '${baseURL}register';
  static String get loginUrl => '${baseURL}login';
  static String get userProfileUrl => '${baseURL}profile';
  static String get logoutUrl => '${baseURL}user_delete/0';
  static String get forgotPasswordUrl => '${baseURL}forget_pass_user';
  static String get resetPasswordUrl => '${baseURL}change_password';
  // Additional URLs from the collection
  static String get updateProfileUrl => '${baseURL}update_profile/0';
  static String get userOrdersUrl => '${baseURL}user_orders';
  static String get getUserOrdersUrl => '${baseURL}user_orders/t/ar';
  static String get userFavoritesUrl => '${baseURL}user_favorite/t/ar';
  static String get addUserFavoriteUrl => '${baseURL}user_favorite';
  static String get categoriesUrl => '${baseURL}categories/t/ar/0/0';
  static String get sliderUrl => '${baseURL}advertising/t/ar/0';
  static String get categoriesWithSubUrl =>
      '${baseURL}categories/get_with_sub/ar/0/0';
  static String get productsInCategoriesUrl =>
      '${baseURL}categories/get_with_product_sub/ar/0/0';

  static String get imageUrl => 'https://master-market.masool.net/uploads/';
  static String getProductsByPageUrl(String page) =>
      '${baseURL}products/t/ar/0/0/0?page=$page';
  static String getProductsBySearchUrl(String term) =>
      "${baseURL}products/t/ar/0/0/0?search=$term";
}
