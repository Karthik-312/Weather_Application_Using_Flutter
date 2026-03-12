import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Retry an HTTP call up to [maxRetries] times with exponential backoff.
  /// Delays: 500ms, 1s, 2s for attempts 1, 2, 3.
  static Future<T> _withRetry<T>(
    Future<T> Function() fn, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        final delay = Duration(milliseconds: (500 * pow(2, attempt - 1)).toInt());
        await Future<void>.delayed(delay);
      }
    }
  }

  static Future<Map<String, dynamic>> fetchCurrentWeather(String city) =>
      _withRetry(() async {
        final res = await http.get(
          Uri.parse('$_baseUrl/weather?q=$city&appid=$openWeatherAPIKey'),
        );
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['cod'] != 200) {
          throw data['message'] ?? 'Failed to fetch weather';
        }
        return data;
      });

  static Future<Map<String, dynamic>> fetchForecast(String city) =>
      _withRetry(() async {
        final res = await http.get(
          Uri.parse('$_baseUrl/forecast?q=$city&appid=$openWeatherAPIKey'),
        );
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['cod'] != '200') {
          throw data['message'] ?? 'Failed to fetch forecast';
        }
        return data;
      });

  static Future<Map<String, dynamic>> fetchCurrentWeatherByCoords(
          double lat, double lon) =>
      _withRetry(() async {
        final res = await http.get(Uri.parse(
            '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$openWeatherAPIKey'));
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['cod'] != 200) {
          throw data['message'] ?? 'Failed to fetch weather';
        }
        return data;
      });

  static Future<Map<String, dynamic>> fetchForecastByCoords(
          double lat, double lon) =>
      _withRetry(() async {
        final res = await http.get(Uri.parse(
            '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$openWeatherAPIKey'));
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['cod'] != '200') {
          throw data['message'] ?? 'Failed to fetch forecast';
        }
        return data;
      });

  static Future<Map<String, dynamic>> fetchAirQuality(
          double lat, double lon) =>
      _withRetry(() async {
        final res = await http.get(Uri.parse(
            '$_baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$openWeatherAPIKey'));
        return jsonDecode(res.body) as Map<String, dynamic>;
      });

  static Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final res = await http.get(Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct'
        '?q=$query&limit=5&appid=$openWeatherAPIKey',
      ));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data as List);
      }
    } catch (_) {}
    return [];
  }
}
