import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

// =========================
// Initial
// =========================

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

// =========================
// Loading
// =========================

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

// =========================
// Loaded
// =========================

class ProfileLoaded extends ProfileState {
  final ProfileUser user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

// =========================
// Updated
// =========================

class ProfileUpdated extends ProfileState {
  final ProfileUser user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

// =========================
// Error
// =========================

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// =========================
// Profile User
// =========================

class ProfileUser extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;

  const ProfileUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
  });

  factory ProfileUser.fromMap(Map<String, dynamic> map) {
    return ProfileUser(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? 'User',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      avatarUrl: map['avatar_url']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        avatarUrl,
      ];
}