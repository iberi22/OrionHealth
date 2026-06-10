import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/models/research_result.dart';
import 'package:url_launcher/url_launcher.dart';

class ResearchResultCard extends StatelessWidget {
  final ResearchResult result;

  const ResearchResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSourceColor(result.source).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getSourceColor(result.source)),
                  ),
                  child: Text(
                    result.source.toUpperCase(),
                    style: TextStyle(
                      color: _getSourceColor(result.source),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (result.confidence > 0)
                  Text(
                    '${(result.confidence * 100).toInt()}% conf.',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result.title,
              style: const TextStyle(
                color: CyberTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _launchUrl(result.url),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('LEER MÁS'),
                  style: TextButton.styleFrom(
                    foregroundColor: CyberTheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'pubmed':
        return Colors.blueAccent;
      case 'fda':
        return Colors.orangeAccent;
      case 'who':
        return Colors.greenAccent;
      default:
        return CyberTheme.secondary;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
