import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/cart_provider.dart';
import 'core/firebase_seeder.dart'; // Added here
import 'screens/onboarding_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/upload_style_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/shipping_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/upload_analyzer_screen.dart';
import 'screens/gender_choice_screen.dart';
import 'screens/main_layout.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Launch the UI INSTANTLY. Do not await anything here.
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  // We use a Future to track initialization state
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initApp();
  }

  Future<void> _initApp() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Run the seeder to ensure we have the 150 items
      FirebaseSeeder.seedData();
    } catch (e) {
      debugPrint("Firebase init error (ignored for UI safety): $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const OutfitMatcherApp(),
    );
  }
}

class OutfitMatcherApp extends StatelessWidget {
  const OutfitMatcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Outfit Matcher',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const OnboardingScreen(),
            '/home': (context) => const MainLayout(),
            '/catalog': (context) => const CatalogScreen(),
            '/upload': (context) => const UploadStyleScreen(),
            '/wardrobe': (context) => const WardrobeScreen(),
            '/cart': (context) => const CartScreen(),
            '/shipping': (context) => const ShippingScreen(),
            '/payment': (context) => const PaymentScreen(),
            '/confirmation': (context) => const ConfirmationScreen(),
            '/analyzer': (context) => const UploadAnalyzerScreen(),
            '/gender': (context) => const GenderChoiceScreen(),
          },
        );
      },
    );
  }
}
