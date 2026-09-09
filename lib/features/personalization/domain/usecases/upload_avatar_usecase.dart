import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/personalization/domain/repositories/profile_repository.dart';

class UploadAvatarUsecase implements UseCase<String, File> {
  final ProfileRepository repository;

  UploadAvatarUsecase(this.repository);

  @override
  Future<Either<String, String>> call(File imageFile) async {
    return await repository.uploadAvatar(imageFile);
  }
}