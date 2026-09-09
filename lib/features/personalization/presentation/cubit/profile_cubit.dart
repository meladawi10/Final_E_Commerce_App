import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> getProfile() async {
    debugPrint("🔥 جاري جلب بيانات البروفايل...");

    if (isClosed) return;
    emit(ProfileLoading());

    try {
      // 1. جلب المستخدم الحالي من سوبابيس
      final User? currentUser = _supabase.auth.currentUser;

      debugPrint("👤 currentUser: ${currentUser?.id} | email: ${currentUser?.email}");

      // لو مفيش يوزر مسجل دخول، دي مشكلة حقيقية لازم تتحل من الـ Auth
      // مش هنعرض بيانات وهمية، هنبعت حالة Error واضحة
      if (currentUser == null) {
        debugPrint("🚨 لا يوجد مستخدم مسجل الدخول (currentUser == null). تأكد من أن تسجيل الدخول تم بنجاح وأن السيشن محفوظة.");
        if (!isClosed) {
          emit(const ProfileError('لا يوجد جلسة مستخدم نشطة. الرجاء تسجيل الدخول مرة أخرى.'));
        }
        return;
      }

      // 2. جلب بيانات البروفايل من جدول profiles
      Map<String, dynamic>? profileData;
      try {
        profileData = await _supabase
            .from('profiles')
            .select()
            .eq('id', currentUser.id)
            .maybeSingle();

        debugPrint("📦 profileData من جدول profiles: $profileData");
      } catch (e) {
        debugPrint("⚠️ خطأ في الاستعلام عن جدول profiles: $e");
      }

      // لو الصف مش موجود في جدول profiles أصلاً، دي إشارة إن الـ trigger
      // بتاع إنشاء البروفايل بعد التسجيل مش شغال، أو الـ id مش متطابق
      if (profileData == null) {
        debugPrint(
            "⚠️ تحذير: لا يوجد صف في جدول profiles للمستخدم ذو id = ${currentUser.id}. سيتم استخدام بيانات auth.users كبديل.");
      }

      // 3. بناء البيانات: profiles أولاً، بعدين auth metadata، من غير أي قيمة ثابتة يدوي
      final String name = (profileData?['full_name'] as String?)?.trim().isNotEmpty == true
          ? profileData!['full_name']
          : (currentUser.userMetadata?['full_name'] as String?) ?? '';

      final String email = currentUser.email ?? '';

      final String phone = (profileData?['phone'] as String?) ?? currentUser.phone ?? '';

      final String avatar = (profileData?['avatar_url'] as String?) ??
          (currentUser.userMetadata?['avatar_url'] as String?) ??
          '';

      if (!isClosed) {
        emit(ProfileLoaded(ProfileUser(
          id: currentUser.id,
          email: email,
          fullName: name,
          phone: phone,
          avatarUrl: avatar,
        )));
      }
    } catch (e, stack) {
      debugPrint("🚨 خطأ أثناء جلب البروفايل: $e");
      debugPrint("$stack");
      if (!isClosed) {
        emit(ProfileError('حدث خطأ أثناء جلب بيانات البروفايل: $e'));
      }
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (isClosed) return;
    try {
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        emit(const ProfileError('لا يوجد جلسة مستخدم نشطة. لا يمكن تحديث البيانات.'));
        return;
      }

      final Map<String, dynamic> updateData = {};
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      if (updateData.isNotEmpty) {
        // upsert بدل update عشان لو الصف مش موجود أصلاً في profiles يتعمله insert
        await _supabase.from('profiles').upsert({
          'id': currentUser.id,
          ...updateData,
        });
      }

      await getProfile();
    } catch (e) {
      debugPrint("🚨 خطأ أثناء تحديث البروفايل: $e");
      if (!isClosed) {
        emit(ProfileError('حدث خطأ أثناء التحديث: $e'));
      }
    }
  }
}