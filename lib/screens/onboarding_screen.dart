import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/services/storage_service.dart';
import 'package:weather_app/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.cloud_rounded,
      title: 'Real-Time Weather',
      description:
          'Get accurate, up-to-the-minute weather data for any city worldwide with animated weather icons and beautiful gradients.',
      gradient: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
    ),
    _OnboardingPage(
      icon: Icons.map_rounded,
      title: 'Interactive Weather Map',
      description:
          'Explore weather patterns globally with temperature, rain, cloud, wind, and pressure overlay maps. Tap anywhere for street-level data.',
      gradient: [Color(0xFF0f0c29), Color(0xFF302b63)],
    ),
    _OnboardingPage(
      icon: Icons.compare_arrows_rounded,
      title: 'Compare & Plan',
      description:
          'Compare weather between cities side by side. Plan trips with 5-day forecasts and smart packing suggestions.',
      gradient: [Color(0xFF373B44), Color(0xFF4286f4)],
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      title: 'Smart Features',
      description:
          'Moon phases, golden hour, activity suggestions, mood journaling, weather history, ambient sounds, and much more!',
      gradient: [Color(0xFF6a0572), Color(0xFF9C27B0)],
    ),
  ];

  void _completeOnboarding() async {
    await StorageService.setOnboardingSeen();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: page.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        TweenAnimationBuilder<double>(
                          key: ValueKey(index),
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: 0.6 + value * 0.4,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(page.icon,
                                size: 80, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Skip button
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text('Skip',
                            style: GoogleFonts.poppins(
                                color: Colors.white54, fontSize: 14)),
                      )
                    else
                      const SizedBox(width: 60),

                    const Spacer(),

                    // Page indicators
                    Row(
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? Colors.white
                                : Colors.white30,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Next/Done button
                    GestureDetector(
                      onTap: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          _currentPage < _pages.length - 1
                              ? 'Next'
                              : 'Get Started',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
