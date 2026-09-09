import 'package:dartz/dartz.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/local_preferences_helper.dart';
import 'package:t_store/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:t_store/features/auth/data/models/login_req_body.dart';
import 'package:t_store/features/auth/data/models/register_req_body.dart';
import 'package:t_store/features/auth/data/models/send_otp_req_body.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, UserEntity?>> getCurrentUser() async {
    try {
      final token = sl<LocalPreferencesHelper>().authToken;
      if (token == null || token.isEmpty) {
        return const Right(null);
      }
      return Right(UserEntity(
        id: token,
        email: 'meladawi6@gmail.com',
        fullName: 'Mohamed Mahmoud Moustafa',
      ));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        loginReqBody: LoginReqBody(email: email, password: password),
      );

      return result.fold(
        (error) => Left(error),
        (data) async {
          // ✨ حفظ التوكن محلياً فور نجاح تسجيل الدخول لكي يستقر النظام ولا يضيع الـ Session
          await sl<LocalPreferencesHelper>().setAuthToken(data.accessToken);

          return Right(UserEntity(
            id: data.accessToken,
            email: email,
            fullName: 'Mohamed Mahmoud Moustafa',
          ));
        },
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final nameParts = fullName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : fullName;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final result = await remoteDataSource.register(
        registerReqBody: RegisterReqBody(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        ),
      );

      return result.fold(
        (error) => Left(error),
        (_) => Right(UserEntity(
          id: '',
          email: email,
          fullName: fullName,
          phone: phone,
        )),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> verifyEmail({required String email, required String otp}) async {
    try {
      return await remoteDataSource.verifyEmail(email: email, otp: otp);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> resendOtp(String email) async {
    try {
      return await remoteDataSource.resendOtp(email: email);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> signInWithGoogle() async => const Right(false);

  @override
  Future<Either<String, bool>> signInWithFacebook() async => const Right(false);

  @override
  Future<Either<String, bool>> signInWithApple() async => const Right(false);

  @override
  Future<Either<String, void>> signOut() async {
    try {
      // مسح التوكن محلياً عند تسجيل الخروج
      await sl<LocalPreferencesHelper>().clearAuthToken();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> resetPassword(String email) async {
    try {
      final result = await remoteDataSource.sendOtp(
        forgetPasswordReqBody: SendOtpReqBody(email: email),
      );
      return result.fold(
        (error) => Left(error),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updatePassword(String newPassword) async {
    return const Right(null);
  }

  @override
  Future<Either<String, void>> resendConfirmation(String email) async {
    return const Right(null);
  }

  @override
  bool get isLoggedIn => sl<LocalPreferencesHelper>().authToken != null;

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(null);
}