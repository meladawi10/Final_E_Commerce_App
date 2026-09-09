import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/widgets/divider_widget.dart';
import 'package:t_store/features/auth/presentation/widgets/sign_in_methods_section.dart';
import 'package:t_store/features/auth/presentation/widgets/sign_up_form_section.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: TColors.light, // خلفية بيضاء صريحة
        appBar: AppBar(
          backgroundColor: TColors.light,
          elevation: 0,
          iconTheme: const IconThemeData(color: TColors.textPrimary),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان بخط ضخم وعريض جداً
                  Text(
                    TTexts.signUpTitle, // "Create an account"
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                          color: TColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  const SignUpFormSection(),

                  const SizedBox(height: TSizes.spaceBtwSections),
                  const DividerWidget(text: TTexts.orSignUpWith),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  const SignInMethodsSection(),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  // جملة الانتقال لتسجيل الدخول تحت خالص
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already Have an Account? ",
                        style: TextStyle(color: TColors.textSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          THelperFunctions.navigateToScreen(
                            context,
                            const LoginView(),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: TColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: TColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
