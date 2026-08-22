import 'dart:ui';

import '../../../core/app_export.dart';
import '../bot_settings_screen.dart';

class BotCommandListWidget extends StatelessWidget {
  final List<BotCommand> commands;
  final bool botEnabled;
  final void Function(String id) onToggle;
  final void Function(String id) onDelete;

  const BotCommandListWidget({
    required this.commands,
    required this.botEnabled,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Commands',
                style: TextStyle(
                  color: Color(0xFFE6EDF3),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${commands.length}',
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (commands.isEmpty)
            EmptyStateWidget(
              iconName: 'terminal',
              title: 'No commands yet',
              subtitle:
                  'Add your first bot command to automate chat responses during your live streams.',
              ctaLabel: 'Add Command',
              onCta: () {},
            )
          else
            ...commands.asMap().entries.map((entry) {
              final i = entry.key;
              final cmd = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (i * 50).clamp(0, 400)),
                curve: Curves.easeOutCubic,
                builder: (_, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - v)),
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CommandCard(
                    command: cmd,
                    botEnabled: botEnabled,
                    onToggle: () => onToggle(cmd.id),
                    onDelete: () => onDelete(cmd.id),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _CommandCard extends StatelessWidget {
  final BotCommand command;
  final bool botEnabled;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _CommandCard({
    required this.command,
    required this.botEnabled,
    required this.onToggle,
    required this.onDelete,
  });

  Color get _categoryColor {
    switch (command.category) {
      case 'moderation':
        return const Color(0xFFFF3B30);
      case 'engagement':
        return const Color(0xFF30D158);
      default:
        return const Color(0xFF0A84FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEffectivelyActive = command.isActive && botEnabled;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withAlpha(217),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isEffectivelyActive
                  ? _categoryColor.withAlpha(51)
                  : const Color(0x1AFFFFFF),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Trigger badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _categoryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _categoryColor.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      command.trigger,
                      style: TextStyle(
                        color: _categoryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21262D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      command.category,
                      style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Active toggle
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isEffectivelyActive
                            ? const Color(0xFF30D158)
                            : const Color(0xFF30363D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            left: command.isActive ? 18 : 2,
                            top: 2,
                            child: Container(
                              width: 16,
                              height: 16,
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
                  const SizedBox(width: 8),
                  // Delete
                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: const CustomIconWidget(
                      iconName: 'delete',
                      color: Color(0xFF8B949E),
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Response preview
              Text(
                command.response,
                style: const TextStyle(
                  color: Color(0xFFB8C4CE),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Metadata row
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'timer',
                    color: const Color(0xFF8B949E),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${command.cooldownSec}s cooldown',
                    style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomIconWidget(
                    iconName: 'bolt',
                    color: const Color(0xFF8B949E),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${command.usageCount} uses',
                    style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  if (!command.isActive)
                    const Text(
                      'Disabled',
                      style: TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Usage stats row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
                ),
                child: Row(
                  children: [
                    // Trigger count
                    Expanded(
                      child: _StatCell(
                        icon: 'bolt',
                        label: 'Activaciones',
                        value: '${command.usageCount}',
                        color: const Color(0xFF0A84FF),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: const Color(0x1AFFFFFF),
                    ),
                    // Success rate
                    Expanded(
                      child: _StatCell(
                        icon: 'check_circle',
                        label: 'Éxito',
                        value: '${command.successRate.toStringAsFixed(1)}%',
                        color: command.successRate >= 95
                            ? const Color(0xFF30D158)
                            : command.successRate >= 80
                            ? const Color(0xFFFFD60A)
                            : const Color(0xFFFF3B30),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: const Color(0x1AFFFFFF),
                    ),
                    // Viewer impact
                    Expanded(
                      child: _StatCell(
                        icon: 'visibility',
                        label: 'Viewers',
                        value: '+${command.viewerImpact}',
                        color: const Color(0xFFBF5AF2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
        title: const Text(
          'Delete Command',
          style: TextStyle(
            color: Color(0xFFE6EDF3),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Delete "${command.trigger}"? This action cannot be undone.',
          style: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8B949E)),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(iconName: icon, color: color, size: 11),
            const SizedBox(width: 3),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B949E),
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}