import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/weather?q=$city&appid=$openWeatherAPIKey'),
    );
    final data = jsonDecode(res.body);
    if (data['cod'] != 200) {
      throw data['message'] ?? 'Failed to fetch weather';
    }
    return data;
  }

  static Future<Map<String, dynamic>> fetchForecast(String city) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/forecast?q=$city&appid=$openWeatherAPIKey'),
    );
    final data = jsonDecode(res.body);
    if (data['cod'] != '200') {
      throw data['message'] ?? 'Failed to fetch forecast';
    }
    return data;
  }

  static Future<Map<String, dynamic>> fetchCurrentWeatherByCoords(
      double lat, double lon) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$openWeatherAPIKey'),
    );
    final data = jsonDecode(res.body);
    if (data['cod'] != 200) {
      throw data['message'] ?? 'Failed to fetch weather';
    }
    return data;
  }

  static Future<Map<String, dynamic>> fetchForecastByCoords(
      double lat, double lon) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$openWeatherAPIKey'),
    );
    final data = jsonDecode(res.body);
    if (data['cod'] != '200') {
      throw data['message'] ?? 'Failed to fetch forecast';
    }
    return data;
  }

  static Future<Map<String, dynamic>> fetchAirQuality(
      double lat, double lon) async {
    final res = await http.get(
      Uri.parse(
          '$_baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$openWeatherAPIKey'),
    );
    return jsonDecode(res.body);
  }
}
