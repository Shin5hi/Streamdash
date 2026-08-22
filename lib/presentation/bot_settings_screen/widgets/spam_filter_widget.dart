import 'dart:ui';

import '../../../core/app_export.dart';

class SpamFilterWidget extends StatefulWidget {
  final bool botEnabled;
  const SpamFilterWidget({required this.botEnabled, super.key});

  @override
  State<SpamFilterWidget> createState() => _SpamFilterWidgetState();
}

class _SpamFilterWidgetState extends State<SpamFilterWidget> {
  // TODO: Replace with Riverpod/Bloc for production
  bool _blockLinks = true;
  bool _blockCaps = true;
  bool _blockRepeated = false;
  double _spamThreshold = 3.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22).withAlpha(217),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'shield',
                      color: const Color(0xFFFFD60A),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Spam Filter',
                      style: TextStyle(
                        color: Color(0xFFE6EDF3),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD60A).withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFD60A).withAlpha(77),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Auto-mod',
                        style: TextStyle(
                          color: Color(0xFFFFD60A),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _FilterToggleRow(
                  icon: 'block',
                  label: 'Block external links',
                  subtitle: 'Remove messages containing URLs',
                  value: _blockLinks,
                  enabled: widget.botEnabled,
                  onChanged: (v) => setState(() => _blockLinks = v),
                ),
                const Divider(height: 16, color: Color(0x1AFFFFFF)),
                _FilterToggleRow(
                  icon: 'warning',
                  label: 'Limit ALL CAPS messages',
                  subtitle: 'Timeout users sending all-caps spam',
                  value: _blockCaps,
                  enabled: widget.botEnabled,
                  onChanged: (v) => setState(() => _blockCaps = v),
                ),
                const Divider(height: 16, color: Color(0x1AFFFFFF)),
                _FilterToggleRow(
                  icon: 'refresh',
                  label: 'Block repeated messages',
                  subtitle: 'Prevent copy-paste spam flooding',
                  value: _blockRepeated,
                  enabled: widget.botEnabled,
                  onChanged: (v) => setState(() => _blockRepeated = v),
                ),
                const Divider(height: 16, color: Color(0x1AFFFFFF)),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'timer',
                      color: const Color(0xFF8B949E),
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Spam threshold',
                            style: TextStyle(
                              color: Color(0xFFE6EDF3),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_spamThreshold.toInt()} identical messages triggers timeout',
                            style: const TextStyle(
                              color: Color(0xFF8B949E),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_spamThreshold.toInt()}x',
                      style: const TextStyle(
                        color: Color(0xFFFFD60A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFFFD60A),
                    inactiveTrackColor: const Color(0xFF30363D),
                    thumbColor: const Color(0xFFFFD60A),
                    overlayColor: const Color(0xFFFFD60A).withAlpha(26),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _spamThreshold,
                    min: 2,
                    max: 10,
                    divisions: 8,
                    onChanged: widget.botEnabled
                        ? (v) => setState(() => _spamThreshold = v)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterToggleRow extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _FilterToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: value && enabled
              ? const Color(0xFFFFD60A)
              : const Color(0xFF8B949E),
          size: 15,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: enabled
                      ? const Color(0xFFE6EDF3)
                      : const Color(0xFF8B949E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
              ),
            ],
          ),
        ),
        Switch(
          value: value && enabled,
          onChanged: enabled ? onChanged : null,
          activeThumbColor: const Color(0xFFFFD60A),
          activeTrackColor: const Color(0xFFFFD60A).withAlpha(77),
          inactiveThumbColor: const Color(0xFF8B949E),
          inactiveTrackColor: const Color(0xFF30363D),
        ),
      ],
    );
  }
}
