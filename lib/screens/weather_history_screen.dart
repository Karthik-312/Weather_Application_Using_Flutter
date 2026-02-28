import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weather_app/services/storage_service.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';

class WeatherHistoryScreen extends StatefulWidget {
  const WeatherHistoryScreen({super.key});

  @override
  State<WeatherHistoryScreen> createState() => _WeatherHistoryScreenState();
}

class _WeatherHistoryScreenState extends State<WeatherHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _moodEntries = [];
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await StorageService.loadWeatherHistory();
    final moods = await StorageService.loadMoodEntries();
    if (mounted) {
      setState(() {
        _history = history;
        _moodEntries = moods;
        _isLoading = false;
      });
    }
  }

  Future<void> _exportData(String type) async {
    String csv;
    String label;
    if (type == 'weather') {
      csv = await StorageService.exportWeatherHistoryCSV();
      label = 'Weather History';
    } else {
      csv = await StorageService.exportMoodJournalCSV();
      label = 'Mood Journal';
    }

    try {
      await Share.share(csv, subject: '$label Export');
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: csv));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label data copied to clipboard!')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Data & History',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurpleAccent,
          labelStyle: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          tabs: const [
            Tab(text: 'Weather Log'),
            Tab(text: 'Mood Journal'),
          ],
        ),
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
          child: _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: Colors.white54))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWeatherHistory(),
                    _buildMoodHistory(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildWeatherHistory() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text('${_history.length} entries',
                  style: GoogleFonts.poppins(
                      color: Colors.white38, fontSize: 12)),
              const Spacer(),
              if (_history.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.download_rounded,
                      color: Colors.deepPurpleAccent, size: 16),
                  label: Text('Export CSV',
                      style: GoogleFonts.poppins(
                          color: Colors.deepPurpleAccent, fontSize: 12)),
                  onPressed: () => _exportData('weather'),
                ),
            ],
          ),
        ),
        Expanded(
          child: _history.isEmpty
              ? _emptyState('No weather history yet',
                  'Data will appear after your first fetch')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final e = _history[index];
                    final condition = (e['condition'] ?? '') as String;
                    final icon = condition.isNotEmpty
                        ? WeatherUtils.getWeatherIcon(condition)
                        : Icons.cloud_outlined;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon,
                                  color: Colors.white60, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${e['city'] ?? ''} — ${e['condition'] ?? ''}',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${e['date'] ?? ''} | ${e['humidity'] ?? ''}% humidity | ${e['wind'] ?? ''} m/s',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white30,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text('${e['temp'] ?? ''}°C',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300)),
                                Text('${e['pressure'] ?? ''} hPa',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white24,
                                        fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMoodHistory() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text('${_moodEntries.length} entries',
                  style: GoogleFonts.poppins(
                      color: Colors.white38, fontSize: 12)),
              const Spacer(),
              if (_moodEntries.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.download_rounded,
                      color: Colors.deepPurpleAccent, size: 16),
                  label: Text('Export CSV',
                      style: GoogleFonts.poppins(
                          color: Colors.deepPurpleAccent, fontSize: 12)),
                  onPressed: () => _exportData('mood'),
                ),
            ],
          ),
        ),
        Expanded(
          child: _moodEntries.isEmpty
              ? _emptyState('No mood entries yet',
                  'Log your mood from the Mood Journal screen')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _moodEntries.length,
                  itemBuilder: (context, index) {
                    final e = _moodEntries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text(_getMoodEmoji(e['mood'] ?? ''),
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(e['mood'] ?? '',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  if ((e['note'] ?? '').isNotEmpty)
                                    Text(e['note'],
                                        style: GoogleFonts.poppins(
                                            color: Colors.white38,
                                            fontSize: 11)),
                                  Text(
                                    '${e['city'] ?? ''} | ${e['temp'] ?? ''}°C | ${e['condition'] ?? ''}',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white24,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          Text(title,
              style: GoogleFonts.poppins(
                  color: Colors.white30, fontSize: 15)),
          Text(subtitle,
              style: GoogleFonts.poppins(
                  color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Happy':
        return '\u{1F60A}';
      case 'Neutral':
        return '\u{1F610}';
      case 'Sad':
        return '\u{1F622}';
      case 'Excited':
        return '\u{1F604}';
      case 'Tired':
        return '\u{1F634}';
      case 'Anxious':
        return '\u{1F630}';
      default:
        return '\u{2753}';
    }
  }
}
