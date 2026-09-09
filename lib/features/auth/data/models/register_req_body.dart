import 'package:equatable/equatable.dart';

class RegisterReqBody extends Equatable {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const RegisterReqBody({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      };

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}
