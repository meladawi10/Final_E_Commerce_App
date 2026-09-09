import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/api/ecommerce_api_client.dart';
import 'package:t_store/core/utils/helpers/dio_exception_helper.dart';
import 'package:t_store/core/utils/helpers/platform_exception_helper.dart';
import 'package:t_store/features/auth/data/models/change_password_req_body.dart';
import 'package:t_store/features/auth/data/models/change_password_response.dart';
import 'package:t_store/features/auth/data/models/login_req_body.dart';
import 'package:t_store/features/auth/data/models/login_response.dart';
import 'package:t_store/features/auth/data/models/register_req_body.dart';
import 'package:t_store/features/auth/data/models/send_otp_req_body.dart';
import 'package:t_store/features/auth/data/models/send_otp_response.dart';

abstract class AuthRemoteDataSource {
  Future<Either<String, void>> register({
    required RegisterReqBody registerReqBody,
  });

  Future<Either<String, LoginResponse>> login({
    required LoginReqBody loginReqBody,
  });

  Future<Either<String, SendOtpResponseData>> sendOtp({
    required SendOtpReqBody forgetPasswordReqBody,
  });

  Future<Either<String, ChangePasswordResponseData>> setNewPassword({
    required ChangePasswordReqBody changePasswordReqBody,
  });

  Future<Either<String, void>> verifyEmail({
    required String email,
    required String otp,
  });

  Future<Either<String, void>> resendOtp({
    required String email,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final EcommerceApiClient apiClient;

  final SupabaseClient _supabase = Supabase.instance.client;

  AuthRemoteDataSourceImpl({
    required this.apiClient,
  });

  // ============================================================
  // REGISTER
  // ============================================================

  @override
  Future<Either<String, void>> register({
    required RegisterReqBody registerReqBody,
  }) async {
    try {
      debugPrint('🚀 التسجيل مباشرة عبر Supabase Auth...');

      final AuthResponse response = await _supabase.auth.signUp(
        email: registerReqBody.email,
        password: registerReqBody.password,
        data: {
          'full_name':
              '${registerReqBody.firstName} ${registerReqBody.lastName}',
        },
      );

      final user = response.user;

      if (user != null) {
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'email': registerReqBody.email,
          'full_name':
              '${registerReqBody.firstName} ${registerReqBody.lastName}',
        });

        debugPrint(
          '✅ تم الحفظ بنجاح في جدول profiles الخاص بك في Supabase!',
        );
      }

      return const Right(null);
    } on AuthException catch (e) {
      debugPrint('⚠️ خطأ من Supabase Auth: ${e.message}');
      return Left(e.message);
    } on PostgrestException catch (e) {
      debugPrint('⚠️ خطأ من Supabase Database: ${e.message}');
      return Left(e.message);
    } catch (e) {
      debugPrint('❌ حدث خطأ غير متوقع: $e');
      return Left('حدث خطأ غير متوقع: $e');
    }
  }

  // ============================================================
  // LOGIN - SUPABASE
  // ============================================================

  @override
  Future<Either<String, LoginResponse>> login({
    required LoginReqBody loginReqBody,
  }) async {
    try {
      debugPrint('🚀 تسجيل الدخول عبر Supabase...');
      debugPrint('📧 Email: ${loginReqBody.email}');

      // تسجيل الدخول من Supabase Auth
      final AuthResponse response =
          await _supabase.auth.signInWithPassword(
        email: loginReqBody.email,
        password: loginReqBody.password,
      );

      final user = response.user;
      final session = response.session;

      // التأكد أن تسجيل الدخول نجح
      if (user == null || session == null) {
        debugPrint('❌ لم يتم إنشاء User أو Session');

        return const Left(
          'فشل تسجيل الدخول، لم يتم إنشاء جلسة للمستخدم',
        );
      }

      debugPrint('✅ تم تسجيل الدخول بنجاح');
      debugPrint('👤 User ID: ${user.id}');
      debugPrint('📧 User Email: ${user.email}');

      // ========================================================
      // GET PROFILE
      // ========================================================

      Map<String, dynamic>? profile;

      try {
        profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        debugPrint('📦 Profile Data: $profile');
      } on PostgrestException catch (e) {
        debugPrint(
          '⚠️ لم يتم جلب profile: ${e.message}',
        );
      }

      // ========================================================
      // LOGIN RESPONSE
      // ========================================================

      final String accessToken = session.accessToken;

      final String refreshToken =
          session.refreshToken ?? '';

      final String expiresAtUtc =
          session.expiresAt != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  session.expiresAt! * 1000,
                ).toUtc().toIso8601String()
              : '';

      final LoginResponse loginResponse = LoginResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAtUtc: expiresAtUtc,
      );

      debugPrint('🎟️ Access Token received');
      debugPrint('🔄 Refresh Token received');
      debugPrint('⏰ Session expires at: $expiresAtUtc');

      return Right(loginResponse);
    } on AuthException catch (e) {
      debugPrint(
        '⚠️ Supabase Auth Error: ${e.message}',
      );

      return Left(e.message);
    } on PlatformException catch (e) {
      debugPrint(
        '⚠️ Platform Error: ${e.message}',
      );

      return Left(
        PlatformExceptionHelper.handlePlatformError(e),
      );
    } catch (e) {
      debugPrint(
        '❌ Login Error: $e',
      );

      return Left(
        'حدث خطأ غير متوقع: $e',
      );
    }
  }

  // ============================================================
  // SEND OTP
  // ============================================================

  @override
  Future<Either<String, SendOtpResponseData>> sendOtp({
    required SendOtpReqBody forgetPasswordReqBody,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/auth/forgot-password',
        data: forgetPasswordReqBody.toJson(),
      );

      final SendOtpResponse forgetPassResponse =
          SendOtpResponse.fromJson(response.data);

      if (forgetPassResponse.status) {
        return Right(forgetPassResponse.data!);
      } else {
        return Left(forgetPassResponse.message);
      }
    } on DioException catch (e) {
      debugPrint(
        'DioException during sendOtp: '
        'status=${e.response?.statusCode}, '
        'data=${e.response?.data}',
      );

      return Left(
        e.error?.toString() ??
            DioExceptionHelper.handleDioError(e),
      );
    } on PlatformException catch (e) {
      return Left(
        PlatformExceptionHelper.handlePlatformError(e),
      );
    } catch (e) {
      return Left(
        'حدث خطأ غير متوقع: $e',
      );
    }
  }

  // ============================================================
  // SET NEW PASSWORD
  // ============================================================

  @override
  Future<Either<String, ChangePasswordResponseData>>
      setNewPassword({
    required ChangePasswordReqBody changePasswordReqBody,
  }) async {
    try {
      final String token = changePasswordReqBody.token;

      final response = await apiClient.dio.post(
        '/api/auth/reset-password',
        data: changePasswordReqBody.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final ChangePasswordResponse changePasswordResponse =
          ChangePasswordResponse.fromJson(response.data);

      if (changePasswordResponse.status) {
        return Right(changePasswordResponse.data!);
      } else {
        return Left(changePasswordResponse.message);
      }
    } on DioException catch (e) {
      debugPrint(
        'DioException during setNewPassword: '
        'status=${e.response?.statusCode}, '
        'data=${e.response?.data}',
      );

      return Left(
        e.error?.toString() ??
            DioExceptionHelper.handleDioError(e),
      );
    } on PlatformException catch (e) {
      return Left(
        PlatformExceptionHelper.handlePlatformError(e),
      );
    } catch (e) {
      return Left(
        'حدث خطأ غير متوقع: $e',
      );
    }
  }

  // ============================================================
  // VERIFY EMAIL
  // ============================================================

  @override
  Future<Either<String, void>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      debugPrint(
        'Verifying email: $email with OTP: $otp',
      );

      await apiClient.dio.post(
        '/api/auth/verify-email',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      return const Right(null);
    } on DioException catch (e) {
      debugPrint(
        'DioException during verifyEmail: '
        'status=${e.response?.statusCode}, '
        'data=${e.response?.data}',
      );

      return Left(
        e.error?.toString() ??
            DioExceptionHelper.handleDioError(e),
      );
    } on PlatformException catch (e) {
      return Left(
        PlatformExceptionHelper.handlePlatformError(e),
      );
    } catch (e) {
      return Left(
        'حدث خطأ غير متوقع: $e',
      );
    }
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  @override
  Future<Either<String, void>> resendOtp({
    required String email,
  }) async {
    try {
      debugPrint(
        'Resending OTP to email: $email',
      );

      await apiClient.dio.post(
        '/api/auth/resend-otp',
        data: {
          'email': email,
        },
      );

      return const Right(null);
    } on DioException catch (e) {
      debugPrint(
        'DioException during resendOtp: '
        'status=${e.response?.statusCode}, '
        'data=${e.response?.data}',
      );

      return Left(
        e.error?.toString() ??
            DioExceptionHelper.handleDioError(e),
      );
    } on PlatformException catch (e) {
      return Left(
        PlatformExceptionHelper.handlePlatformError(e),
      );
    } catch (e) {
      return Left(
        'حدث خطأ غير متوقع: $e',
      );
    }
  }
}