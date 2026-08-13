    import 'package:firebase_core/firebase_core.dart';
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:stallion_one/features/auth/presentation/pages/login_page.dart';
    import 'package:stallion_one/features/auth/presentation/pages/splash_page.dart';

    import 'firebase_options.dart';
    import 'features/auth/presentation/pages/signup_page.dart';
    import 'core/theme/app_theme.dart';

    Future<void> main() async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      runApp(
        const ProviderScope(
          child: StallionOneApp(),
        ),
      );
    }

    class StallionOneApp extends StatelessWidget {
      const StallionOneApp({super.key});

      @override
      Widget build(BuildContext context) {


        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,

          home: const SplashPage(),
        );
      }
    }