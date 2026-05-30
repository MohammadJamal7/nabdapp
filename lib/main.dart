import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/storage/storage_service.dart';
import 'core/api/api_client.dart';
import 'core/router/app_router.dart';
import 'core/signalr/signalr_service.dart';
import 'core/push/push_service.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await Firebase.initializeApp();
    await StorageService.init();
    ApiClient.init();
    if (StorageService.isAuthenticated) {
      SignalRService.connect();
    }
    PushService.init();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const ProviderScope(child: NabdApp()));
}

class NabdApp extends ConsumerStatefulWidget {
  const NabdApp({super.key});

  @override
  ConsumerState<NabdApp> createState() => _NabdAppState();
}

class _NabdAppState extends ConsumerState<NabdApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Nabd',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
