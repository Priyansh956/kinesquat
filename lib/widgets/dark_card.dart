import 'package:flutter/material.dart';

class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const DarkCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: Colors.white24, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}