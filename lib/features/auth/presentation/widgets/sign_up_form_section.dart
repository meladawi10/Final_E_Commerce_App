import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/utils/constants/colors.dart'; // تم إضافة ملف الألوان عشان ميطلعش إيرور
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/utils/validators/validation.dart';

import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';

import 'terms_and_privacy_agreement.dart';
import 'package:t_store/features/auth/presentation/views/signup/verify_email_view.dart';

class SignUpFormSection extends StatefulWidget {
  const SignUpFormSection({super.key});

  @override
  State<SignUpFormSection> createState() => _SignUpFormSectionState();
}

class _SignUpFormSectionState extends State<SignUpFormSection> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleRegistration() {
    debugPrint('SignUp: _handleRegistration called');
    final isValid = _formKey.currentState?.validate() ?? false;
    debugPrint('SignUp: Form validation result: $isValid');
    if (isValid) {
      debugPrint('SignUp: Triggering AuthCubit.signUp with email: ${_emailController.text}');
      context.read<AuthCubit>().signUp(
            email: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text.trim(),
            fullName:
                '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
            phone: _phoneController.text.trim(),
          );
    } else {
      debugPrint('SignUp: Form validation failed!');
      THelperFunctions.showSnackBar(
        context: context,
        message: 'Please fill in all required fields correctly',
        type: SnackBarType.error,
      );
    }
  }

  // الدالة دي المسئولة عن تظبيط شكل كل الخانات (اللون الأسود، الخلفية، والحدود)
  InputDecoration _buildInputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: TColors.lightContainer,
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      prefixIcon: Icon(icon, color: TColors.darkerGrey),
      suffixIcon: suffixIcon,
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
        borderSide: const BorderSide(color: TColors.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthEmailConfirmationRequired) {
          THelperFunctions.showSnackBar(
              context: context,
              message: 'تم إرسال رابط التأكيد إلى ${state.email}',
              type: SnackBarType.success);

          THelperFunctions.navigateReplacementToScreen(
              context, const LoginView());
        } else if (state is AuthError) {
          THelperFunctions.showSnackBar(
              context: context,
              message: state.message,
              type: SnackBarType.error);
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'First name is required'
                        : null,
                    decoration: _buildInputDecoration(TTexts.firstName, Iconsax.user),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwInputFields),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Last name is required' : null,
                    decoration: _buildInputDecoration(TTexts.lastName, Iconsax.user),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              validator: (value) {
                return TValidator.validateEmail(value);
              },
              decoration: _buildInputDecoration(TTexts.email, Iconsax.direct),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: _phoneController,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              validator: (value) => TValidator.validatePhoneNumber(value),
              decoration: _buildInputDecoration(TTexts.phoneNo, Iconsax.call),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              keyboardType: TextInputType.streetAddress,
              controller: _addressController,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Address is required' : null,
              decoration: _buildInputDecoration('Address', Iconsax.location),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              validator: (value) => TValidator.validatePassword(value),
              obscureText: _obscurePassword,
              decoration: _buildInputDecoration(
                TTexts.password,
                Iconsax.password_check,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                    color: TColors.darkerGrey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              keyboardType: TextInputType.visiblePassword,
              controller: _confirmPasswordController,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              validator: (value) => TValidator.validateConfirmPassword(
                  value, _passwordController), // تم التعديل هنا لتقبل الـ text صح
              obscureText: _obscurePassword,
              decoration: _buildInputDecoration('Confirm Password', Iconsax.password_check),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            
            const TermsAndPrivacyAgreement(),
            
            const SizedBox(height: TSizes.spaceBtwSections),
            
            SizedBox(
              width: double.infinity,
              height: 55, // نفس ارتفاع زرار الدخول
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthFailure) {
                    THelperFunctions.showSnackBar(
                      context: context,
                      message: state.message,
                      type: SnackBarType.error,
                    );
                  } else if (state is AuthEmailConfirmationRequired) {
                    THelperFunctions.navigateToScreen(
                      context,
                      VerifyEmailView(email: state.email),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthSubmitLoading || state is AuthLoading;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            THelperFunctions.hideKeyboard();
                            _handleRegistration();
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            TTexts.createAccount,
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