import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/local_preferences_helper.dart';

class TokenRefreshInterceptor extends QueuedInterceptor {
  final Dio dio;

  TokenRefreshInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final token = sl<LocalPreferencesHelper>().authToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final response = await Supabase.instance.client.auth.refreshSession();
        final session = response.session;
        
        if (session != null && session.accessToken.isNotEmpty) {
          await sl<LocalPreferencesHelper>().setAuthToken(session.accessToken);

          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${session.accessToken}';

          final cloneReq = await dio.fetch(opts);
          return handler.resolve(cloneReq);
        }
      } catch (e) {
        try {
          await sl<LocalPreferencesHelper>().clearAuthToken();
        } catch (_) {}
      }
    }
    return super.onError(err, handler);
  }
}
