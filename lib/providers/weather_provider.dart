import 'package:flutter/material.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/services/location_service.dart';
import 'package:weather_app/services/storage_service.dart';
import 'package:weather_app/utils/weather_utils.dart';

class WeatherProvider extends ChangeNotifier {
  String _currentCity = 'Bangalore';
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecastData;
  Map<String, dynamic>? _airQualityData;
  List<String> _favoriteCities = [];
  String _temperatureUnit = 'C';
  bool _isLoading = true;
  String? _error;
  double? _lat;
  double? _lon;
  bool _isDarkMode = true;
  bool _isOfflineData = false;

  String get currentCity => _currentCity;
  Map<String, dynamic>? get currentWeather => _currentWeather;
  Map<String, dynamic>? get forecastData => _forecastData;
  Map<String, dynamic>? get airQualityData => _airQualityData;
  List<String> get favoriteCities => List.unmodifiable(_favoriteCities);
  String get temperatureUnit => _temperatureUnit;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get lat => _lat;
  double? get lon => _lon;
  bool get isDarkMode => _isDarkMode;
  bool get isOfflineData => _isOfflineData;

  bool get isFavorite => _favoriteCities.contains(_currentCity);

  String get currentCondition =>
      _currentWeather?['weather']?[0]?['main'] ?? 'Clear';

  bool get isNight {
    if (_currentWeather == null) return false;
    final sunrise = (_currentWeather!['sys']['sunrise'] as num).toInt();
    final sunset = (_currentWeather!['sys']['sunset'] as num).toInt();
    return WeatherUtils.isNightTime(sunrise, sunset);
  }

  List<Color> get weatherGradient =>
      WeatherUtils.getWeatherGradient(currentCondition, isNight);

  List<dynamic> get hourlyForecast {
    final list = _forecastData?['list'] as List<dynamic>?;
    return list?.take(8).toList() ?? [];
  }

  Map<String, List<dynamic>> get dailyForecast {
    if (_forecastData == null) return {};
    final list = _forecastData!['list'] as List<dynamic>;
    return WeatherUtils.groupForecastByDay(list);
  }

  int get aqi => _airQualityData?['list']?[0]?['main']?['aqi'] ?? 0;

  Map<String, dynamic> get aqiComponents =>
      _airQualityData?['list']?[0]?['components'] ?? {};

  // Rain countdown from forecast
  String? get rainCountdown {
    if (_forecastData == null) return null;
    final list = _forecastData!['list'] as List<dynamic>;
    for (var item in list) {
      final cond = item['weather'][0]['main'].toString().toLowerCase();
      if (cond == 'rain' || cond == 'drizzle' || cond == 'thunderstorm') {
        final dt = DateTime.fromMillisecondsSinceEpoch(
            (item['dt'] as num).toInt() * 1000);
        final diff = dt.difference(DateTime.now());
        if (diff.isNegative) continue;
        if (diff.inHours > 24) return null;
        if (diff.inHours > 0) {
          return 'Rain expected in ${diff.inHours}h ${diff.inMinutes % 60}m';
        }
        return 'Rain expected in ${diff.inMinutes}m';
      }
    }
    return null;
  }

  // Share text
  String getShareText() {
    if (_currentWeather == null) return '';
    final w = _currentWeather!;
    final tempC =
        ((w['main']['temp'] as num).toDouble() - 273.15).round();
    final feelsLike =
        ((w['main']['feels_like'] as num).toDouble() - 273.15).round();
    final condition = WeatherUtils.capitalizeWords(
        w['weather'][0]['description'] ?? '');
    final humidity = w['main']['humidity'];
    final wind = w['wind']['speed'];
    final pressure = w['main']['pressure'];

    return 'Weather in $_currentCity\n'
        'Temperature: ${tempC}°C (Feels like ${feelsLike}°C)\n'
        'Condition: $condition\n'
        'Humidity: $humidity%\n'
        'Wind: $wind m/s\n'
        'Pressure: $pressure hPa\n'
        '\n— Shared from Weather App';
  }

  Future<void> initialize() async {
    _temperatureUnit = await StorageService.loadUnit();
    _isDarkMode = await StorageService.loadDarkMode();
    _currentCity = await StorageService.loadLastCity();
    _favoriteCities = await StorageService.loadFavorites();
    await fetchWeather();
  }

  Future<void> fetchWeather() async {
    _isLoading = true;
    _error = null;
    _isOfflineData = false;
    notifyListeners();

    try {
      _currentWeather =
          await WeatherService.fetchCurrentWeather(_currentCity);
      _forecastData = await WeatherService.fetchForecast(_currentCity);

      _lat = (_currentWeather!['coord']['lat'] as num).toDouble();
      _lon = (_currentWeather!['coord']['lon'] as num).toDouble();

      if (_lat != null && _lon != null) {
        _airQualityData =
            await WeatherService.fetchAirQuality(_lat!, _lon!);
      }

      // Cache for offline use
      StorageService.cacheWeatherData(
          _currentCity, _currentWeather!, _forecastData!, _airQualityData);
      await StorageService.saveLastCity(_currentCity);
    } catch (e) {
      // Fallback to cached data
      final cached = await StorageService.loadCachedWeather(_currentCity);
      if (cached != null) {
        _currentWeather = cached['current'];
        _forecastData = cached['forecast'];
        _airQualityData = cached['airQuality'];
        _isOfflineData = true;
        _error = null;
      } else {
        _error = e.toString();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchCity(String city) async {
    _currentCity = city;
    await fetchWeather();
  }

  Future<List<Map<String, dynamic>>> searchCitySuggestions(
      String query) async {
    return await WeatherService.searchCities(query);
  }

  Future<void> useCurrentLocation() async {
    _isLoading = true;
    _error = null;
    _isOfflineData = false;
    notifyListeners();

    try {
      final position = await LocationService.getCurrentLocation();
      _lat = position.latitude;
      _lon = position.longitude;

      _currentWeather =
          await WeatherService.fetchCurrentWeatherByCoords(_lat!, _lon!);
      _forecastData =
          await WeatherService.fetchForecastByCoords(_lat!, _lon!);
      _airQualityData =
          await WeatherService.fetchAirQuality(_lat!, _lon!);

      _currentCity = _currentWeather!['name'] ?? 'Unknown';
      StorageService.cacheWeatherData(
          _currentCity, _currentWeather!, _forecastData!, _airQualityData);
      await StorageService.saveLastCity(_currentCity);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleFavorite() {
    if (_favoriteCities.contains(_currentCity)) {
      _favoriteCities.remove(_currentCity);
    } else {
      _favoriteCities.add(_currentCity);
    }
    StorageService.saveFavorites(_favoriteCities);
    notifyListeners();
  }

  void removeFavoriteCity(String city) {
    _favoriteCities.remove(city);
    StorageService.saveFavorites(_favoriteCities);
    notifyListeners();
  }

  void changeUnit(String unit) {
    _temperatureUnit = unit;
    StorageService.saveUnit(unit);
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    StorageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  String formatTemp(double tempK) {
    return '${WeatherUtils.convertTemp(tempK, _temperatureUnit).round()}°';
  }
}
