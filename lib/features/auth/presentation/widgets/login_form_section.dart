import 'package:t_store/features/auth/presentation/views/signup/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/utils/validators/validation.dart';

import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';

import 'package:t_store/features/auth/presentation/views/password_configuration/forget_password_view.dart';
// استبدال HomeView بـ NavigationMenu لضمان ظهور الأزرار السفلية
import 'package:t_store/core/common/widgets/navigation_menu.dart';

class LoginFormSection extends StatefulWidget {
  const LoginFormSection({super.key});

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
            email: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text.trim(),
          );
    }
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: TColors.lightContainer,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: TColors.primary,
          width: 1,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      prefixIcon: Icon(
        icon,
        color: TColors.darkerGrey,
      ),

      suffixIcon: suffixIcon,

      labelText: label,

      labelStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),

      floatingLabelStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSessionEstablished || state is AuthAuthenticated) {
          THelperFunctions.showSnackBar(
            context: context,
            message: 'تم تسجيل الدخول بنجاح',
            type: SnackBarType.success,
          );

          THelperFunctions.navigateReplacementToScreen(
            context,
            const NavigationMenu(),
          );
        } else if (state is AuthEmailConfirmationRequired) {
          THelperFunctions.navigateToScreen(
            context,
            VerifyEmailView(email: state.email),
          );
        } else if (state is AuthFailure) {
          THelperFunctions.showSnackBar(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        } else if (state is AuthError) {
          THelperFunctions.showSnackBar(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },

      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.w600,
              ),
              validator: (value) =>
                  TValidator.validateEmail(value),
              decoration: _buildInputDecoration(
                TTexts.email,
                Iconsax.direct,
              ),
            ),

            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),

            // Password
            TextFormField(
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              obscureText: _obscurePassword,
              style: const TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.w600,
              ),
              validator: (value) =>
                  TValidator.validatePassword(value),
              onFieldSubmitted: (_) {
                if (context.read<AuthCubit>().state
                    is! AuthLoading) {
                  _handleLogin();
                }
              },
              decoration: _buildInputDecoration(
                TTexts.password,
                Iconsax.password_check,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                    color: TColors.darkerGrey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(
              height: TSizes.spaceBtwInputFields / 2,
            ),

            // Remember Me + Forgot Password
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: TColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text(
                      TTexts.rememberMe,
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                TextButton(
                  onPressed: () {
                    THelperFunctions.navigateToScreen(
                      context,
                      const ForgetPasswordView(),
                    );
                  },
                  child: const Text(
                    TTexts.forgetPassword,
                    style: TextStyle(
                      color: TColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: TSizes.spaceBtwSections,
            ),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthSubmitLoading || state is AuthLoading;

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            THelperFunctions.hideKeyboard();
                            _handleLogin();
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            TTexts.signIn,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}