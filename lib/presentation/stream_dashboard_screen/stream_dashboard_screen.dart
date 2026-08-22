import 'dart:async';
import 'dart:ui';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/youtube_service.dart';
import './widgets/stream_bot_commands_widget.dart';
import './widgets/stream_chat_feed_widget.dart';
import './widgets/stream_metrics_widget.dart';
import './widgets/stream_video_widget.dart';
import './widgets/stream_viewer_chart_widget.dart';
import './widgets/yt_quick_actions_widget.dart';

class StreamDashboardScreen extends StatefulWidget {
  const StreamDashboardScreen({super.key});

  @override
  State<StreamDashboardScreen> createState() => _StreamDashboardScreenState();
}

class _StreamDashboardScreenState extends State<StreamDashboardScreen> {
  final YouTubeService _ytService = YouTubeService();

  bool _isLive = false;
  bool _botActive = true;
  bool _isShortsMode = false;
  bool _isLoadingMetrics = true;

  int _concurrentViewers = 0;
  int _totalLikes = 0;
  int _commentsPerMin = 0;
  int _newSubs = 0;
  String _streamDuration = '0:00:00';
  String _channelName = '';
  String _streamTitle = '';

  StreamSubscription<YTStreamMetrics>? _metricsSub;
  Timer? _durationTicker;
  DateTime? _streamStartTime;

  @override
  void initState() {
    super.initState();
    _initYouTubeData();
  }

  Future<void> _initYouTubeData() async {
    // Fetch channel info first
    await _ytService.fetchChannelInfo();

    // Subscribe to metrics stream
    _metricsSub = _ytService.metricsStream.listen((metrics) {
      if (!mounted) return;
      setState(() {
        _isLive = metrics.isLive;
        _concurrentViewers = metrics.concurrentViewers;
        _totalLikes = metrics.totalLikes;
        _commentsPerMin = metrics.totalComments;
        _newSubs = metrics.newSubscribers;
        _streamDuration = metrics.streamDuration;
        _channelName = metrics.channelName;
        _streamTitle = metrics.title;
        _isLoadingMetrics = false;
      });
    });

    // Start real-time polling (fetches immediately + every 30s)
    _ytService.startRealTimePolling();

    // Fallback: if no API key configured, show offline state quickly
    if (!_ytService.hasApiKey) {
      setState(() => _isLoadingMetrics = false);
    }
  }

  @override
  void dispose() {
    _metricsSub?.cancel();
    _durationTicker?.cancel();
    _ytService.stopPolling();
    super.dispose();
  }

  void _toggleBot() {
    setState(() => _botActive = !_botActive);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_botActive ? 'Bot activated' : 'Bot deactivated'),
        backgroundColor: _botActive
            ? const Color(0xFF30D158)
            : const Color(0xFFFF3B30),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleShortsMode() {
    setState(() => _isShortsMode = !_isShortsMode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              _isShortsMode
                  ? 'Modo Shorts activado — Formato vertical 9:16'
                  : 'Modo Stream normal activado',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: _isShortsMode
            ? const Color(0xFFFF0000)
            : const Color(0xFF30363D),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: _isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
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
            color: const Color(0xFF0D1117).withAlpha(179),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91916), Color(0xFF9146FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: CustomIconWidget(
                      iconName: 'live_tv',
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    _channelName.isNotEmpty ? _channelName : 'StreamDash',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: const Color(0xFFE6EDF3),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (_isShortsMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⚡', style: TextStyle(fontSize: 10)),
                        SizedBox(width: 3),
                        Text(
                          'SHORTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                // API key missing warning
                if (!_ytService.hasApiKey)
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
                      'API KEY',
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
                      color: const Color(0xFFFF3B30),
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
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () =>
                      context.push(AppRoutes.ytChannelConnectScreen),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF0000).withAlpha(60),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      color: Color(0xFFFF0000),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => context.push(AppRoutes.botSettingsScreen),
                  icon: CustomIconWidget(
                    iconName: 'settings',
                    color: const Color(0xFF8B949E),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    if (_isShortsMode) {
      return _buildShortsLayout();
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamVideoWidget(
                  isLive: _isLive,
                  viewerCount: _concurrentViewers,
                  isShortsMode: _isShortsMode,
                  onToggleShortsMode: _toggleShortsMode,
                ),
                const SizedBox(height: 12),
                _isLoadingMetrics
                    ? _buildMetricsSkeleton()
                    : StreamMetricsWidget(
                        concurrentViewers: _concurrentViewers,
                        totalLikes: _totalLikes,
                        commentsPerMin: _commentsPerMin,
                        newSubs: _newSubs,
                      ),
                const SizedBox(height: 12),
                StreamViewerChartWidget(isLive: _isLive),
                const SizedBox(height: 12),
                StreamBotCommandsWidget(
                  botActive: _botActive,
                  onToggleBot: _toggleBot,
                ),
                const SizedBox(height: 12),
                YtQuickActionsWidget(
                  onChatTap: () => context.push(AppRoutes.ytLiveChatScreen),
                  onAnalyticsTap: () =>
                      context.push(AppRoutes.ytAnalyticsScreen),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: StreamChatFeedWidget(isLive: _isLive),
          ),
        ),
      ],
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
                  color: const Color(0xFF161B22),
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

  Widget _buildShortsLayout() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamVideoWidget(
                  isLive: _isLive,
                  viewerCount: _concurrentViewers,
                  isShortsMode: _isShortsMode,
                  onToggleShortsMode: _toggleShortsMode,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight - MediaQuery.of(context).padding.top - 56,
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 8, top: 4, bottom: 24),
              child: StreamChatFeedWidget(isLive: _isLive, compact: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 8, bottom: 24),
            child: Column(
              children: [
                StreamVideoWidget(
                  isLive: _isLive,
                  viewerCount: _concurrentViewers,
                  isShortsMode: _isShortsMode,
                  onToggleShortsMode: _toggleShortsMode,
                ),
                const SizedBox(height: 12),
                _isLoadingMetrics
                    ? _buildMetricsSkeleton()
                    : StreamMetricsWidget(
                        concurrentViewers: _concurrentViewers,
                        totalLikes: _totalLikes,
                        commentsPerMin: _commentsPerMin,
                        newSubs: _newSubs,
                      ),
                const SizedBox(height: 12),
                StreamViewerChartWidget(isLive: _isLive),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 8, right: 16, bottom: 24),
            child: Column(
              children: [
                StreamBotCommandsWidget(
                  botActive: _botActive,
                  onToggleBot: _toggleBot,
                ),
                const SizedBox(height: 12),
                StreamChatFeedWidget(isLive: _isLive),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _toggleBot,
      backgroundColor: _botActive
          ? const Color(0xFF30D158)
          : const Color(0xFF30363D),
      icon: CustomIconWidget(
        iconName: _botActive ? 'smart_toy' : 'smart_toy_outlined',
        color: Colors.white,
        size: 20,
      ),
      label: Text(
        _botActive ? 'Bot ON' : 'Bot OFF',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
