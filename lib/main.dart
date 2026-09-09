import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/t_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تحميل ملف البيئة
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint(
      '⚠️ [DotEnv Error]: لم يتم العثور على ملف البيئة أو حدث خطأ في تحميله: $e',
    );
  }

  // 2. تهيئة Supabase
  await SupabaseService.initialize();

  // 3. التأكد من وجود Session
  try {
    final session = Supabase.instance.client.auth.currentSession;

    debugPrint(
      '🔍 [Auth Check at Startup] Current User ID: '
      '${session?.user.id ?? 'No Active Session'}',
    );
  } catch (e) {
    debugPrint('⚠️ [Auth Check Error]: $e');
  }

  // 4. تهيئة Dependency Injection
  await setupServiceLocator();

  // 5. تشغيل التطبيق
  runApp(const TStore());
}