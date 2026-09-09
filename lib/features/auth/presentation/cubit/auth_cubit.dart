import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// منع حزمة supabase_flutter من تصدير AuthState الخاص بها لتجنب التعارض
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/local_preferences_helper.dart';
import 'package:t_store/features/auth/domain/repositories/auth_repository.dart';
import 'package:t_store/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUsecase signInUsecase;
  final SignUpUsecase signUpUsecase;
  final SignOutUsecase signOutUsecase;
  final ResetPasswordUsecase resetPasswordUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final LocalPreferencesHelper? _preferencesHelper;

  AuthCubit({
    required this.signInUsecase,
    required this.signUpUsecase,
    required this.signOutUsecase,
    required this.resetPasswordUsecase,
    required this.getCurrentUserUsecase,
    LocalPreferencesHelper? preferencesHelper,
  })  : _preferencesHelper = preferencesHelper ?? _getPreferencesHelperSafely(),
        super(AuthInitial());

  static LocalPreferencesHelper? _getPreferencesHelperSafely() {
    try {
      if (sl.isRegistered<LocalPreferencesHelper>()) {
        return sl<LocalPreferencesHelper>();
      }
      return sl<LocalPreferencesHelper>();
    } catch (_) {
      return null;
    }
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final result = await getCurrentUserUsecase(const NoParams());

    result.fold(
      (error) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await signInUsecase(SignInParams(
      email: email,
      password: password,
    ));

    result.fold(
      (error) {
        emit(AuthError(error));
      },
      (user) async {
        _preferencesHelper?.setAuthToken(user.id);
        
        try {
          await Supabase.instance.client.auth.getSession();
          
          // 🚀 إجبار حفظ وإرسال بيانات المستخدم لجدول profiles عند تسجيل الدخول
          final supabaseClient = Supabase.instance.client;
          final currentUser = supabaseClient.auth.currentUser;
          if (currentUser != null) {
            await supabaseClient.from('profiles').upsert({
              'id': currentUser.id,
              'full_name': currentUser.userMetadata?['full_name'] ?? 'Mohamed Mahmoud Moustafa',
              'email': currentUser.email ?? email,
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          debugPrint("⚠️ خطأ أثناء مزامنة البروفايل في الداتا بيز: $e");
        }

        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    debugPrint('AuthCubit.signUp called with email: $email');
    emit(AuthLoading());

    try {
      final result = await signUpUsecase(SignUpParams(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      ));

      result.fold(
        (error) {
          debugPrint('AuthCubit.signUp failed: $error');
          emit(AuthError(error));
        },
        (user) async {
          debugPrint('AuthCubit.signUp success, bypassing verification for email: $email');
          
          if (user != null) {
            _preferencesHelper?.setAuthToken(user.id);
            try {
              await Supabase.instance.client.auth.getSession();
              
              // 🚀 حفظ بيانات التسجيل الجديد في جدول profiles فوراً
              final supabaseClient = Supabase.instance.client;
              final currentUser = supabaseClient.auth.currentUser;
              if (currentUser != null) {
                await supabaseClient.from('profiles').upsert({
                  'id': currentUser.id,
                  'full_name': fullName,
                  'email': email,
                  if (phone != null && phone.isNotEmpty) 'phone': phone,
                  'updated_at': DateTime.now().toIso8601String(),
                });
              }
            } catch (e) {
              debugPrint("⚠️ خطأ أثناء إنشاء صف الـ profiles لليوزر الجديد: $e");
            }
            emit(AuthAuthenticated(user));
          } else {
            signIn(email: email, password: password);
          }
        },
      );
    } catch (e, s) {
      debugPrint('AuthCubit.signUp exception: ${e.toString()}');
      debugPrint('Stack trace: ${s.toString()}');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyEmail({required String email, required String otp}) async {
    debugPrint('AuthCubit.verifyEmail called for $email with OTP $otp');
    emit(AuthLoading());

    final result = await sl<AuthRepository>().verifyEmail(email: email, otp: otp);

    result.fold(
      (error) {
        debugPrint('AuthCubit.verifyEmail failed: $error');
        emit(AuthError(error));
      },
      (_) {
        debugPrint('AuthCubit.verifyEmail success');
        emit(AuthEmailVerified(email));
      },
    );
  }

  Future<void> resendVerificationEmail(String email) async {
    debugPrint('AuthCubit.resendVerificationEmail called for $email');
    emit(AuthLoading());

    final result = await sl<AuthRepository>().resendOtp(email);

    result.fold(
      (error) {
        debugPrint('AuthCubit.resendVerificationEmail failed: $error');
        emit(AuthError(error));
      },
      (_) {
        debugPrint('AuthCubit.resendVerificationEmail success');
        emit(AuthConfirmationResent(email));
      },
    );
  }

  Future<void> signOut() async {
    emit(AuthLoading());

    final result = await signOutUsecase(const NoParams());

    result.fold(
      (error) => emit(AuthError(error)),
      (_) {
        _preferencesHelper?.clearAuthToken();
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());

    final result = await resetPasswordUsecase(email);

    result.fold(
      (error) => emit(AuthError(error)),
      (_) => emit(AuthPasswordResetSent(email)),
    );
  }

  void clearError() {
    if (state is AuthError || state is AuthFailure) {
      emit(AuthUnauthenticated());
    }
  }
}