import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'butterfly_info.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, String>> _history = [];
  Map<String, dynamic> _butterflyData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final historyData = prefs.getStringList('butterfly_history') ?? [];
    final String jsonData = await rootBundle.loadString(
      'assets/butterflies.json',
    );
    final Map<String, dynamic> butterflyJson = json.decode(jsonData);

    setState(() {
      _history = historyData
          .map((e) => Map<String, String>.from(json.decode(e)))
          .toList();
      _butterflyData = butterflyJson;
    });
  }

  void _openDetail(Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ButterflyDetailPage(commonName: item['label']!),
      ),
    );
  }

  String? _getImagePath(String name) {
    final entry = _butterflyData.entries.firstWhere(
      (e) => e.key.toLowerCase().trim() == name.toLowerCase().trim(),
      orElse: () => const MapEntry('', null),
    );
    if (entry.value != null && entry.value['image'] != null) {
      return entry.value['image'].toString().replaceFirst(
        'assets/images/',
        'assets/butterflies/',
      );
    }
    return null;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy, HH:mm').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _history.isEmpty
          ? const Center(child: Text('No identifications yet.'))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final imgPath = _getImagePath(item['label']!);
                return Card(
                  child: ListTile(
                    leading: imgPath != null
                        ? Image.asset(
                            imgPath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.image),
                    title: Text(item['label'] ?? 'Unknown'),
                    subtitle: Text(_formatDate(item['date'])),
                    onTap: () => _openDetail(item),
                  ),
                );
              },
            ),
    );
  }
}

Future<void> addToHistory(String label, String imagePath) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> historyData =
      prefs.getStringList('butterfly_history') ?? [];

  final newItem = json.encode({
    'label': label,
    'imagePath': imagePath,
    'date': DateTime.now().toString(),
  });

  historyData.insert(0, newItem);
  await prefs.setStringList('butterfly_history', historyData);
}
