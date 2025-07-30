import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ButterflyDetailPage extends StatefulWidget {
  final String commonName;
  final List<Map<String, dynamic>>? alternatives;
  final int? selectedIndex;

  const ButterflyDetailPage({
    super.key,
    required this.commonName,
    this.alternatives,
    this.selectedIndex,
  });

  @override
  State<ButterflyDetailPage> createState() => _ButterflyDetailPageState();
}

class _ButterflyDetailPageState extends State<ButterflyDetailPage> {
  bool translateToMarathi = false;

  Future<Map<String, dynamic>?> _loadButterflyInfo(String name) async {
    final String data = await rootBundle.loadString('assets/butterflies.json');
    final Map<String, dynamic> butterflies = json.decode(data);
    final cleanedName = name.split(' (')[0].trim();
    return butterflies.entries
        .firstWhere(
          (entry) =>
              entry.key.toLowerCase().trim() ==
              cleanedName.toLowerCase().trim(),
          orElse: () => MapEntry('', null),
        )
        .value;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.commonName.split(' (')[0];

    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadButterflyInfo(displayName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final butterfly = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(displayName),
            actions: [
              IconButton(
                icon: const Icon(Icons.translate),
                onPressed: () {
                  setState(() {
                    translateToMarathi = !translateToMarathi;
                  });
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (butterfly != null && butterfly['image'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      butterfly['image'].toString().replaceFirst(
                        'assets/images/',
                        'assets/butterflies/',
                      ),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Text("❌ Image not found"),
                    ),
                  ),
                const SizedBox(height: 20),

                if (butterfly != null) ...[
                  _infoCard(
                    '🦋 Common Name',
                    translateToMarathi &&
                            butterfly.containsKey('Common Name_MR')
                        ? butterfly['Common Name_MR']
                        : butterfly['Common Name'],
                  ),
                  _infoCard('🔬 Scientific Name', butterfly['Scientific Name']),
                  _infoCard(
                    '👁️ Appearance',
                    translateToMarathi && butterfly.containsKey('Appearance_MR')
                        ? butterfly['Appearance_MR']
                        : butterfly['Appearance'],
                  ),
                  _infoCard(
                    '📍 Location',
                    translateToMarathi && butterfly.containsKey('Locations_MR')
                        ? butterfly['Locations_MR']
                        : butterfly['Locations'],
                  ),
                  _infoCard(
                    '🦋 Behaviour',
                    translateToMarathi && butterfly.containsKey('Behavior_MR')
                        ? butterfly['Behavior_MR']
                        : butterfly['Behavior'],
                  ),
                  _infoCard(
                    '🌿 Habitat',
                    translateToMarathi && butterfly.containsKey('Habitat_MR')
                        ? butterfly['Habitat_MR']
                        : butterfly['Habitat'],
                  ),
                  _infoCard(
                    '🌱 Larval Host Plant',
                    translateToMarathi &&
                            butterfly.containsKey('Larval host plant_MR')
                        ? butterfly['Larval host plant_MR']
                        : butterfly['Larval host plant'],
                  ),
                  _infoCard(
                    '💡 Interesting Fact',
                    translateToMarathi &&
                            butterfly.containsKey('Interesting fact_MR')
                        ? butterfly['Interesting fact_MR']
                        : butterfly['Interesting fact'],
                  ),
                ] else ...[
                  const Text("No detailed data available."),
                ],

                const SizedBox(height: 24),

                if (widget.alternatives != null &&
                    widget.alternatives!.isNotEmpty) ...[
                  const Text(
                    "Can't find your butterfly?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < widget.alternatives!.length; i++)
                    Card(
                      color:
                          (widget.selectedIndex != null &&
                              i == widget.selectedIndex)
                          ? Colors.teal[50]
                          : null,
                      child: ListTile(
                        title: Text(widget.alternatives![i]['label']),
                        subtitle: Text(
                          'Confidence: ${(widget.alternatives![i]['confidence'] * 100).toStringAsFixed(2)}%',
                        ),
                        onTap: () {
                          if (widget.alternatives![i]['label'] !=
                              widget.commonName) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ButterflyDetailPage(
                                  commonName: widget.alternatives![i]['label'],
                                  alternatives: widget.alternatives,
                                  selectedIndex: i,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(fontSize: 20, color: Colors.teal)),
              const SizedBox(width: 4),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: "$title:\n",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: value?.toString() ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
