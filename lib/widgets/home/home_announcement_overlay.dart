import 'package:flutter/material.dart';

import 'announcement_card.dart';

class HomeAnnouncementOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const HomeAnnouncementOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: AnnouncementCard(onClose: onClose),
      ),
    );
  }
}
