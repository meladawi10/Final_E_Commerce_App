import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/localizations/app_localizations.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/utils/local_preferences_helper.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';

import 'package:t_store/features/personalization/presentation/cubit/profile_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_state.dart';
import 'package:t_store/features/personalization/presentation/view_models/profile_entity_tile_model.dart';
import 'package:t_store/features/personalization/presentation/widgets/personal_information_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/profile_information_section.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..getProfile(),
      child: const ProfileViewBody(),
    );
  }
}

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  File? _selectedImage;
  Uint8List? _webImageBytes;

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  User? get _currentUser {
    return Supabase.instance.client.auth.currentUser;
  }

  // ============================================================
  // PICK PROFILE IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final currentUser = _currentUser;

      if (currentUser == null) {
        _showSnackBar(
          'User is not logged in',
          Colors.red,
        );
        return;
      }

      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      // Preview immediately
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();

        if (mounted) {
          setState(() {
            _webImageBytes = bytes;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      }

      final bytes = await pickedFile.readAsBytes();

      final fileName =
          '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload image to Supabase Storage
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Get public URL
      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update profile
      await Supabase.instance.client
          .from('profiles')
          .update({
            'avatar_url': imageUrl,
          })
          .eq('id', currentUser.id);

      // Update Cubit state
      if (mounted) {
        await context.read<ProfileCubit>().updateProfile(
              avatarUrl: imageUrl,
            );

        _showSnackBar(
          'Profile picture updated successfully!',
          Colors.green,
        );
      }
    } on StorageException catch (e) {
      if (mounted) {
        _showSnackBar(
          'Storage error: ${e.message}',
          Colors.red,
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        _showSnackBar(
          'Database error: ${e.message}',
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Error updating picture: $e',
          Colors.red,
        );
      }
    }
  }

  // ============================================================
  // EDIT NAME
  // ============================================================

  void _showEditNameDialog(String currentName) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'name'.tr(context),
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();

                if (newName.isEmpty) {
                  return;
                }

                if (newName == currentName) {
                  Navigator.pop(dialogContext);
                  return;
                }

                Navigator.pop(dialogContext);

                try {
                  await context
                      .read<ProfileCubit>()
                      .updateProfile(
                        fullName: newName,
                      );

                  // Also update Supabase Auth metadata
                  await Supabase.instance.client.auth.updateUser(
                    UserAttributes(
                      data: {
                        'full_name': newName,
                      },
                    ),
                  );

                  if (mounted) {
                    _showSnackBar(
                      'Name updated successfully!',
                      Colors.green,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    _showSnackBar(
                      'Error updating name: $e',
                      Colors.red,
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
    String message,
    Color color,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      // Clear local token
      await sl<LocalPreferencesHelper>().clearAuthToken();

      // Logout from Supabase
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      THelperFunctions.navigateReplacementToScreen(
        context,
        const LoginView(),
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Logout failed: $e',
          Colors.red,
        );
      }
    }
  }

  // ============================================================
  // DEFAULT AVATAR
  // ============================================================

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildAvatar(String avatarUrl) {
    // Local web image preview
    if (kIsWeb && _webImageBytes != null) {
      return Image.memory(
        _webImageBytes!,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
      );
    }

    // Local mobile image preview
    if (!kIsWeb && _selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
      );
    }

    // Supabase avatar
    if (avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return _buildDefaultAvatar();
        },
      );
    }

    return _buildDefaultAvatar();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: CustomAppBar(
        appBarModel: AppBarModel(
          title: Text(
            'profile'.tr(context),
          ),
          hasArrowBack: true,
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            // ==================================================
            // LOADING
            // ==================================================

            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ==================================================
            // ERROR
            // ==================================================

            if (state is ProfileError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(
                    TSizes.defaultSpace,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: TSizes.spaceBtwItems,
                      ),
                      Text(
                        state.message,
                        style: const TextStyle(
                          color: TColors.error,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: TSizes.spaceBtwItems,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<ProfileCubit>()
                              .getProfile();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ==================================================
            // GET USER FROM CUBIT
            // ==================================================

            final user = state is ProfileLoaded
                ? state.user
                : state is ProfileUpdated
                    ? state.user
                    : null;

            // ==================================================
            // GET USER FROM SUPABASE AUTH
            // ==================================================

            final currentUser = _currentUser;

            // ==================================================
            // REAL DATA ONLY
            // ==================================================

            final String realName =
                user?.fullName?.trim().isNotEmpty == true
                    ? user!.fullName
                    : currentUser
                            ?.userMetadata?['full_name']
                            ?.toString() ??
                        'User';

            final String realEmail =
                user?.email?.trim().isNotEmpty == true
                    ? user!.email
                    : currentUser?.email ?? '';

            final String realId =
                user?.id?.trim().isNotEmpty == true
                    ? user!.id
                    : currentUser?.id ?? '';

            final String realPhone =
                user?.phone?.trim().isNotEmpty == true
                    ? user!.phone
                    : currentUser?.phone ?? '';

            final String avatarUrl =
                user?.avatarUrl?.trim().isNotEmpty == true
                    ? user!.avatarUrl
                    : currentUser
                            ?.userMetadata?['avatar_url']
                            ?.toString() ??
                        '';

            // ==================================================
            // PROFILE INFORMATION
            // ==================================================

            final List<ProfileEntityTileModel>
                profileInformation = [
              ProfileEntityTileModel(
                title: 'name'.tr(context),
                value: realName,
                onTap: () {
                  _showEditNameDialog(realName);
                },
              ),
              ProfileEntityTileModel(
                title: 'username'.tr(context),
                value: realEmail.isNotEmpty &&
                        realEmail.contains('@')
                    ? realEmail.split('@').first
                    : realName,
                trailing: null,
                onTap: () {
                  _showSnackBar(
                    'Username cannot be changed',
                    Colors.orange,
                  );
                },
              ),
            ];

            // ==================================================
            // PERSONAL INFORMATION
            // Gender & Date of Birth removed
            // ==================================================

            final List<ProfileEntityTileModel>
                personalInformation = [
              ProfileEntityTileModel(
                trailing: Iconsax.copy,
                title: 'user_id'.tr(context),
                value: realId.isNotEmpty
                    ? realId
                    : 'Not available',
                onTap: () {
                  if (realId.isEmpty) return;

                  Clipboard.setData(
                    ClipboardData(text: realId),
                  ).then((_) {
                    if (context.mounted) {
                      _showSnackBar(
                        'User ID copied!',
                        Colors.green,
                      );
                    }
                  });
                },
              ),
              ProfileEntityTileModel(
                title: 'email'.tr(context),
                value: realEmail.isNotEmpty
                    ? realEmail
                    : 'Not available',
                trailing: null,
                onTap: () {},
              ),
              ProfileEntityTileModel(
                title: 'phone_number'.tr(context),
                value: realPhone.isNotEmpty
                    ? realPhone
                    : 'not_registered'.tr(context),
                trailing: null,
                onTap: () {},
              ),
            ];

            // ==================================================
            // UI
            // ==================================================

            return RefreshIndicator(
              color: TColors.primary,
              backgroundColor:
                  isDark ? TColors.darkContainer : Colors.white,
              onRefresh: () async {
                await context
                    .read<ProfileCubit>()
                    .getProfile();
              },
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(
                    TSizes.defaultSpace,
                  ),
                  child: Column(
                    children: [
                      // ========================================
                      // PROFILE IMAGE
                      // ========================================

                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: _buildAvatar(
                                  avatarUrl,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _pickImage,
                              child: Text(
                                'change_picture'.tr(context),
                                style: const TextStyle(
                                  color: TColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: TSizes.spaceBtwItems,
                      ),

                      // ========================================
                      // PROFILE INFO
                      // ========================================

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'profile_info'.tr(context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: TSizes.spaceBtwItems,
                      ),

                      ProfileInformationSection(
                        profileInformation:
                            profileInformation,
                      ),

                      const SpaceBetweenSectionsWithDivider(),

                      // ========================================
                      // PERSONAL INFO
                      // ========================================

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'personal_info'.tr(context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: TSizes.spaceBtwItems,
                      ),

                      PersonalInformationSection(
                        personalInformation:
                            personalInformation,
                      ),

                      const SpaceBetweenSectionsWithDivider(),

                      const SizedBox(
                        height: TSizes.spaceBtwItems,
                      ),

                      // ========================================
                      // LOGOUT
                      // ========================================

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: TSizes.md,
                              horizontal: TSizes.md,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                TSizes.cardRadiusLg,
                              ),
                            ),
                          ),
                          onPressed: _logout,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Iconsax.logout,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(
                                width:
                                    TSizes.spaceBtwItems,
                              ),
                              Text(
                                'logout'.tr(context),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: TSizes.spaceBtwItems,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// SECTION DIVIDER
// ============================================================

class SpaceBetweenSectionsWithDivider
    extends StatelessWidget {
  const SpaceBetweenSectionsWithDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          height: TSizes.spaceBtwItems / 1.5,
        ),
        Divider(),
        SizedBox(
          height: TSizes.spaceBtwItems / 1.5,
        ),
      ],
    );
  }
}