import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Text(
              'Favorite Cities',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: provider.primaryTextColor,
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: provider.backgroundGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: provider.favoriteCities.isEmpty
                  ? _buildEmptyState(provider)
                  : _buildFavoritesList(context, provider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(WeatherProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: provider.accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 56,
                color: provider.accentColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No favorites yet',
              style: GoogleFonts.poppins(
                color: provider.primaryTextColor,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the heart icon on the weather screen to save cities you care about.',
              style: GoogleFonts.poppins(
                color: provider.secondaryTextColor,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, WeatherProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: provider.favoriteCities.length,
      itemBuilder: (context, index) {
        final city = provider.favoriteCities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Semantics(
                label: 'City icon',
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: provider.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_city_rounded,
                      color: provider.accentColor, size: 22),
                ),
              ),
              title: Text(
                city,
                style: GoogleFonts.poppins(
                  color: provider.primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Tap to view weather',
                style: GoogleFonts.poppins(
                    color: provider.secondaryTextColor, fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'Load weather for $city',
                    child: IconButton(
                      icon: Icon(Icons.open_in_new_rounded,
                          color: provider.secondaryTextColor, size: 20),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        provider.searchCity(city);
                      },
                      tooltip: 'View weather',
                    ),
                  ),
                  Semantics(
                    label: 'Remove $city from favorites',
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent, size: 20),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        provider.removeFavoriteCity(city);
                      },
                      tooltip: 'Remove',
                    ),
                  ),
                ],
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                provider.searchCity(city);
              },
            ),
          ),
        );
      },
    );
  }
}
