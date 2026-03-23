import 'package:flutter/material.dart';

import '../../config/app_config.dart';

class AnnouncementCard extends StatelessWidget {
  final VoidCallback onClose;

  const AnnouncementCard({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: 420,
        maxHeight: screenHeight * 0.72,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                AppConfig.announcement,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 82,
            height: 34,
            child: TextButton(
              onPressed: onClose,
              style: TextButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('关闭'),
            ),
          ),
        ],
      ),
    );
  }
}
