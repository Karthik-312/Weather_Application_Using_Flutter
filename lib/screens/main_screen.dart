import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/screens/home_screen.dart';
import 'package:weather_app/screens/favorites_screen.dart';
import 'package:weather_app/screens/compare_screen.dart';
import 'package:weather_app/screens/world_feed_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    FavoritesScreen(),
    CompareScreen(),
    WorldFeedScreen(),
  ];

  void navigateTo(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: _currentIndex,
            onTap: navigateTo,
            provider: provider,
          ),
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final WeatherProvider provider;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = provider.isDarkMode;
    final bg = isDark ? const Color(0xFF0A0E1A) : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favorites'),
      (Icons.compare_arrows_rounded, Icons.compare_arrows_rounded, 'Compare'),
      (Icons.public_rounded, Icons.public_outlined, 'World'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final (selectedIcon, unselectedIcon, label) = items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: selected
                                ? provider.accentColor.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            selected ? selectedIcon : unselectedIcon,
                            color: selected
                                ? provider.accentColor
                                : provider.secondaryTextColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? provider.accentColor
                                : provider.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
