import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/services/storage_service.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({super.key});

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen> {
  List<Map<String, dynamic>> _entries = [];
  String? _selectedMood;
  final _noteController = TextEditingController();

  static const List<Map<String, String>> _moods = [
    {'emoji': '\u{1F60A}', 'label': 'Happy'},
    {'emoji': '\u{1F610}', 'label': 'Neutral'},
    {'emoji': '\u{1F622}', 'label': 'Sad'},
    {'emoji': '\u{1F604}', 'label': 'Excited'},
    {'emoji': '\u{1F634}', 'label': 'Tired'},
    {'emoji': '\u{1F630}', 'label': 'Anxious'},
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await StorageService.loadMoodEntries();
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _logMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood first')),
      );
      return;
    }

    final provider = Provider.of<WeatherProvider>(context, listen: false);
    final weather = provider.currentWeather;

    final entry = {
      'mood': _selectedMood,
      'note': _noteController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
      'city': provider.currentCity,
      'temp': weather != null
          ? ((weather['main']['temp'] as num).toDouble() - 273.15).round()
          : null,
      'condition': weather?['weather']?[0]?['main'] ?? '',
    };

    await StorageService.saveMoodEntry(entry);
    _noteController.clear();
    setState(() => _selectedMood = null);
    await _loadEntries();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood logged!')),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Mood Journal',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: Colors.white54),
              tooltip: 'Clear all entries',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Journal?'),
                    content: const Text(
                        'This will delete all mood entries. This cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Clear',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await StorageService.clearMoodEntries();
                  _loadEntries();
                }
              },
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMoodInput(),
                const SizedBox(height: 28),
                if (_entries.isNotEmpty) ...[
                  Text('Past Entries',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  ..._entries.take(30).map(_buildEntryCard),
                ] else
                  _buildEmptyState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodInput() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How are you feeling?',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['label'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedMood = mood['label']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepPurple
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.deepPurpleAccent
                          : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(mood['emoji']!,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(mood['label']!,
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add a note (optional)...',
              hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 14),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: Text('Log Mood', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _logMood,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final mood = entry['mood'] ?? '';
    final note = entry['note'] ?? '';
    final timestamp = DateTime.tryParse(entry['timestamp'] ?? '');
    final city = entry['city'] ?? '';
    final temp = entry['temp'];
    final condition = entry['condition'] ?? '';
    final emoji = _moods
        .firstWhere((m) => m['label'] == mood,
            orElse: () => {'emoji': '\u{2753}', 'label': mood})['emoji']!;
    final weatherIcon =
        condition.isNotEmpty ? WeatherUtils.getWeatherIcon(condition) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(mood,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (timestamp != null)
                        Text(
                          DateFormat('MMM d, h:mm a').format(timestamp),
                          style: GoogleFonts.poppins(
                              color: Colors.white30, fontSize: 11),
                        ),
                    ],
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(note,
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 12)),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (weatherIcon != null) ...[
                        Icon(weatherIcon, color: Colors.white30, size: 14),
                        const SizedBox(width: 4),
                      ],
                      if (temp != null)
                        Text('$temp°C',
                            style: GoogleFonts.poppins(
                                color: Colors.white30, fontSize: 11)),
                      if (city.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.location_on_outlined,
                            color: Colors.white24, size: 12),
                        const SizedBox(width: 2),
                        Text(city,
                            style: GoogleFonts.poppins(
                                color: Colors.white24, fontSize: 11)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.book_rounded,
                size: 60, color: Colors.white.withOpacity(0.12)),
            const SizedBox(height: 12),
            Text('No entries yet',
                style: GoogleFonts.poppins(
                    color: Colors.white30, fontSize: 16)),
            Text('Log your mood to start tracking!',
                style: GoogleFonts.poppins(
                    color: Colors.white24, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
