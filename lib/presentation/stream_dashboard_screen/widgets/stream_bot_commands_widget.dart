import 'dart:async';
import 'dart:ui';

import '../../../core/app_export.dart';

/// Enhanced bot commands widget with YouTube-specific quick actions,
/// animated emoji reactions, and interactive stream control buttons.
class StreamBotCommandsWidget extends StatefulWidget {
  final bool botActive;
  final VoidCallback onToggleBot;

  const StreamBotCommandsWidget({
    required this.botActive,
    required this.onToggleBot,
    super.key,
  });

  @override
  State<StreamBotCommandsWidget> createState() =>
      _StreamBotCommandsWidgetState();
}

class _StreamBotCommandsWidgetState extends State<StreamBotCommandsWidget>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  final List<_FloatingEmoji> _floatingEmojis = [];

  static const List<Map<String, String>> _botCommands = [
    {'icon': 'bolt', 'label': '!socials', 'desc': 'Post social links'},
    {'icon': 'timer', 'label': '!uptime', 'desc': 'Stream uptime'},
    {'icon': 'people', 'label': '!discord', 'desc': 'Discord invite'},
    {
      'icon': 'record_voice_over',
      'label': '!shoutout',
      'desc': 'Shoutout user',
    },
    {'icon': 'block', 'label': '!timeout', 'desc': 'Timeout 60s'},
    {'icon': 'schedule', 'label': '!schedule', 'desc': 'Next stream'},
    {'icon': 'local_fire_department', 'label': '!hype', 'desc': 'Hype train'},
    {'icon': 'content_cut', 'label': '!clip', 'desc': 'Create clip'},
  ];

  static const List<Map<String, dynamic>> _streamActions = [
    {'emoji': '🔥', 'label': 'Hype', 'color': 0xFFFF9500},
    {'emoji': '❤️', 'label': 'Love', 'color': 0xFFFF3B30},
    {'emoji': '🎉', 'label': 'Party', 'color': 0xFFFFD60A},
    {'emoji': '💯', 'label': '100%', 'color': 0xFF30D158},
    {'emoji': '👏', 'label': 'Clap', 'color': 0xFF0A84FF},
    {'emoji': '🚀', 'label': 'Rocket', 'color': 0xFFBF5AF2},
  ];

  static const List<Map<String, dynamic>> _moderationActions = [
    {'icon': 'slow_motion_video', 'label': 'Slow Mode', 'color': 0xFF0A84FF},
    {'icon': 'block', 'label': 'Sub Only', 'color': 0xFFFFD60A},
    {'icon': 'shield', 'label': 'Shield', 'color': 0xFF30D158},
    {'icon': 'clear_all', 'label': 'Clear Chat', 'color': 0xFFFF453A},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _launchEmoji(String emoji) {
    setState(() {
      _floatingEmojis.add(
        _FloatingEmoji(
          emoji: emoji,
          id: DateTime.now().millisecondsSinceEpoch,
          xOffset: 20.0 + (DateTime.now().millisecond % 60).toDouble(),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _floatingEmojis.removeWhere(
            (e) => e.id == _floatingEmojis.firstOrNull?.id,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22).withAlpha(217),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildTabBar(),
                    SizedBox(
                      height: 120,
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _buildBotCommandsTab(),
                          _buildEmojiReactionsTab(),
                          _buildModerationTab(),
                        ],
                      ),
                    ),
                    _buildStatusBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
        ..._floatingEmojis.map((fe) => _FloatingEmojiWidget(data: fe)),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'smart_toy',
            color: widget.botActive
                ? const Color(0xFF30D158)
                : const Color(0xFF8B949E),
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            'Stream Controls',
            style: TextStyle(
              color: Color(0xFFE6EDF3),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.onToggleBot,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.botActive
                    ? const Color(0xFF30D158).withAlpha(38)
                    : const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.botActive
                      ? const Color(0xFF30D158).withAlpha(102)
                      : const Color(0x1AFFFFFF),
                ),
              ),
              child: Text(
                widget.botActive ? 'BOT ON' : 'BOT OFF',
                style: TextStyle(
                  color: widget.botActive
                      ? const Color(0xFF30D158)
                      : const Color(0xFF8B949E),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: TabBar(
        controller: _tabCtrl,
        isScrollable: false,
        indicatorColor: const Color(0xFFFF3B30),
        indicatorWeight: 2,
        labelColor: const Color(0xFFFF3B30),
        unselectedLabelColor: const Color(0xFF8B949E),
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        dividerColor: const Color(0x1AFFFFFF),
        tabs: const [
          Tab(text: 'Bot Commands'),
          Tab(text: 'Reactions'),
          Tab(text: 'Moderation'),
        ],
      ),
    );
  }

  Widget _buildBotCommandsTab() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: _botCommands.map((cmd) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _CommandChip(
              icon: cmd['icon']!,
              label: cmd['label']!,
              enabled: widget.botActive,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmojiReactionsTab() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: _streamActions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _EmojiActionButton(
              emoji: action['emoji'] as String,
              label: action['label'] as String,
              color: Color(action['color'] as int),
              onTap: () => _launchEmoji(action['emoji'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModerationTab() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: _moderationActions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _ModerationButton(
              icon: action['icon'] as String,
              label: action['label'] as String,
              color: Color(action['color'] as int),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Text(
        widget.botActive
            ? '${_botCommands.length} commands active · Last fired: !socials 2m ago'
            : 'Bot is disabled — commands will not respond',
        style: const TextStyle(
          color: Color(0xFF8B949E),
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ─── Command Chip ────────────────────────────────────────────────────────────

class _CommandChip extends StatefulWidget {
  final String icon;
  final String label;
  final bool enabled;
  const _CommandChip({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  @override
  State<_CommandChip> createState() => _CommandChipState();
}

class _CommandChipState extends State<_CommandChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _scale;
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  void _onTap() async {
    if (!widget.enabled) return;
    await _scale.reverse();
    setState(() => _fired = true);
    await _scale.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _fired = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _fired
                ? const Color(0xFF30D158).withAlpha(38)
                : widget.enabled
                ? const Color(0xFF21262D)
                : const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _fired
                  ? const Color(0xFF30D158).withAlpha(128)
                  : widget.enabled
                  ? const Color(0x2AFFFFFF)
                  : const Color(0x0FFFFFFF),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: _fired ? 'check_circle' : widget.icon,
                color: _fired
                    ? const Color(0xFF30D158)
                    : widget.enabled
                    ? const Color(0xFFE6EDF3)
                    : const Color(0xFF8B949E),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.enabled
                      ? const Color(0xFFE6EDF3)
                      : const Color(0xFF8B949E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Emoji Action Button ──────────────────────────────────────────────────────

class _EmojiActionButton extends StatefulWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _EmojiActionButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_EmojiActionButton> createState() => _EmojiActionButtonState();
}

class _EmojiActionButtonState extends State<_EmojiActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _ctrl.reverse();
    widget.onTap();
    await _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.color.withAlpha(77)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Moderation Button ────────────────────────────────────────────────────────

class _ModerationButton extends StatefulWidget {
  final String icon;
  final String label;
  final Color color;
  const _ModerationButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_ModerationButton> createState() => _ModerationButtonState();
}

class _ModerationButtonState extends State<_ModerationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _ctrl.reverse();
    setState(() => _active = !_active);
    await _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _ctrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _active
                ? widget.color.withAlpha(38)
                : const Color(0xFF21262D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _active
                  ? widget.color.withAlpha(128)
                  : const Color(0x2AFFFFFF),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: widget.icon,
                color: _active ? widget.color : const Color(0xFF8B949E),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: _active ? widget.color : const Color(0xFF8B949E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Floating Emoji Animation ─────────────────────────────────────────────────

class _FloatingEmoji {
  final String emoji;
  final int id;
  final double xOffset;
  _FloatingEmoji({
    required this.emoji,
    required this.id,
    required this.xOffset,
  });
}

class _FloatingEmojiWidget extends StatefulWidget {
  final _FloatingEmoji data;
  const _FloatingEmojiWidget({required this.data});

  @override
  State<_FloatingEmojiWidget> createState() => _FloatingEmojiWidgetState();
}

class _FloatingEmojiWidgetState extends State<_FloatingEmojiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _y;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_ctrl);
    _y = Tween(
      begin: 0.0,
      end: -120.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: widget.data.xOffset,
      bottom: 60,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _y.value),
          child: Opacity(
            opacity: _opacity.value,
            child: Text(
              widget.data.emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
      ),
    );
  }
}
