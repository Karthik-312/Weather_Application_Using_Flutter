# Weather App

A beautiful, feature-rich weather application built with Flutter. Get real-time weather data, 5-day forecasts, air quality monitoring, interactive weather maps, and smart suggestions — all wrapped in a stunning glassmorphism UI.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Features

### Core Weather
- **Real-time weather data** — current temperature, feels like, high/low, humidity, wind speed & direction, pressure, visibility
- **Hourly forecast** — 8-hour scrollable forecast with temperature and condition icons
- **5-day daily forecast** — daily high/low temps, precipitation probability, and color-coded temperature bars
- **Temperature unit switching** — Celsius, Fahrenheit, and Kelvin
- **Sunrise & sunset times**

### Air Quality
- **Air Quality Index (AQI)** — color-coded rating with descriptive labels (Good → Very Poor)
- **Pollutant breakdown** — detailed view of PM2.5, PM10, O₃, NO₂, SO₂, CO, NH₃, NO with progress bars
- **Health recommendations** — context-aware health tips based on AQI level

### Interactive Weather Map
- **Beautiful CartoDB dark base map** — clean, modern tile design
- **5 toggleable weather layers** — Temperature, Precipitation, Clouds, Wind, Pressure (powered by OpenWeatherMap tiles)
- **Tap anywhere for street-level weather** — get detailed weather data for any location on the map
- **Detailed bottom sheet** — shows full weather breakdown for the tapped location
- **Color-coded legend** — dynamic legend bar for the active weather layer

### Smart Features
- **GPS auto-detect location** — one-tap to get weather at your current position
- **Favorite cities** — save, manage, and quickly switch between your favorite cities
- **Smart suggestions** — clothing recommendations and activity tips based on weather conditions
- **Temperature trend chart** — line chart showing the temperature trajectory over the next hours
- **Persistent settings** — remembers your last city, temperature unit, and theme preference

### UI/UX
- **Glassmorphism design** — frosted-glass cards with backdrop blur throughout the app
- **Dynamic gradient backgrounds** — colors shift based on weather condition (clear, rain, snow, night, etc.)
- **Shimmer loading** — elegant skeleton loading animation while data is being fetched
- **Pull-to-refresh** — swipe down to refresh weather data
- **Smooth animations** — fade-in transitions, scale effects, and animated gradient changes
- **Google Fonts (Poppins)** — clean, modern typography
- **Dark / Light theme** — toggle from settings

---

## Screenshots

| Home Screen | Weather Map | Air Quality |
|:-----------:|:-----------:|:-----------:|
| Current weather, hourly & daily forecast | Tap any street for weather | Pollutant breakdown with health tips |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point with Provider setup
├── secrets.dart                       # API keys (not committed)
│
├── providers/
│   └── weather_provider.dart          # Centralized state management
│
├── services/
│   ├── weather_service.dart           # OpenWeatherMap API calls
│   ├── location_service.dart          # GPS location via Geolocator
│   └── storage_service.dart           # SharedPreferences persistence
│
├── screens/
│   ├── home_screen.dart               # Main weather screen with all sections
│   ├── weather_map_screen.dart        # Interactive weather map
│   ├── air_quality_screen.dart        # Detailed AQI with health recommendations
│   ├── favorites_screen.dart          # Saved cities management
│   └── settings_screen.dart           # Theme, units, and about
│
├── widgets/
│   ├── glass_container.dart           # Reusable glassmorphism container
│   └── temperature_chart.dart         # FL Chart temperature line chart
│
└── utils/
    └── weather_utils.dart             # Temperature conversion, icons, gradients, suggestions
```

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State Management | Provider |
| HTTP Client | http |
| Maps | flutter_map + CartoDB tiles |
| Weather Data | OpenWeatherMap API (free tier) |
| Charts | fl_chart |
| Location | Geolocator |
| Fonts | Google Fonts (Poppins) |
| Storage | SharedPreferences |
| Loading Effects | Shimmer |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.5`
- An [OpenWeatherMap API key](https://openweathermap.org/api) (free tier works)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Karthik-312/weather_app.git
   cd weather_app
   ```

2. **Add your API key**

   Create or edit `lib/secrets.dart`:
   ```dart
   const openWeatherAPIKey = 'YOUR_API_KEY_HERE';
   const String airQualityAPIKey = 'YOUR_API_KEY_HERE';
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Supported Platforms

- Android
- iOS
- Web (Chrome, Edge)
- Windows Desktop
- macOS
- Linux

---

## API Usage

This app uses the **OpenWeatherMap free tier** which includes:

| Endpoint | Purpose |
|----------|---------|
| `/data/2.5/weather` | Current weather by city or coordinates |
| `/data/2.5/forecast` | 5-day / 3-hour forecast |
| `/data/2.5/air_pollution` | Air quality index and pollutant data |
| `/map/{layer}/{z}/{x}/{y}.png` | Weather map tile overlays |

Free tier allows **1,000 API calls/day** — more than enough for personal use.

---

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is open source and available under the [MIT License](LICENSE).

---

## Acknowledgments

- [OpenWeatherMap](https://openweathermap.org/) — weather data API
- [CartoDB](https://carto.com/) — beautiful map base tiles
- [Flutter](https://flutter.dev/) — UI framework
- [fl_chart](https://pub.dev/packages/fl_chart) — charting library
- [flutter_map](https://pub.dev/packages/flutter_map) — map rendering
