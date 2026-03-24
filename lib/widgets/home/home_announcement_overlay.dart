import 'package:flutter/material.dart';

import 'announcement_card.dart';

class HomeAnnouncementOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final String content; // 🔥 新增

  const HomeAnnouncementOverlay({
    super.key,
    required this.onClose,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withValues(alpha: 0.6),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: () {},
            child: AnnouncementCard(
              content: content, // 🔥 传下去
              onClose: onClose,
            ),
          ),
        ),
      ),
    );
  }
}
