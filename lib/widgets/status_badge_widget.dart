import 'package:flutter/material.dart';

enum StreamStatus { live, offline, scheduled, ended }

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool pulse;

  const StatusBadgeWidget({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.pulse = false,
    super.key,
  });

  factory StatusBadgeWidget.live() => const StatusBadgeWidget(
    label: 'LIVE',
    backgroundColor: Color(0xFFFF3B30),
    textColor: Colors.white,
    pulse: true,
  );

  factory StatusBadgeWidget.offline() => const StatusBadgeWidget(
    label: 'OFFLINE',
    backgroundColor: Color(0xFF30363D),
    textColor: Color(0xFF8B949E),
  );

  factory StatusBadgeWidget.active() => const StatusBadgeWidget(
    label: 'ACTIVE',
    backgroundColor: Color(0xFF0A2E16),
    textColor: Color(0xFF30D158),
  );

  factory StatusBadgeWidget.disabled() => const StatusBadgeWidget(
    label: 'DISABLED',
    backgroundColor: Color(0xFF21262D),
    textColor: Color(0xFF8B949E),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
