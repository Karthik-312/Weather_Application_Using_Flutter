import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/widgets/glass_container.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Favorite Cities',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0f0c29),
                  Color(0xFF302b63),
                  Color(0xFF24243e)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: provider.favoriteCities.isEmpty
                  ? _buildEmptyState()
                  : _buildFavoritesList(context, provider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded,
              size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            'No favorites yet',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Tap the heart icon on the weather screen to save your favorite cities.',
              style: GoogleFonts.poppins(
                  color: Colors.white30, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
      BuildContext context, WeatherProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.favoriteCities.length,
      itemBuilder: (context, index) {
        final city = provider.favoriteCities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_city_rounded,
                    color: Colors.white70, size: 22),
              ),
              title: Text(
                city,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Tap to view weather',
                style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded,
                        color: Colors.white54, size: 20),
                    onPressed: () {
                      provider.searchCity(city);
                      Navigator.pop(context);
                    },
                    tooltip: 'View weather',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 20),
                    onPressed: () => provider.removeFavoriteCity(city),
                    tooltip: 'Remove',
                  ),
                ],
              ),
              onTap: () {
                provider.searchCity(city);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}
