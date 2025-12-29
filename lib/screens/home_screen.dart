import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_theme.dart';
import 'main_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Fashion Enthusiast';
  String _userEmail = 'user@stylx.com';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Fashion Enthusiast';
        _userEmail = prefs.getString('user_email') ?? 'user@stylx.com';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Static Background Gradient (instead of scrolling images)
          // Rich Background
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1080&auto=format&fit=crop&q=80',
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(color: AppTheme.background),
                  errorWidget: (c, u, e) =>
                      Container(color: AppTheme.background),
                ),
                // Gradient Overlay for readability and theme tint
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.background.withOpacity(0.7),
                        AppTheme.background.withOpacity(0.9),
                        AppTheme.background,
                      ],
                    ),
                  ),
                ),
                // Subtle added tint
                Container(
                  color: AppTheme.primary.withOpacity(0.05),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppTheme.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'OM',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .scale(duration: 800.ms, curve: Curves.fastOutSlowIn),
                    const SizedBox(height: 32),
                    Text(
                      'Outfit Matcher',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 12),
                    Text(
                      'Your AI-Powered Personal Stylist',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () {
                        // Switch to Shop Tab (Index 1) from Home
                        MainLayout.switchTab(context, 1);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: AppTheme.primaryGradient),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          child: const Text(
                            'Explore Outfits',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).scale(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Switch to Wardrobe Tab (Index 2)
                        MainLayout.switchTab(context, 2);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'My Digital Wardrobe',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ).animate().fadeIn(delay: 900.ms).scale(),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/upload'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(color: Colors.white24, width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Upload Your Style',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ).animate().fadeIn(delay: 1000.ms).scale(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.primaryGradient),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_userName)}&background=000&color=fff&size=150&bold=true'),
            ),
            accountName: Text(_userName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(_userEmail),
          ),
          _buildDrawerItem(context, Icons.home_outlined, 'Home',
              () => Navigator.pop(context)),
          _buildDrawerItem(context, Icons.explore_outlined, 'Shop Trends', () {
            Navigator.pop(context);
            MainLayout.switchTab(context, 1);
          }),
          _buildDrawerItem(context, Icons.favorite_border, 'My Wardrobe', () {
            Navigator.pop(context);
            MainLayout.switchTab(context, 2);
          }),
          _buildDrawerItem(context, Icons.auto_awesome_outlined, 'AI Analyzer',
              () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/analyzer');
          }),
          _buildDrawerItem(context, Icons.shopping_bag_outlined, 'My Cart', () {
            Navigator.pop(context);
            MainLayout.switchTab(context, 3);
          }),
          const Spacer(),
          // THEME TOGGLE
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: AppTheme.primary),
                title: const Text('Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (val) => themeProvider.toggleTheme(),
                  activeThumbColor: AppTheme.primary,
                ),
              );
            },
          ),
          const Divider(color: Colors.white10),
          _buildDrawerItem(context, Icons.logout, 'Logout', () {
            Navigator.pushReplacementNamed(context, '/');
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
