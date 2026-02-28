import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:weather_app/air_quality_screen.dart';
import 'package:weather_app/air_quality_map.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  late Future<Map<String, dynamic>> airQuality;
  TextEditingController cityController = TextEditingController();
  String cityName = 'Bangalore';
  String selectedUnit = 'C';
  double? lat, lon;

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'City not found or API error';
      }

      lat = data['city']['coord']['lat'];
      lon = data['city']['coord']['lon'];
      airQuality = getAirQuality();

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getAirQuality() async {
    if (lat == null || lon == null) return {};

    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$airQualityAPIKey',
        ),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != null && data['cod'] != '200') {
        throw 'Air Quality API error';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  double convertTemperature(double tempK) {
    switch (selectedUnit) {
      case 'F':
        return (tempK - 273.15) * 9 / 5 + 32;
      case 'K':
        return tempK;
      case 'R':
        return (tempK - 273.15) * 4 / 5;
      default:
        return tempK - 273.15;
    }
  }

  Color getAQIColor(int aqi) {
    switch (aqi) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String describeAQICategory(int aqi) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'Enter City Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        if (cityController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter a city name")),
                          );
                          return;
                        }
                        setState(() {
                          cityName = cityController.text.trim();
                          weather = getCurrentWeather();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Weather for $cityName',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['C', 'F', 'K', 'R'].map((unit) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => selectedUnit = unit);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedUnit == unit
                              ? Colors.deepPurple
                              : Colors.white,
                          foregroundColor: selectedUnit == unit
                              ? Colors.white
                              : Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(unit),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                FutureBuilder(
                  future: weather,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator.adaptive());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }

                    final data = snapshot.data!;
                    final current = data['list'][0];
                    final currentTemp =
                        convertTemperature(current['main']['temp'])
                            .toStringAsFixed(1);
                    final currentSky = current['weather'][0]['main'];
                    final pressure = current['main']['pressure'].toString();
                    final wind = current['wind']['speed'].toString();
                    final humidity = current['main']['humidity'].toString();

                    final sunrise = DateTime.fromMillisecondsSinceEpoch(
                        data['city']['sunrise'] * 1000);
                    final sunset = DateTime.fromMillisecondsSinceEpoch(
                        data['city']['sunset'] * 1000);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          color: Colors.white.withOpacity(0.9),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text('$currentTemp °$selectedUnit',
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                const SizedBox(height: 16),
                                Icon(
                                  currentSky == 'Clouds' || currentSky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.wb_sunny,
                                  size: 64,
                                  color: Colors.orangeAccent,
                                ),
                                const SizedBox(height: 8),
                                Text(currentSky,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    AdditionalInfoItem(
                                        icon: Icons.wb_sunny,
                                        label: 'Sunrise',
                                        value: DateFormat.jm().format(sunrise)),
                                    AdditionalInfoItem(
                                        icon: Icons.nights_stay,
                                        label: 'Sunset',
                                        value: DateFormat.jm().format(sunset)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Hourly Forecast',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              final hour = data['list'][index];
                              final time = DateFormat.jm().format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      hour['dt'] * 1000));
                              final temp =
                                  convertTemperature(hour['main']['temp'])
                                      .toStringAsFixed(1);
                              final sky = hour['weather'][0]['main'];
                              final icon = sky == 'Clouds' || sky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.wb_sunny;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: HourlyForecastItem(
                                  time: time,
                                  temperature: '$temp°$selectedUnit',
                                  icon: icon,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AdditionalInfoItem(
                                icon: Icons.water_drop,
                                label: 'Humidity',
                                value: '$humidity%'),
                            AdditionalInfoItem(
                                icon: Icons.air,
                                label: 'Wind',
                                value: '$wind m/s'),
                            AdditionalInfoItem(
                                icon: Icons.speed,
                                label: 'Pressure',
                                value: '$pressure hPa'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        FutureBuilder(
                          future: airQuality,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError || snapshot.data == null) {
                              return const Text(
                                  'Failed to load air quality data',
                                  style: TextStyle(color: Colors.white));
                            }

                            final airData = snapshot.data!;
                            if (airData.isEmpty || airData['list'] == null) {
                              return const Text('No air quality data available',
                                  style: TextStyle(color: Colors.white));
                            }

                            final aqi = airData['list'][0]['main']['aqi'];
                            final components = airData['list'][0]['components'];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Air Quality',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                const SizedBox(height: 10),
                                Text(
                                  'Air Quality Index for $cityName: $aqi (${describeAQICategory(aqi)})',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: getAQIColor(aqi)),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AirQualityScreen(
                                            airQualityData: components),
                                      ),
                                    );
                                  },
                                  child: const Text('View Details'),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (lat != null && lon != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AirQualityMap(
                                              lat: lat!, lon: lon!),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Location not available")),
                                      );
                                    }
                                  },
                                  child: const Text('View Air Quality on Map'),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
