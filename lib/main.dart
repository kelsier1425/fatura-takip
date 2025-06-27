import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'config/supabase/supabase_config.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize locale data for Turkish
  await initializeDateFormatting('tr', null);
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(
    const ProviderScope(
      child: FaturaTakipApp(),
    ),
  );
}

class FaturaTakipApp extends ConsumerStatefulWidget {
  const FaturaTakipApp({Key? key}) : super(key: key);
  
  @override
  ConsumerState<FaturaTakipApp> createState() => _FaturaTakipAppState();
}

class _FaturaTakipAppState extends ConsumerState<FaturaTakipApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    ref.read(themeProvider.notifier).updateSystemBrightness(brightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.materialThemeMode,
      routerConfig: AppRouter.createRouter(ref),
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
