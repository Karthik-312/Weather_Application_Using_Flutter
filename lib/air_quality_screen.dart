import 'package:flutter/material.dart';

class AirQualityScreen extends StatelessWidget {
  final Map<String, dynamic> airQualityData;

  const AirQualityScreen({Key? key, required this.airQualityData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: airQualityData.length,
          itemBuilder: (context, index) {
            String key = airQualityData.keys.elementAt(index);
            var value = airQualityData[key];
            return ListTile(
              title: Text(key),
              subtitle: Text(value.toString()),
            );
          },
        ),
      ),
    );
  }
}
