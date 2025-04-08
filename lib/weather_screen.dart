import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  TextEditingController cityController = TextEditingController();
  String cityName = 'Bangalore';
  String selectedUnit = 'C';

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
        throw 'An unexpected error occurred';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
      backgroundColor: const Color.fromARGB(255, 245, 246, 244),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'Enter City Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      cityName = cityController.text;
                      weather = getCurrentWeather();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var unit in ['C', 'F', 'K', 'R'])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedUnit = unit;
                        });
                      },
                      child: Text(unit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedUnit == unit ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: weather,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  }

                  final data = snapshot.data!;
                  final currentWeatherData = data['list'][0];
                  final currentTemp =
                      convertTemperature(currentWeatherData['main']['temp'])
                          .toStringAsFixed(1);
                  final currentSky = currentWeatherData['weather'][0]['main'];
                  final currentPressure =
                      currentWeatherData['main']['pressure'].toString();
                  final currentWindSpeed =
                      currentWeatherData['wind']['speed'].toString();
                  final currentHumidity =
                      currentWeatherData['main']['humidity'].toString();

                  final sunrise = DateTime.fromMillisecondsSinceEpoch(
                      data['city']['sunrise'] * 1000);
                  final sunset = DateTime.fromMillisecondsSinceEpoch(
                      data['city']['sunset'] * 1000);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              '$currentTemp °$selectedUnit',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Icon(
                              currentSky == 'Clouds' || currentSky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.wb_sunny,
                              size: 64,
                              color: Colors.black87,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentSky,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // **Sunrise & Sunset (Darkened + Icons Added)**
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AdditionalInfoItem(
                                  icon: Icons.wb_sunny,
                                  label: 'Sunrise',
                                  value: DateFormat.jm().format(sunrise),
                                ),
                                AdditionalInfoItem(
                                  icon: Icons.nights_stay,
                                  label: 'Sunset',
                                  value: DateFormat.jm().format(sunset),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      // **Hourly Forecast**
                      const Text(
                        'Hourly Forecast',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Darkened Text
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            final hourlyData = data['list'][index];
                            final hourlyTime = DateFormat.jm().format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    hourlyData['dt'] * 1000));
                            final hourlyTemp =
                                convertTemperature(hourlyData['main']['temp'])
                                    .toStringAsFixed(1);
                            final hourlySky = hourlyData['weather'][0]['main'];
                            final hourlyIcon =
                                hourlySky == 'Clouds' || hourlySky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.wb_sunny;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: HourlyForecastItem(
                                time: hourlyTime,
                                temperature: '$hourlyTemp°$selectedUnit',
                                icon: hourlyIcon,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // **Additional Weather Info (Darkened + Icons)**
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInfoItem(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: '$currentHumidity%',
                          ),
                          AdditionalInfoItem(
                            icon: Icons.air,
                            label: 'Wind',
                            value: '$currentWindSpeed m/s',
                          ),
                          AdditionalInfoItem(
                            icon: Icons.speed,
                            label: 'Pressure',
                            value: '$currentPressure hPa',
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
