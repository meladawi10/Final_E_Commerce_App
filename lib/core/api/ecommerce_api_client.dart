import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'token_refresh_interceptor.dart';

class EcommerceApiClient {
  late final Dio dio;

  EcommerceApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: dotenv.env['API_BASE_URL'] ?? 'https://accessories-eshop.runasp.net/',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(TokenRefreshInterceptor(dio));
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) {
          String errorMessage = 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً';

          if (error.response != null) {
            switch (error.response?.statusCode) {
              case 400:
                errorMessage = 'طلب غير صحيح، يرجى التأكد من البيانات الإدخالية';
                break;
              case 401:
                errorMessage = 'جلسة غير مصرح بها، يرجى تسجيل الدخول مجدداً';
                break;
              case 403:
                errorMessage = 'ليس لديك صلاحيات الوصول لهذا المورد';
                break;
              case 404:
                errorMessage = 'المورد المطلوب غير موجود';
                break;
              case 500:
                errorMessage = 'خطأ في السيرفر الداخلي، يرجى المحاولة لاحقاً';
                break;
            }
          } else if (error.type == DioExceptionType.connectionTimeout ||
                     error.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'اتصال الشبكة ضعيف، يرجى التأكد من الاتصال بالإنترنت';
          }

          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: errorMessage,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }
}
