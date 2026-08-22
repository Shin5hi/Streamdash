import '../core/app_export.dart';

class _TabSpec {
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final int? branchIndex;

  const _TabSpec({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedVisualIndex = 0;

  static const List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'YouTube',
      activeIcon: 'smart_display',
      inactiveIcon: 'smart_display',
      branchIndex: 0,
    ),
    _TabSpec(
      label: 'Twitch',
      activeIcon: 'live_tv',
      inactiveIcon: 'live_tv',
      branchIndex: 1,
    ),
    _TabSpec(
      label: 'Bot',
      activeIcon: 'smart_toy',
      inactiveIcon: 'smart_toy_outlined',
      branchIndex: 2,
    ),
    _TabSpec(
      label: 'Account',
      activeIcon: 'person',
      inactiveIcon: 'person_outline',
      branchIndex: 3,
    ),
    _TabSpec(
      label: 'History',
      activeIcon: 'video_library',
      inactiveIcon: 'video_library_outlined',
      branchIndex: 4,
    ),
  ];

  void _onTabTap(int visualIndex) {
    final tab = _tabs[visualIndex];
    if (tab.branchIndex == null) return;
    setState(() => _selectedVisualIndex = visualIndex);
    widget.navigationShell.goBranch(
      tab.branchIndex!,
      initialLocation: tab.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF14141C),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(102),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final isActive = i == _selectedVisualIndex;

            // Platform tabs get special colors
            Color activeColor;
            Color activeBg;
            if (i == 0) {
              // YouTube
              activeColor = const Color(0xFFE91916);
              activeBg = const Color(0xFFE91916).withAlpha(38);
            } else if (i == 1) {
              // Twitch
              activeColor = const Color(0xFF9146FF);
              activeBg = const Color(0xFF9146FF).withAlpha(38);
            } else {
              activeColor = const Color(0xFFE91916);
              activeBg = const Color(0xFFE91916).withAlpha(38);
            }

            return GestureDetector(
              onTap: () => _onTabTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // YouTube tab: use YT icon text, Twitch: use T icon
                    if (i == 0)
                      Text(
                        '▶',
                        style: TextStyle(
                          fontSize: 16,
                          color: isActive
                              ? activeColor
                              : const Color(0xFF8B949E),
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    else if (i == 1)
                      Text('🎮', style: TextStyle(fontSize: isActive ? 18 : 16))
                    else
                      Icon(
                        isActive
                            ? _iconData(tab.activeIcon)
                            : _iconData(tab.inactiveIcon),
                        color: isActive ? activeColor : const Color(0xFF8B949E),
                        size: 20,
                      ),
                    if (isActive) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'smart_toy':
        return Icons.smart_toy;
      case 'smart_toy_outlined':
        return Icons.smart_toy_outlined;
      case 'person':
        return Icons.person;
      case 'person_outline':
        return Icons.person_outline;
      case 'video_library':
        return Icons.video_library;
      case 'video_library_outlined':
        return Icons.video_library_outlined;
      case 'smart_display':
        return Icons.smart_display;
      case 'live_tv':
        return Icons.live_tv;
      default:
        return Icons.circle;
    }
  }
}
