import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  static Map<String, List<dynamic>> groupForecastByDay(
      List<dynamic> forecastList) {
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

  // ── Moon Phase ──

  static Map<String, dynamic> getMoonPhaseInfo(DateTime date) {
    final knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
    final diffDays =
        date.toUtc().difference(knownNewMoon).inSeconds / 86400.0;
    final cycles = diffDays / 29.530588853;
    final phase = cycles - cycles.floor();

    String name;
    String emoji;
    if (phase < 0.0625) {
      name = 'New Moon';
      emoji = '\u{1F311}';
    } else if (phase < 0.1875) {
      name = 'Waxing Crescent';
      emoji = '\u{1F312}';
    } else if (phase < 0.3125) {
      name = 'First Quarter';
      emoji = '\u{1F313}';
    } else if (phase < 0.4375) {
      name = 'Waxing Gibbous';
      emoji = '\u{1F314}';
    } else if (phase < 0.5625) {
      name = 'Full Moon';
      emoji = '\u{1F315}';
    } else if (phase < 0.6875) {
      name = 'Waning Gibbous';
      emoji = '\u{1F316}';
    } else if (phase < 0.8125) {
      name = 'Last Quarter';
      emoji = '\u{1F317}';
    } else if (phase < 0.9375) {
      name = 'Waning Crescent';
      emoji = '\u{1F318}';
    } else {
      name = 'New Moon';
      emoji = '\u{1F311}';
    }

    final illumination =
        (phase <= 0.5 ? phase * 2 : (1 - phase) * 2) * 100;

    return {
      'phase': phase,
      'name': name,
      'emoji': emoji,
      'illumination': illumination.round(),
    };
  }

  // ── Golden Hour ──

  static Map<String, String> getGoldenHour(
      int sunriseTimestamp, int sunsetTimestamp) {
    final sunrise =
        DateTime.fromMillisecondsSinceEpoch(sunriseTimestamp * 1000);
    final sunset =
        DateTime.fromMillisecondsSinceEpoch(sunsetTimestamp * 1000);
    final fmt = DateFormat.jm();
    return {
      'morningStart': fmt.format(sunrise),
      'morningEnd': fmt.format(sunrise.add(const Duration(hours: 1))),
      'eveningStart':
          fmt.format(sunset.subtract(const Duration(hours: 1))),
      'eveningEnd': fmt.format(sunset),
    };
  }

  // ── Day Length ──

  static String getDayLength(int sunriseTimestamp, int sunsetTimestamp) {
    final duration = sunsetTimestamp - sunriseTimestamp;
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  // ── Activity Suggestions ──

  static List<Map<String, dynamic>> getActivitySuggestions(
    String condition,
    double tempC,
    double windSpeed,
    double humidity,
    bool isNight,
  ) {
    final suggestions = <Map<String, dynamic>>[];
    final cond = condition.toLowerCase();

    if (cond == 'clear' && !isNight) {
      if (tempC > 15 && tempC < 35 && windSpeed < 8) {
        suggestions.add({
          'icon': Icons.hiking,
          'text': 'Great day for hiking or a nature walk',
          'color': const Color(0xFF4CAF50),
        });
      }
      if (tempC > 20 && tempC < 35) {
        suggestions.add({
          'icon': Icons.sports_soccer,
          'text': 'Perfect weather for outdoor sports',
          'color': const Color(0xFFFF9800),
        });
      }
      if (tempC > 28) {
        suggestions.add({
          'icon': Icons.pool,
          'text': 'Head to the pool or beach!',
          'color': const Color(0xFF2196F3),
        });
      }
      suggestions.add({
        'icon': Icons.camera_alt_rounded,
        'text': 'Perfect for photography',
        'color': const Color(0xFF9C27B0),
      });
    }

    if (cond == 'clouds' && !isNight && tempC > 10) {
      suggestions.add({
        'icon': Icons.directions_bike,
        'text': 'Nice cycling weather — no harsh sun',
        'color': const Color(0xFF009688),
      });
      suggestions.add({
        'icon': Icons.park,
        'text': 'Good day for a park visit',
        'color': const Color(0xFF4CAF50),
      });
    }

    if (cond == 'rain' || cond == 'drizzle') {
      suggestions.add({
        'icon': Icons.menu_book_rounded,
        'text': 'Perfect for reading or indoor hobbies',
        'color': const Color(0xFF795548),
      });
      suggestions.add({
        'icon': Icons.local_cafe,
        'text': 'Cozy up with hot coffee or tea',
        'color': const Color(0xFF8D6E63),
      });
      suggestions.add({
        'icon': Icons.movie_rounded,
        'text': 'Movie marathon day!',
        'color': const Color(0xFF607D8B),
      });
    }

    if (cond == 'thunderstorm') {
      suggestions.add({
        'icon': Icons.home_rounded,
        'text': 'Stay indoors — storms expected',
        'color': const Color(0xFFF44336),
      });
      suggestions.add({
        'icon': Icons.games_rounded,
        'text': 'Board games or video games',
        'color': const Color(0xFF3F51B5),
      });
    }

    if (cond == 'snow') {
      suggestions.add({
        'icon': Icons.snowboarding,
        'text': 'Perfect for snowboarding or skiing',
        'color': const Color(0xFF00BCD4),
      });
      suggestions.add({
        'icon': Icons.ac_unit,
        'text': 'Build a snowman!',
        'color': const Color(0xFF81D4FA),
      });
    }

    if (isNight && cond == 'clear') {
      suggestions.add({
        'icon': Icons.star_rounded,
        'text': 'Clear sky — great for stargazing',
        'color': const Color(0xFF311B92),
      });
    }

    if (windSpeed > 10) {
      suggestions.add({
        'icon': Icons.kitesurfing,
        'text': 'Windy! Try kite flying',
        'color': const Color(0xFF00ACC1),
      });
    }

    if (suggestions.isEmpty) {
      suggestions.add({
        'icon': Icons.self_improvement,
        'text': 'Good time for yoga or meditation',
        'color': const Color(0xFF7E57C2),
      });
    }

    return suggestions;
  }

  // ── Pressure Trend ──

  static String getPressureTrendLabel(double change) {
    if (change > 2) return 'Rising Fast';
    if (change > 0.5) return 'Rising';
    if (change < -2) return 'Falling Fast';
    if (change < -0.5) return 'Falling';
    return 'Stable';
  }

  static IconData getPressureTrendIcon(double change) {
    if (change > 0.5) return Icons.trending_up_rounded;
    if (change < -0.5) return Icons.trending_down_rounded;
    return Icons.trending_flat_rounded;
  }

  static Color getPressureTrendColor(double change) {
    if (change > 2) return const Color(0xFF4CAF50);
    if (change > 0.5) return const Color(0xFF8BC34A);
    if (change < -2) return const Color(0xFFF44336);
    if (change < -0.5) return const Color(0xFFFF9800);
    return const Color(0xFF2196F3);
  }

  // ── Weather Trivia ──

  static final List<String> weatherTrivia = [
    'A single cloud can weigh more than 1 million pounds.',
    'Lightning strikes Earth about 100 times every second.',
    'The highest temperature ever recorded was 56.7\u00B0C in Death Valley, California.',
    'Snowflakes can take up to 1 hour to fall to the ground.',
    'The lowest temperature ever recorded was -89.2\u00B0C in Antarctica.',
    'A hurricane releases the energy of 10,000 nuclear bombs per second.',
    'It rains diamonds on Jupiter and Saturn.',
    'The fastest wind speed ever recorded was 408 km/h during a tornado.',
    'Fog is actually a cloud that touches the ground.',
    'The driest place on Earth is the Atacama Desert in Chile.',
    'Raindrops are not tear-shaped — they look like hamburger buns.',
    'A bolt of lightning is 5 times hotter than the sun\'s surface.',
    'Mawsynram in India receives the most rainfall in the world.',
    'Earth\'s atmosphere weighs about 5.5 quadrillion tons.',
    'A single thunderstorm can produce 275 million gallons of water.',
    'Hailstones can travel at over 160 km/h.',
    'The coldest inhabited place is Oymyakon, Russia (-67.7\u00B0C).',
    'About 2,000 thunderstorms are happening on Earth at any time.',
    'Snowflakes always have six sides, but no two are alike.',
    'Red sunsets mean good weather is coming your way.',
    'Wind doesn\'t make a sound until it hits something.',
    'Petrichor is the name for the smell of rain on dry earth.',
    'Tornadoes can pick up and carry houses for miles.',
    'The eye of a hurricane is completely calm and clear.',
    'Cirrus clouds can travel at speeds over 160 km/h.',
    'Moonbows are rainbows caused by moonlight.',
    'Antarctica is technically a desert — it gets very little precipitation.',
    'Ball lightning is a rare glowing sphere seen during storms.',
    'The highest clouds are noctilucent clouds at 80 km altitude.',
    'A "sundog" is a bright spot beside the sun caused by ice crystals.',
  ];

  static String getRandomTrivia() {
    return weatherTrivia[Random().nextInt(weatherTrivia.length)];
  }
}
