import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_colors.dart';
import 'core/utils/logger.dart';
import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration
  AppConfig.setEnvironment(Environment.development);
  AppConfig.printConfig();

  // Initialize AdMob with error handling
  try {
    await MobileAds.instance.initialize();
    Logger.success('AdMob initialized successfully');
  } catch (e) {
    Logger.error('AdMob initialization failed', e);
    // Continue app execution even if AdMob fails
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    Logger.success('Supabase initialized successfully');
  } catch (e) {
    Logger.error('Supabase initialization failed', e);
  }

  // Call system will be initialized when user logs in

  runApp(const RomanticLoginApp());
}

class RomanticLoginApp extends StatefulWidget {
  const RomanticLoginApp({super.key});

  // Global navigation key for accessing navigator from anywhere
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Set current user ID for call service
  static void setCurrentUserIdForCalls(String userId) {
    print('📞 Call service configured for user: $userId');
  }

  @override
  State<RomanticLoginApp> createState() => _RomanticLoginAppState();
}

class _RomanticLoginAppState extends State<RomanticLoginApp> with WidgetsBindingObserver {
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed');
        break;
      case AppLifecycleState.paused:
        print('📱 App paused');
        break;
      case AppLifecycleState.detached:
        print('📱 App detached');
        break;
      case AppLifecycleState.inactive:
        print('📱 App inactive');
        break;
      case AppLifecycleState.hidden:
        print('📱 App hidden');
        break;
    }
  }

  // Setup incoming call callback
  void _setupIncomingCallCallback() {
    // CallManager handles incoming calls automatically
    print('📞 Incoming call callback setup complete');
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        navigatorKey:
            RomanticLoginApp.navigatorKey, // Add global navigation key
        theme: ThemeData(
          primarySwatch: Colors.pink,
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
    );
  }
}
