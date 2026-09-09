import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String expiresAtUtc;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAtUtc,
  });

  String get token => accessToken;

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        expiresAtUtc,
      ];

  factory LoginResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresAtUtc: json['expiresAtUtc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAtUtc': expiresAtUtc,
    };
  }
}

typedef LoginUserData = LoginResponse;