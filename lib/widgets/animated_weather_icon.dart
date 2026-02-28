import 'package:flutter/material.dart';
import 'package:weather_app/utils/weather_utils.dart';

class AnimatedWeatherIcon extends StatefulWidget {
  final String condition;
  final bool isNight;
  final double size;

  const AnimatedWeatherIcon({
    super.key,
    required this.condition,
    this.isNight = false,
    this.size = 100,
  });

  @override
  State<AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<AnimatedWeatherIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getDuration(),
    )..repeat(reverse: _shouldReverse());
  }

  @override
  void didUpdateWidget(AnimatedWeatherIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.condition != widget.condition) {
      _controller.duration = _getDuration();
      _controller.repeat(reverse: _shouldReverse());
    }
  }

  Duration _getDuration() {
    switch (widget.condition.toLowerCase()) {
      case 'clear':
        return const Duration(seconds: 4);
      case 'clouds':
        return const Duration(seconds: 3);
      case 'rain':
      case 'drizzle':
        return const Duration(milliseconds: 1200);
      case 'thunderstorm':
        return const Duration(milliseconds: 2000);
      case 'snow':
        return const Duration(seconds: 5);
      default:
        return const Duration(seconds: 3);
    }
  }

  bool _shouldReverse() {
    return widget.condition.toLowerCase() != 'thunderstorm';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = WeatherUtils.getWeatherIcon(
      widget.condition,
      isNight: widget.isNight,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _buildIcon(icon),
    );
  }

  Widget _buildIcon(IconData icon) {
    final v = _controller.value;

    switch (widget.condition.toLowerCase()) {
      case 'clear':
        return Transform.rotate(
          angle: v * 0.5,
          child: Transform.scale(
            scale: 0.9 + v * 0.1,
            child: Icon(icon,
                size: widget.size,
                color: widget.isNight
                    ? Colors.white
                    : Color.lerp(Colors.amber, Colors.orange, v)),
          ),
        );

      case 'clouds':
        return Transform.translate(
          offset: Offset(v * 12 - 6, 0),
          child: Opacity(
            opacity: 0.75 + v * 0.25,
            child: Icon(icon, size: widget.size, color: Colors.white),
          ),
        );

      case 'rain':
      case 'drizzle':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: widget.size, color: Colors.lightBlueAccent),
            ...List.generate(3, (i) {
              final offset = (v + i * 0.33) % 1.0;
              return Positioned(
                bottom: widget.size * 0.05 + offset * widget.size * 0.3,
                left: widget.size * (0.25 + i * 0.2),
                child: Opacity(
                  opacity: (1 - offset).clamp(0.0, 0.7),
                  child: Icon(Icons.water_drop,
                      size: widget.size * 0.12,
                      color: Colors.lightBlueAccent.withOpacity(0.6)),
                ),
              );
            }),
          ],
        );

      case 'thunderstorm':
        final flash = v > 0.85;
        return Transform.scale(
          scale: flash ? 1.08 : 1.0,
          child: Icon(icon,
              size: widget.size,
              color: flash ? Colors.yellowAccent : Colors.white70),
        );

      case 'snow':
        return Transform.rotate(
          angle: v * 1.2,
          child: Transform.translate(
            offset: Offset(0, v * 5 - 2.5),
            child:
                Icon(icon, size: widget.size, color: Colors.white),
          ),
        );

      default:
        return Opacity(
          opacity: 0.8 + v * 0.2,
          child: Icon(icon, size: widget.size, color: Colors.white),
        );
    }
  }
}
