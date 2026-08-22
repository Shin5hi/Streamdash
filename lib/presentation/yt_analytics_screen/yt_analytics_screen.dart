import 'dart:async';
import 'dart:ui';

import '../../core/app_export.dart';
import '../../services/youtube_service.dart';
import './widgets/yt_metric_card_widget.dart';
import './widgets/yt_superchat_stats_widget.dart';
import './widgets/yt_viewer_sparkline_widget.dart';

class YtAnalyticsScreen extends StatefulWidget {
  const YtAnalyticsScreen({super.key});

  @override
  State<YtAnalyticsScreen> createState() => _YtAnalyticsScreenState();
}

class _YtAnalyticsScreenState extends State<YtAnalyticsScreen> {
  StreamSubscription<YTStreamMetrics>? _metricsSub;
  YTStreamMetrics? _metrics;
  final List<double> _viewerHistory = [];

  @override
  void initState() {
    super.initState();
    YouTubeService().startMockStream();
    _metricsSub = YouTubeService().metricsStream.listen((m) {
      if (!mounted) return;
      setState(() {
        _metrics = m;
        _viewerHistory.add(m.concurrentViewers.toDouble());
        if (_viewerHistory.length > 20) _viewerHistory.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _metricsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _metrics;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: _buildAppBar(),
      body: m == null
          ? _buildLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStreamInfo(m),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(m),
                  const SizedBox(height: 16),
                  YtViewerSparklineWidget(history: _viewerHistory),
                  const SizedBox(height: 16),
                  YtSuperChatStatsWidget(
                    count: m.superChatCount,
                    revenue: m.superChatRevenue,
                  ),
                  const SizedBox(height: 16),
                  _buildEngagementRate(m),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF161B22),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xFFE6EDF3),
          size: 18,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Stream Analytics',
        style: TextStyle(
          color: Color(0xFFE6EDF3),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF3B30).withAlpha(38),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3B30),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: Color(0xFFFF3B30),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
    );
  }

  Widget _buildStreamInfo(YTStreamMetrics m) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withAlpha(217),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: m.thumbnailUrl,
                  width: 72,
                  height: 48,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 72,
                    height: 48,
                    color: const Color(0xFF21262D),
                    child: const Icon(Icons.live_tv, color: Color(0xFF8B949E)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: const TextStyle(
                        color: Color(0xFFE6EDF3),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color(0xFF8B949E),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          m.streamDuration,
                          style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.youtube_searched_for,
                          color: Color(0xFFFF3B30),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          m.channelName,
                          style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 11,
                          ),
                        ),
                      ],
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

  Widget _buildMetricsGrid(YTStreamMetrics m) {
    final cards = [
      YtMetricCardData(
        icon: Icons.visibility_outlined,
        label: 'Viewers',
        value: _fmt(m.concurrentViewers),
        accent: const Color(0xFF0A84FF),
        trend: '+4.2%',
        trendUp: true,
      ),
      YtMetricCardData(
        icon: Icons.thumb_up_outlined,
        label: 'Likes',
        value: _fmt(m.totalLikes),
        accent: const Color(0xFFFF3B30),
        trend: '+2.1%',
        trendUp: true,
      ),
      YtMetricCardData(
        icon: Icons.chat_bubble_outline,
        label: 'Msgs/min',
        value: m.totalComments.toString(),
        accent: const Color(0xFFFFD60A),
        trend: '-8%',
        trendUp: false,
      ),
      YtMetricCardData(
        icon: Icons.group_add_outlined,
        label: 'New Subs',
        value: m.newSubscribers.toString(),
        accent: const Color(0xFF30D158),
        trend: '+${m.newSubscribers}',
        trendUp: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) => YtMetricCardWidget(data: cards[i]),
    );
  }

  Widget _buildEngagementRate(YTStreamMetrics m) {
    final rate = m.concurrentViewers > 0
        ? ((m.totalLikes / m.concurrentViewers) * 100).clamp(0, 100)
        : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withAlpha(217),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.insights, color: Color(0xFF30D158), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Engagement Rate',
                    style: TextStyle(
                      color: Color(0xFFE6EDF3),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: rate / 100,
                        backgroundColor: const Color(0xFF21262D),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF30D158),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${rate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Color(0xFF30D158),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Based on ${_fmt(m.totalLikes)} likes / ${_fmt(m.concurrentViewers)} viewers',
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}
