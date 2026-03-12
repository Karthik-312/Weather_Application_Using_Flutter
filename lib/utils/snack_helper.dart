import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';

class WeatherSnack {
  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.info_outline_rounded,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final provider = context.read<WeatherProvider>();
    final bgColor = isError
        ? const Color(0xFFE53935)
        : isSuccess
            ? const Color(0xFF43A047)
            : provider.accentColor;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: duration,
          elevation: 4,
        ),
      );
  }

  static void error(BuildContext context, String message) =>
      show(context, message,
          icon: Icons.error_outline_rounded, isError: true);

  static void success(BuildContext context, String message) =>
      show(context, message,
          icon: Icons.check_circle_outline_rounded, isSuccess: true);
}
