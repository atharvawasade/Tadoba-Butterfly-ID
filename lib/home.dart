import 'package:flutter/material.dart';
import 'classifier_page.dart';
import 'history.dart';
import 'search_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tadoba Butterfly ID"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/TATRlogoblack.png",
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),

            _buildTile(
              context,
              Icons.camera_alt_rounded,
              'Identify a Butterfly',
              const ClassifyPage(),
            ),

            const SizedBox(height: 16),

            _buildTile(context, Icons.history, 'History', const HistoryPage()),

            const SizedBox(height: 16),

            _buildTile(
              context,
              Icons.search_rounded,
              'Search Butterflies',
              const SearchPage(),
            ),

            const SizedBox(height: 16),

            _buildTile(
              context,
              Icons.info_outline,
              'About',
              null,
              isAbout: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('About This App'),
                    content: SingleChildScrollView(
                      child: Text.rich(
                        const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '🌿 Tadoba-Andhari Tiger Reserve (TATR) is committed to promoting nature education, especially among young minds. Through this app, TATR aims to foster curiosity, awareness, and appreciation for the incredible diversity of butterflies found in our forests.\n\n',
                            ),
                            TextSpan(
                              text:
                                  '🦋 Butterflies are not only beautiful insects but also important indicators of ecosystem health. Their presence, behavior, and diversity reflect the condition of the environment around us.\n\n',
                            ),
                            TextSpan(
                              text:
                                  '📱 This app lets you explore and identify butterfly species using visual patterns and colors, making learning fun and interactive for nature enthusiasts, students, and visitors.\n\n',
                            ),
                            TextSpan(
                              text:
                                  '🙏 Image and species data used in this app have been sourced from the ',
                            ),
                            TextSpan(
                              text: '"Butterflies of India"',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  ' project. We sincerely acknowledge and thank their team of researchers, photographers, and contributors for their incredible work in documenting India\'s butterfly diversity.\n\n',
                            ),
                            TextSpan(
                              text: 'Website: www.ifoundbutterflies.org \n',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.teal,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Developed by - \n Atharva Wasade \n Summer Intern, \n TATR, Chandrapur',
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String label,
    Widget? page, {
    bool isAbout = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        onPressed: isAbout
            ? onTap
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page!),
                );
              },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
