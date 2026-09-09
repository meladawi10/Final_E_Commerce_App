import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/local_preferences_helper.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/on_boarding_view.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // الانتظار لمدة ثانيتين قبل التوجيه
    await Future.delayed(const Duration(seconds: 2), () {});
    if (!mounted) return;

    final prefs = sl<LocalPreferencesHelper>();
    final hasSeenOnboarding = prefs.hasSeenOnboarding;

    // ⚠️ التحقق من السيشن الحقيقية بتاعة Supabase، مش التوكن المحلي
    // التوكن المحلي ممكن يكون قديم/غير متزامن، فمينفعش نعتمد عليه لوحده
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    debugPrint(
        "🔍 [Splash] hasSeenOnboarding: $hasSeenOnboarding | isLoggedIn (Supabase session): $isLoggedIn");

    Widget nextScreen;
    if (!hasSeenOnboarding) {
      nextScreen = const OnBoardingView();
    } else if (isLoggedIn) {
      nextScreen = const NavigationMenu();
    } else {
      // مفيش سيشن حقيقية → تسجيل الدخول إجباري
      nextScreen = const LoginView();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 👈 خلفية بيضاء ثابتة دائماً
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logos/splashscreen.jpg',
              width: 280,
              height: 280,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  'NEXORA',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}