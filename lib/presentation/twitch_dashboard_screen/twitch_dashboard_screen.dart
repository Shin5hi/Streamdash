import 'dart:async';
import 'dart:ui';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/twitch_service.dart';
import '../stream_dashboard_screen/widgets/stream_bot_commands_widget.dart';
import '../stream_dashboard_screen/widgets/stream_viewer_chart_widget.dart';

class TwitchDashboardScreen extends StatefulWidget {
  const TwitchDashboardScreen({super.key});

  @override
  State<TwitchDashboardScreen> createState() => _TwitchDashboardScreenState();
}

class _TwitchDashboardScreenState extends State<TwitchDashboardScreen> {
  final TwitchService _twitchService = TwitchService();

  bool _isLive = false;
  bool _botActive = true;
  bool _isLoadingMetrics = true;

  int _concurrentViewers = 0;
  int _totalFollowers = 0;
  int _newFollowers = 0;
  int _chatMessagesPerMin = 0;
  int _bitsTotal = 0;
  String _streamDuration = '0:00:00';
  String _channelName = '';
  String _streamTitle = '';
  String _gameName = '';

  StreamSubscription<TwitchStreamMetrics>? _metricsSub;
  StreamSubscription<TwitchChatMessage>? _chatSub;
  final List<TwitchChatMessage> _recentMessages = [];

  @override
  void initState() {
    super.initState();
    _initTwitchData();
  }

  Future<void> _initTwitchData() async {
    await _twitchService.fetchChannelInfo();

    _metricsSub = _twitchService.metricsStream.listen((metrics) {
      if (!mounted) return;
      setState(() {
        _isLive = metrics.isLive;
        _concurrentViewers = metrics.concurrentViewers;
        _totalFollowers = metrics.totalFollowers;
        _newFollowers = metrics.newFollowers;
        _chatMessagesPerMin = metrics.chatMessagesPerMin;
        _bitsTotal = metrics.bitsTotal;
        _streamDuration = metrics.streamDuration;
        _channelName = metrics.channelName;
        _streamTitle = metrics.title;
        _gameName = metrics.gameName;
        _isLoadingMetrics = false;
      });
    });

    _chatSub = _twitchService.chatStream.listen((msg) {
      if (!mounted) return;
      setState(() {
        _recentMessages.insert(0, msg);
        if (_recentMessages.length > 50) _recentMessages.removeLast();
      });
    });

    if (_twitchService.hasCredentials) {
      _twitchService.startRealTimePolling();
    } else {
      _twitchService.startMockStream();
      setState(() => _isLoadingMetrics = false);
    }
  }

  @override
  void dispose() {
    _metricsSub?.cancel();
    _chatSub?.cancel();
    _twitchService.stopPolling();
    super.dispose();
  }

  void _toggleBot() {
    setState(() => _botActive = !_botActive);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_botActive ? 'Bot activado' : 'Bot desactivado'),
        backgroundColor: _botActive
            ? const Color(0xFF30D158)
            : const Color(0xFF9146FF),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStreamPreview(),
                    const SizedBox(height: 12),
                    _isLoadingMetrics
                        ? _buildMetricsSkeleton()
                        : _buildMetricsGrid(),
                    const SizedBox(height: 12),
                    StreamViewerChartWidget(isLive: _isLive),
                    const SizedBox(height: 12),
                    StreamBotCommandsWidget(
                      botActive: _botActive,
                      onToggleBot: _toggleBot,
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActions(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 280,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildChatFeed(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: const Color(0xFF0D0D12).withAlpha(179),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9146FF), Color(0xFF6441A5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text('🎮', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    _channelName.isNotEmpty ? _channelName : 'StreamDash',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Color(0xFFE6EDF3),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (_gameName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9146FF).withAlpha(40),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF9146FF).withAlpha(80),
                      ),
                    ),
                    child: Text(
                      _gameName,
                      style: const TextStyle(
                        color: Color(0xFF9146FF),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const Spacer(),
                if (!_twitchService.hasCredentials)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD60A).withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFFFD60A).withAlpha(80),
                      ),
                    ),
                    child: const Text(
                      'DEMO',
                      style: TextStyle(
                        color: Color(0xFFFFD60A),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (_isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9146FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
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
                  ),
                const SizedBox(width: 8),
                Text(
                  _streamDuration,
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () =>
                      context.push(AppRoutes.twitchChannelConnectScreen),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9146FF).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF9146FF).withAlpha(60),
                      ),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      color: Color(0xFF9146FF),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreamPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF14141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
        image: _streamTitle.isNotEmpty ? null : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (_isLive)
              CachedNetworkImage(
                imageUrl:
                    'https://images.pexels.com/photos/3165335/pexels-photo-3165335.jpeg?auto=compress&cs=tinysrgb&w=640',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(color: const Color(0xFF14141C)),
              )
            else
              Container(
                color: const Color(0xFF14141C),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎮', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 8),
                      Text(
                        'Canal Offline',
                        style: TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Overlay gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(180)],
                  ),
                ),
              ),
            ),
            // Bottom info
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_streamTitle.isNotEmpty)
                    Text(
                      _streamTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Color(0xFF9146FF),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _fmt(_concurrentViewers),
                        style: const TextStyle(
                          color: Color(0xFFE6EDF3),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_gameName.isNotEmpty) ...[
                        const Icon(
                          Icons.sports_esports_outlined,
                          color: Color(0xFF8B949E),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _gameName,
                          style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Twitch badge
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF9146FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Twitch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      _MetricItem(
        icon: Icons.remove_red_eye_outlined,
        label: 'Viewers',
        value: _fmt(_concurrentViewers),
        color: const Color(0xFF9146FF),
      ),
      _MetricItem(
        icon: Icons.favorite_outline,
        label: 'Followers',
        value: _fmt(_totalFollowers),
        color: const Color(0xFFE91916),
      ),
      _MetricItem(
        icon: Icons.chat_bubble_outline,
        label: 'Msgs/min',
        value: _chatMessagesPerMin.toString(),
        color: const Color(0xFFFFD60A),
      ),
      _MetricItem(
        icon: Icons.diamond_outlined,
        label: 'Bits',
        value: _fmt(_bitsTotal),
        color: const Color(0xFF30D158),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: metrics.map((m) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: m.color.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: m.color.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(m.icon, color: m.color, size: 16),
                  const SizedBox(height: 6),
                  Text(
                    m.value,
                    style: TextStyle(
                      color: m.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.label,
                    style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          4,
          (i) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF14141C),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              color: Color(0xFFE6EDF3),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ActionButton(
                icon: Icons.chat_outlined,
                label: 'Chat',
                color: const Color(0xFF9146FF),
                onTap: () => context.push(AppRoutes.twitchLiveChatScreen),
              ),
              const SizedBox(width: 10),
              _ActionButton(
                icon: Icons.bar_chart_outlined,
                label: 'Analytics',
                color: const Color(0xFFE91916),
                onTap: () => context.push(AppRoutes.twitchAnalyticsScreen),
              ),
              const SizedBox(width: 10),
              _ActionButton(
                icon: Icons.content_cut_outlined,
                label: 'Clips',
                color: const Color(0xFFFFD60A),
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _ActionButton(
                icon: Icons.people_outline,
                label: 'Raid',
                color: const Color(0xFF30D158),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatFeed() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF14141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9146FF),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Chat en Vivo',
                  style: TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.twitchLiveChatScreen),
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(
                      color: Color(0xFF9146FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x1AFFFFFF)),
          Expanded(
            child: _recentMessages.isEmpty
                ? const Center(
                    child: Text(
                      'Esperando mensajes...',
                      style: TextStyle(color: Color(0xFF8B949E), fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _recentMessages.length,
                    itemBuilder: (_, i) {
                      final msg = _recentMessages[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              if (msg.isModerator)
                                const WidgetSpan(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.shield,
                                      color: Color(0xFF00AD03),
                                      size: 12,
                                    ),
                                  ),
                                ),
                              if (msg.isSubscriber)
                                const WidgetSpan(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.star,
                                      color: Color(0xFF9146FF),
                                      size: 12,
                                    ),
                                  ),
                                ),
                              TextSpan(
                                text: '${msg.authorName}: ',
                                style: TextStyle(
                                  color: msg.badgeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: msg.message,
                                style: const TextStyle(
                                  color: Color(0xFFE6EDF3),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _MetricItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
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
