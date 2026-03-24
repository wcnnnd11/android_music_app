import 'package:flutter/material.dart';

class LaunchLoadingOverlay extends StatelessWidget {
  final ImageProvider image;

  const LaunchLoadingOverlay({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Image(image: image, fit: BoxFit.cover),
      ),
    );
  }
}

class OperatingLoadingOverlay extends StatelessWidget {
  const OperatingLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.35),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
