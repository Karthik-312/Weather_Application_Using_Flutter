import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/utils/weather_utils.dart';

class TemperatureChart extends StatelessWidget {
  final List<dynamic> hourlyData;
  final String unit;

  const TemperatureChart({
    super.key,
    required this.hourlyData,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 0; i < hourlyData.length && i < 8; i++) {
      final temp = WeatherUtils.convertTemp(
        (hourlyData[i]['main']['temp'] as num).toDouble(),
        unit,
      );
      spots.add(FlSpot(i.toDouble(), temp));

      final time = DateTime.fromMillisecondsSinceEpoch(
        (hourlyData[i]['dt'] as num).toInt() * 1000,
      );
      labels.add(DateFormat.Hm().format(time));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 3;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 3;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.round()}°',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 ||
                      idx >= labels.length ||
                      value != idx.toDouble()) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFFFD700),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFFFD700).withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
