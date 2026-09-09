import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';

// المسارات الصحيحة بناءً على مكان الملفات في مشروعك:
import 'package:t_store/features/auth/presentation/widgets/login_header_section.dart';
import 'package:t_store/features/auth/presentation/widgets/login_form_section.dart';
import 'package:t_store/features/auth/presentation/widgets/sign_in_methods_section.dart';
import 'package:t_store/features/auth/presentation/widgets/divider_widget.dart';
import 'package:t_store/features/auth/presentation/views/signup/sign_up_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: TColors.light,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  const LoginHeaderSection(),
                  LoginFormSection(),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  const DividerWidget(
                    text: TTexts.orSignInWith,
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),

                  SignInMethodsSection(),

                  const SizedBox(height: TSizes.spaceBtwSections * 1.5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Create An Account ",
                        style: TextStyle(color: TColors.textSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          THelperFunctions.navigateToScreen(
                            context,
                            const SignUpView(),
                          );
                        },
                        child: const Text(
                          "Sign Up",
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
