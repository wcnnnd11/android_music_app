import 'package:flutter/material.dart';

class HomeErrorOverlay extends StatelessWidget {
  final String message;

  const HomeErrorOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
