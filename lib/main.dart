import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/services/storage_service.dart';
import 'package:weather_app/screens/home_screen.dart';
import 'package:weather_app/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final seenOnboarding = await StorageService.hasSeenOnboarding();

  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider()..initialize(),
      child: MyApp(showOnboarding: !seenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Weather App',
          theme: ThemeData(
            useMaterial3: true,
            brightness:
                provider.isDarkMode ? Brightness.dark : Brightness.light,
            textTheme: GoogleFonts.poppinsTextTheme(
              provider.isDarkMode
                  ? ThemeData.dark().textTheme
                  : ThemeData.light().textTheme,
            ),
            colorSchemeSeed: provider.accentColor,
          ),
          home: showOnboarding
              ? const OnboardingScreen()
              : const HomeScreen(),
        );
      },
    );
  }
}
