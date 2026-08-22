import 'dart:ui';

import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';

class StreamVideoWidget extends StatelessWidget {
  final bool isLive;
  final int viewerCount;
  final bool isShortsMode;
  final VoidCallback? onToggleShortsMode;

  const StreamVideoWidget({
    required this.isLive,
    required this.viewerCount,
    this.isShortsMode = false,
    this.onToggleShortsMode,
    super.key,
  });

  Future<void> _openYouTubeApp() async {
    // Try to open YouTube app first, fallback to browser
    final ytAppUri = Uri.parse('vnd.youtube://');
    final ytWebUri = Uri.parse('https://www.youtube.com');
    try {
      if (await canLaunchUrl(ytAppUri)) {
        await launchUrl(ytAppUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(ytWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(ytWebUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openBotPage() async {
    final uri = Uri.parse(
      'https://github.com/Shin5hi/YouTube_Stream_Extension',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // In Shorts mode the widget only occupies the left half of the screen
    // so we use half the screen width as the reference for the video dimensions.
    final double availableWidth = isShortsMode
        ? (screenWidth / 2) - 16
        : (isTablet ? screenWidth * 0.55 : screenWidth);

    // Normal: 16:9 ratio. Shorts: 9:16 ratio (vertical) — video fills full available width
    final double videoHeight = isShortsMode
        ? availableWidth * (16 / 9)
        : (isTablet ? 240.0 : screenWidth * 0.56);

    final double videoWidth = isShortsMode ? availableWidth : double.infinity;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isShortsMode ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shorts mode banner
          if (isShortsMode) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _ShortsLogoIcon(size: 16),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: Text(
                      'Modo Shorts — 9:16',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Video container
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: isShortsMode ? videoWidth : double.infinity,
                height: videoHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isShortsMode
                        ? const Color(0xFFFF0000).withAlpha(180)
                        : (isLive
                              ? const Color(0xFFFF3B30).withAlpha(102)
                              : const Color(0x1AFFFFFF)),
                    width: isShortsMode ? 2.0 : 1.5,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomImageWidget(
                      imageUrl: isShortsMode
                          ? 'https://images.pixabay.com/photo/2016/11/29/06/17/audience-1867754_1280.jpg'
                          : 'https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg',
                      width: double.infinity,
                      height: videoHeight,
                      fit: BoxFit.cover,
                      semanticLabel: isShortsMode
                          ? 'YouTube Shorts vertical stream preview in portrait orientation'
                          : 'YouTube live stream preview showing streamer at desk with gaming setup and microphone',
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(26),
                            Colors.black.withAlpha(128),
                          ],
                        ),
                      ),
                    ),
                    if (!isLive)
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(153),
                            shape: BoxShape.circle,
                          ),
                          child: const CustomIconWidget(
                            iconName: 'play_arrow',
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    // Shorts watermark in corner
                    if (isShortsMode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _ShortsLogoIcon(size: 22),
                      ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: isLive
                          ? _LiveBadge()
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(153),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'OFFLINE',
                                style: TextStyle(
                                  color: Color(0xFF8B949E),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            color: Colors.black.withAlpha(115),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'visibility',
                                  color: const Color(0xFFE6EDF3),
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatCount(viewerCount),
                                  style: const TextStyle(
                                    color: Color(0xFFE6EDF3),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(128),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: const Color(0x30FFFFFF),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isShortsMode ? '1080p V' : '1080p',
                                    style: const TextStyle(
                                      color: Color(0xFFE6EDF3),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons row below video
          const SizedBox(height: 10),
          Row(
            children: [
              _VideoActionButton(
                onTap: _openYouTubeApp,
                tooltip: 'Abrir YouTube',
                child: _YouTubeIcon(),
              ),
              const SizedBox(width: 8),
              _VideoActionButton(
                onTap: _openBotPage,
                tooltip: 'Bot StreamDash',
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              // Shorts toggle button
              _ShortsToggleButton(
                isActive: isShortsMode,
                onTap: onToggleShortsMode ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// Square Shorts toggle button
class _ShortsToggleButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _ShortsToggleButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isActive ? 'Desactivar modo Shorts' : 'Activar modo Shorts',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF0000) : const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFFF0000)
                  : const Color(0xFF30363D),
              width: 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF0000).withAlpha(80),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: _ShortsLogoIcon(
              size: 26,
              color: isActive ? Colors.white : const Color(0xFF8B949E),
            ),
          ),
        ),
      ),
    );
  }
}

/// YouTube Shorts logo icon (stylized "S" with play triangle)
class _ShortsLogoIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const _ShortsLogoIcon({this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lightning bolt / Shorts "S" shape using text
          Text(
            '⚡',
            style: TextStyle(fontSize: size * 0.75, color: c, height: 1),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Square action button displayed below the video
class _VideoActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final String tooltip;

  const _VideoActionButton({
    required this.onTap,
    required this.child,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF30363D), width: 1.5),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Custom YouTube logo icon (red play button shape)
class _YouTubeIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Center(
        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _opacity,
            builder: (_, __) => Opacity(
              opacity: _opacity.value,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
