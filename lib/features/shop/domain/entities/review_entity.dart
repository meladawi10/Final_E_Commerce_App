import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        userName,
        userAvatarUrl,
        rating,
        comment,
        createdAt,
        updatedAt,
      ];
}