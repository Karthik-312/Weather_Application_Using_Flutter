import 'package:flutter/material.dart';

class WeatherUtils {
  static double convertTemp(double tempK, String unit) {
    switch (unit) {
      case 'F':
        return (tempK - 273.15) * 9 / 5 + 32;
      case 'K':
        return tempK;
      default:
        return tempK - 273.15;
    }
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  static IconData getWeatherIcon(String condition, {bool isNight = false}) {
    switch (condition.toLowerCase()) {
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'drizzle':
        return Icons.grain;
      case 'rain':
        return Icons.water_drop;
      case 'snow':
        return Icons.ac_unit;
      case 'clear':
        return isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded;
      case 'clouds':
        return isNight ? Icons.nights_stay_rounded : Icons.cloud;
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  static List<Color> getWeatherGradient(String condition, bool isNight) {
    if (isNight) {
      return [
        const Color(0xFF0f0c29),
        const Color(0xFF302b63),
        const Color(0xFF24243e),
      ];
    }
    switch (condition.toLowerCase()) {
      case 'clear':
        return [const Color(0xFF2193b0), const Color(0xFF6dd5ed)];
      case 'clouds':
        return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
      case 'rain':
      case 'drizzle':
        return [const Color(0xFF373B44), const Color(0xFF4286f4)];
      case 'thunderstorm':
        return [const Color(0xFF1a1a2e), const Color(0xFF16213e)];
      case 'snow':
        return [const Color(0xFFe6e9f0), const Color(0xFFeef1f5)];
      case 'mist':
      case 'fog':
      case 'haze':
        return [const Color(0xFF606c88), const Color(0xFF3f4c6b)];
      default:
        return [const Color(0xFF2193b0), const Color(0xFF6dd5ed)];
    }
  }

  static Color getAQIColor(int aqi) {
    switch (aqi) {
      case 1:
        return const Color(0xFF4CAF50);
      case 2:
        return const Color(0xFFFFC107);
      case 3:
        return const Color(0xFFFF9800);
      case 4:
        return const Color(0xFFF44336);
      case 5:
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  static String getAQILabel(int aqi) {
    switch (aqi) {
      case 1:
        return "Good";
      case 2:
        return "Fair";
      case 3:
        return "Moderate";
      case 4:
        return "Poor";
      case 5:
        return "Very Poor";
      default:
        return "Unknown";
    }
  }

  static String getAQIDescription(int aqi) {
    switch (aqi) {
      case 1:
        return "Air quality is satisfactory. Enjoy outdoor activities!";
      case 2:
        return "Acceptable air quality. Sensitive groups should limit prolonged outdoor exertion.";
      case 3:
        return "Members of sensitive groups may experience effects. Reduce outdoor exertion.";
      case 4:
        return "Everyone may experience health effects. Avoid prolonged outdoor exertion.";
      case 5:
        return "Health alert! Stay indoors and use air purifiers.";
      default:
        return "No data available.";
    }
  }

  static String getWindDirection(int degrees) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    int index = ((degrees / 22.5) + 0.5).floor() % 16;
    return directions[index];
  }

  static bool isNightTime(int sunriseUnix, int sunsetUnix) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now < sunriseUnix || now > sunsetUnix;
  }

  static Map<String, List<dynamic>> groupForecastByDay(List<dynamic> forecastList) {
    Map<String, List<dynamic>> grouped = {};
    for (var item in forecastList) {
      String date = (item['dt_txt'] as String).substring(0, 10);
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(item);
    }
    return grouped;
  }

  static List<Map<String, dynamic>> getWeatherSuggestions(
      String condition, double tempC) {
    List<Map<String, dynamic>> suggestions = [];

    if (tempC < 5) {
      suggestions.add({
        'icon': Icons.severe_cold,
        'text': 'Bundle up! Heavy winter clothing recommended.',
      });
    } else if (tempC < 15) {
      suggestions.add({
        'icon': Icons.checkroom,
        'text': 'Wear a warm jacket and layers.',
      });
    } else if (tempC < 25) {
      suggestions.add({
        'icon': Icons.dry_cleaning,
        'text': 'Light layers or a hoodie will do.',
      });
    } else if (tempC < 35) {
      suggestions.add({
        'icon': Icons.wb_sunny,
        'text': 'Light clothing. Stay hydrated!',
      });
    } else {
      suggestions.add({
        'icon': Icons.warning_amber,
        'text': 'Extreme heat! Stay indoors if possible.',
      });
    }

    switch (condition.toLowerCase()) {
      case 'clear':
        suggestions.add({
          'icon': Icons.directions_run,
          'text': 'Great weather for outdoor activities!',
        });
        if (tempC > 25) {
          suggestions.add({
            'icon': Icons.beach_access,
            'text': "Don't forget your sunscreen!",
          });
        }
        break;
      case 'clouds':
        suggestions.add({
          'icon': Icons.park,
          'text': 'Nice for a walk. No harsh sun!',
        });
        break;
      case 'rain':
      case 'drizzle':
        suggestions.add({
          'icon': Icons.umbrella,
          'text': 'Carry an umbrella when going out.',
        });
        suggestions.add({
          'icon': Icons.local_cafe,
          'text': 'Perfect weather for a cozy indoor day.',
        });
        break;
      case 'thunderstorm':
        suggestions.add({
          'icon': Icons.home,
          'text': 'Stay indoors. Thunderstorms expected!',
        });
        break;
      case 'snow':
        suggestions.add({
          'icon': Icons.snowboarding,
          'text': 'Snow day! Drive carefully on roads.',
        });
        break;
      default:
        suggestions.add({
          'icon': Icons.visibility,
          'text': 'Low visibility. Be cautious while driving.',
        });
    }
    return suggestions;
  }
}
