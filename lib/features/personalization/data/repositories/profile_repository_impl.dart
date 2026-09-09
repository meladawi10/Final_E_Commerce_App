import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/auth/data/models/user_model.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/personalization/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseService supabaseService;

  ProfileRepositoryImpl({required this.supabaseService});

  String? get _userId {
    final user = supabaseService.currentUser;
    if (user != null && user.id.isNotEmpty) {
      return user.id;
    }
    return supabaseService.client.auth.currentUser?.id;
  }

  @override
  Future<Either<String, UserEntity>> getProfile() async {
    try {
      String? userId = _userId;

      // لو الـ userId طلع فاضي، نصبر نصف ثانية عشان ندي فرصة للـ Session تحمل من الذاكرة المحلية
      if (userId == null || userId.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        userId = _userId;
      }

      if (userId == null || userId.isEmpty) {
        return const Left('يرجى تسجيل الدخول أولاً');
      }

      final response = await supabaseService.client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // Create profile if not exists
        final user = supabaseService.client.auth.currentUser;
        if (user == null) {
          return const Left('يرجى تسجيل الدخول أولاً');
        }

        final newProfile = await supabaseService.client
            .from(SupabaseTables.profiles)
            .insert({
              'id': userId,
              'email': user.email,
              'full_name': user.userMetadata?['full_name'],
              'phone': user.userMetadata?['phone'],
            })
            .select()
            .single();
        return Right(UserModel.fromJson(newProfile));
      }

      return Right(UserModel.fromJson(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    try {
      String? userId = _userId;
      if (userId == null || userId.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        userId = _userId;
      }

      if (userId == null || userId.isEmpty) {
        return const Left('يرجى تسجيل الدخول أولاً');
      }

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;

      if (updateData.isEmpty) {
        return getProfile();
      }

      final response = await supabaseService.client
          .from(SupabaseTables.profiles)
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return Right(UserModel.fromJson(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> uploadAvatar(File imageFile) async {
    try {
      String? userId = _userId;
      if (userId == null || userId.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        userId = _userId;
      }

      if (userId == null || userId.isEmpty) {
        return const Left('يرجى تسجيل الدخول أولاً');
      }

      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
      final bytes = await imageFile.readAsBytes();

      await supabaseService.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final avatarUrl = supabaseService.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update profile with new avatar URL
      await supabaseService.client
          .from(SupabaseTables.profiles)
          .update({'avatar_url': avatarUrl})
          .eq('id', userId);

      return Right(avatarUrl);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteAvatar() async {
    try {
      String? userId = _userId;
      if (userId == null || userId.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        userId = _userId;
      }

      if (userId == null || userId.isEmpty) {
        return const Left('يرجى تسجيل الدخول أولاً');
      }

      // Remove avatar URL from profile
      await supabaseService.client
          .from(SupabaseTables.profiles)
          .update({'avatar_url': null})
          .eq('id', userId);

      // Try to delete file from storage
      try {
        await supabaseService.client.storage
            .from('avatars')
            .remove(['avatar_$userId.jpg', 'avatar_$userId.png']);
      } catch (_) {
        // Ignore storage errors
      }

      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}