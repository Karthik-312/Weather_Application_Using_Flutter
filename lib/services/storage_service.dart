import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _favoritesKey = 'favorite_cities';
  static const String _unitKey = 'temperature_unit';
  static const String _themeKey = 'is_dark_mode';
  static const String _lastCityKey = 'last_city';

  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  static Future<void> saveFavorites(List<String> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, cities);
  }

  static Future<String> loadUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_unitKey) ?? 'C';
  }

  static Future<void> saveUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitKey, unit);
  }

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? true;
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  static Future<String> loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCityKey) ?? 'Bangalore';
  }

  static Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, city);
  }

  // ── Offline Cache ──

  static Future<void> cacheWeatherData(
    String city,
    Map<String, dynamic> current,
    Map<String, dynamic> forecast,
    Map<String, dynamic>? airQuality,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_current_$city', jsonEncode(current));
    await prefs.setString('cache_forecast_$city', jsonEncode(forecast));
    if (airQuality != null) {
      await prefs.setString('cache_aqi_$city', jsonEncode(airQuality));
    }
    await prefs.setString(
        'cache_time_$city', DateTime.now().toIso8601String());
  }

  static Future<Map<String, Map<String, dynamic>?>?> loadCachedWeather(
      String city) async {
    final prefs = await SharedPreferences.getInstance();
    final currentStr = prefs.getString('cache_current_$city');
    final forecastStr = prefs.getString('cache_forecast_$city');
    if (currentStr == null || forecastStr == null) return null;

    final timeStr = prefs.getString('cache_time_$city');
    if (timeStr != null) {
      final cacheTime = DateTime.parse(timeStr);
      if (DateTime.now().difference(cacheTime).inHours > 6) return null;
    }

    final aqiStr = prefs.getString('cache_aqi_$city');
    return {
      'current': jsonDecode(currentStr) as Map<String, dynamic>,
      'forecast': jsonDecode(forecastStr) as Map<String, dynamic>,
      'airQuality':
          aqiStr != null ? jsonDecode(aqiStr) as Map<String, dynamic> : null,
    };
  }

  // ── Mood Journal ──

  static Future<List<Map<String, dynamic>>> loadMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('mood_entries');
    if (str == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(str));
  }

  static Future<void> saveMoodEntry(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadMoodEntries();
    entries.insert(0, entry);
    if (entries.length > 100) entries.removeLast();
    await prefs.setString('mood_entries', jsonEncode(entries));
  }

  static Future<void> clearMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mood_entries');
  }

  // ── Weather History ──

  static Future<List<Map<String, dynamic>>> loadWeatherHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('weather_history');
    if (str == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(str));
  }

  static Future<void> saveWeatherSnapshot(Map<String, dynamic> snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadWeatherHistory();

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final city = snapshot['city'] ?? '';
    history.removeWhere(
        (e) => (e['date'] ?? '') == today && (e['city'] ?? '') == city);

    history.insert(0, {...snapshot, 'date': today});
    if (history.length > 90) history.removeLast();
    await prefs.setString('weather_history', jsonEncode(history));
  }

  static Future<void> clearWeatherHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('weather_history');
  }

  // ── Pressure History ──

  static Future<List<Map<String, dynamic>>> loadPressureHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('pressure_history');
    if (str == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(str));
  }

  static Future<void> savePressureReading(int pressure, String city) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadPressureHistory();
    history.insert(0, {
      'pressure': pressure,
      'city': city,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (history.length > 48) history.removeLast();
    await prefs.setString('pressure_history', jsonEncode(history));
  }

  // ── Custom Accent Color ──

  static Future<int> loadAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('accent_color') ?? 0xFF6200EA;
  }

  static Future<void> saveAccentColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', colorValue);
  }

  // ── Onboarding ──

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seen_onboarding') ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
  }

  // ── Export ──

  static Future<String> exportMoodJournalCSV() async {
    final entries = await loadMoodEntries();
    final buf = StringBuffer('Date,Mood,Note,City,Temperature,Condition\n');
    for (final e in entries) {
      final date = e['timestamp'] ?? '';
      final mood = e['mood'] ?? '';
      final note = (e['note'] ?? '').toString().replaceAll(',', ';');
      final city = e['city'] ?? '';
      final temp = e['temp'] ?? '';
      final cond = e['condition'] ?? '';
      buf.writeln('$date,$mood,$note,$city,$temp,$cond');
    }
    return buf.toString();
  }

  static Future<String> exportWeatherHistoryCSV() async {
    final history = await loadWeatherHistory();
    final buf = StringBuffer(
        'Date,City,Temp(C),Condition,Humidity(%),Wind(m/s),Pressure(hPa)\n');
    for (final e in history) {
      buf.writeln(
          '${e['date']},${e['city']},${e['temp']},${e['condition']},${e['humidity']},${e['wind']},${e['pressure']}');
    }
    return buf.toString();
  }
}
