import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class AirQualityMap extends StatelessWidget {
  final double lat;
  final double lon;

  const AirQualityMap({super.key, required this.lat, required this.lon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 0,
        title: Text(
          'Air Quality Map',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(lat, lon),
          initialZoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            tileProvider: NetworkTileProvider(),
          ),
          TileLayer(
            urlTemplate:
                'https://tiles.aqicn.org/tiles/usepa-aqi/{z}/{x}/{y}.png?token=d4a717c01ae82f3e80ef8e357479ce91d2db1b14',
            subdomains: const ['a', 'b', 'c'],
            tileProvider: NetworkTileProvider(),
            tileBuilder: (context, tileWidget, tile) {
              return Opacity(opacity: 0.6, child: tileWidget);
            },
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: LatLng(lat, lon),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
