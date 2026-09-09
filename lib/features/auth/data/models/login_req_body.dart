import 'package:equatable/equatable.dart';

class LoginReqBody extends Equatable {
  final String email;
  final String password;

  const LoginReqBody({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
