import 'dart:ui';

import '../../../core/app_export.dart';

class BotHeaderWidget extends StatelessWidget {
  final bool botEnabled;
  final int commandsFired;
  final int spamBlocked;
  final VoidCallback onToggle;

  const BotHeaderWidget({
    required this.botEnabled,
    required this.commandsFired,
    required this.spamBlocked,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22).withAlpha(230),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: botEnabled
                    ? const Color(0xFF30D158).withAlpha(77)
                    : const Color(0x1AFFFFFF),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: botEnabled
                            ? const Color(0xFF30D158).withAlpha(31)
                            : const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: botEnabled
                              ? const Color(0xFF30D158).withAlpha(77)
                              : const Color(0x1AFFFFFF),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'smart_toy',
                          color: botEnabled
                              ? const Color(0xFF30D158)
                              : const Color(0xFF8B949E),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'StreamDash Bot',
                            style: TextStyle(
                              color: Color(0xFFE6EDF3),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            botEnabled
                                ? 'Active — monitoring chat'
                                : 'Disabled — not responding',
                            style: TextStyle(
                              color: botEnabled
                                  ? const Color(0xFF30D158)
                                  : const Color(0xFF8B949E),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 52,
                        height: 28,
                        decoration: BoxDecoration(
                          color: botEnabled
                              ? const Color(0xFF30D158)
                              : const Color(0xFF30363D),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              left: botEnabled ? 26 : 2,
                              top: 2,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatPill(
                      icon: 'bolt',
                      label: 'Commands fired',
                      value: commandsFired.toString(),
                      color: const Color(0xFF0A84FF),
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      icon: 'shield',
                      label: 'Spam blocked',
                      value: spamBlocked.toString(),
                      color: const Color(0xFFFFD60A),
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      icon: 'format_list_bulleted',
                      label: 'Total commands',
                      value: '8',
                      color: const Color(0xFF30D158),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(51), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomIconWidget(iconName: icon, color: color, size: 14),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
