import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'butterfly_info.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _butterflies = [];
  List<Map<String, dynamic>> _filtered = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadButterflies();
  }

  Future<void> _loadButterflies() async {
    final String data = await rootBundle.loadString('assets/butterflies.json');
    final Map<String, dynamic> jsonResult = json.decode(data);
    setState(() {
      _butterflies = jsonResult.entries
          .map(
            (e) => {
              'Common Name': e.key,
              ...Map<String, dynamic>.from(e.value as Map),
            },
          )
          .toList();
      _filtered = _butterflies;
    });
  }

  void _updateQuery(String query) {
    setState(() {
      _query = query;
      _filtered = _butterflies
          .where(
            (item) => item['Common Name'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  void _openDetail(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ButterflyDetailPage(commonName: name)),
    );
  }

  Widget _buildButterflyCard(Map<String, dynamic> item) {
    final imagePath =
        item['image']?.toString().replaceFirst(
          'assets/images/',
          'assets/butterflies/',
        ) ??
        '';
    final name = item['Common Name'] ?? '';

    return GestureDetector(
      onTap: () => _openDetail(name),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 100),
                ),
              )
            else
              const Icon(Icons.image, size: 100),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _query.isEmpty ? _butterflies : _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text("Search Butterflies")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Enter butterfly name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _updateQuery,
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text("No results found."))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildButterflyCard(list[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
