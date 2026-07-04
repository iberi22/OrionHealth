import 'package:flutter/material.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GlassmorphicCard(
          child: Column(
            children: ListTile.divideTiles(
              context: context,
              tiles: children,
              color: Colors.white.withValues(alpha: 0.1),
            ).toList(),
          ),
        ),
      ],
    );
  }
}
