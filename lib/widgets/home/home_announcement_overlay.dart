import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'announcement_card.dart';

class HomeAnnouncementOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final String content;

  final bool ignoreShownOnce; // 🔥 新增

  const HomeAnnouncementOverlay({
    super.key,
    required this.onClose,
    required this.content,
    this.ignoreShownOnce = false, // 🔥 默认 false（自动弹用）
  });

  @override
  State<HomeAnnouncementOverlay> createState() =>
      _HomeAnnouncementOverlayState();
}

class _HomeAnnouncementOverlayState extends State<HomeAnnouncementOverlay> {
  Timer? _timer;
  bool _shouldShow = true;

  @override
  void initState() {
    super.initState();
    _checkShouldShow();
  }

  Future<void> _checkShouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool("announcement_shown") ?? false;

    // 🔥 核心修改
    if (!widget.ignoreShownOnce && hasShown) {
      setState(() {
        _shouldShow = false;
      });
      widget.onClose();
      return;
    }

    // 只有自动弹才记录
    if (!widget.ignoreShownOnce) {
      await prefs.setBool("announcement_shown", true);
    }

    // 🔥 5秒自动关闭（手动查看也可以保留，没问题）
    _timer = Timer(const Duration(seconds: 5), () {
      widget.onClose();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.withValues(alpha: 0.6),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: () {},
            child: AnnouncementCard(
              content: widget.content,
              onClose: widget.onClose,
            ),
          ),
        ),
      ),
    );
  }
}
