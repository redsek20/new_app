import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'home_screen.dart';
import 'gender_choice_screen.dart';
import 'wardrobe_screen.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'upload_style_screen.dart';
import 'upload_analyzer_screen.dart';
import '../core/app_theme.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  // Static method to allow children to switch tabs
  static void switchTab(BuildContext context, int index) {
    // We use the public state class now
    final state = context.findAncestorStateOfType<MainLayoutState>();
    state?.changeTab(index);
  }

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Navigator keys to maintain state of each tab
  final GlobalKey<NavigatorState> _homeKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _shopKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _wardrobeKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _cartKey = GlobalKey<NavigatorState>();

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Pop to root if switching to Cart to ensure clean state
    if (index == 3) {
      _cartKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        // Handle physical back button for nested navigators
        final currentNavigator = [
          _homeKey,
          _shopKey,
          _wardrobeKey,
          _cartKey,
        ][_selectedIndex]
            .currentState;

        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
          return false;
        }

        // If on another tab, go to Home
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBody: true, // Transparent functionality
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            // Home Tab
            Navigator(
              key: _homeKey,
              onGenerateRoute: (settings) {
                if (settings.name == '/gender') {
                  return MaterialPageRoute(
                      builder: (_) => const GenderChoiceScreen());
                } else if (settings.name == '/catalog') {
                  return MaterialPageRoute(
                      builder: (_) => const CatalogScreen());
                } else if (settings.name == '/wardrobe') {
                  return MaterialPageRoute(
                      builder: (_) => const WardrobeScreen());
                } else if (settings.name == '/upload') {
                  return MaterialPageRoute(
                      builder: (_) => const UploadStyleScreen());
                } else if (settings.name == '/cart') {
                  return MaterialPageRoute(builder: (_) => const CartScreen());
                } else if (settings.name == '/analyzer') {
                  return MaterialPageRoute(
                      builder: (_) => const UploadAnalyzerScreen());
                }
                return MaterialPageRoute(builder: (_) => const HomeScreen());
              },
            ),
            // Shop Tab (Where flow is Gender -> Catalog)
            Navigator(
              key: _shopKey,
              onGenerateRoute: (settings) {
                if (settings.name == '/' || settings.name == null) {
                  return MaterialPageRoute(
                      builder: (_) => const GenderChoiceScreen());
                } else if (settings.name == '/cart') {
                  return MaterialPageRoute(builder: (_) => const CartScreen());
                }
                return MaterialPageRoute(builder: (_) => const CatalogScreen());
              },
            ),
            // Wardrobe Tab
            Navigator(
              key: _wardrobeKey,
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => const WardrobeScreen(),
              ),
            ),
            // Cart Tab
            Navigator(
              key: _cartKey,
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => const CartScreen(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(0.1),
              )
            ],
            // Glass border effect
            border: Border(
                top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05))),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                gap: 8,
                backgroundColor:
                    Colors.transparent, // Important for glass effect
                color: isDark ? Colors.white60 : Colors.black54,
                activeColor: isDark ? Colors.white : AppTheme.primary,
                tabBackgroundColor: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppTheme.primary.withOpacity(0.1),
                padding: const EdgeInsets.all(16),
                tabs: const [
                  GButton(icon: Icons.home_filled, text: 'Home'),
                  GButton(icon: Icons.manage_search_rounded, text: 'Shop'),
                  GButton(icon: Icons.checkroom_rounded, text: 'Wardrobe'),
                  GButton(icon: Icons.shopping_bag_rounded, text: 'Cart'),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  if (_selectedIndex == index) {
                    // If tapping active tab, pop to root
                    [_homeKey, _shopKey, _wardrobeKey, _cartKey][index]
                        .currentState
                        ?.popUntil((route) => route.isFirst);
                  }
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
