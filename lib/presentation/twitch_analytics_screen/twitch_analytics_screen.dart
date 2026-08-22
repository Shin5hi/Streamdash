import 'dart:async';
import 'dart:ui';

import '../../core/app_export.dart';
import '../../services/twitch_service.dart';

class TwitchAnalyticsScreen extends StatefulWidget {
  const TwitchAnalyticsScreen({super.key});

  @override
  State<TwitchAnalyticsScreen> createState() => _TwitchAnalyticsScreenState();
}

class _TwitchAnalyticsScreenState extends State<TwitchAnalyticsScreen> {
  StreamSubscription<TwitchStreamMetrics>? _metricsSub;
  TwitchStreamMetrics? _metrics;
  final List<double> _viewerHistory = [];

  @override
  void initState() {
    super.initState();
    TwitchService().startMockStream();
    _metricsSub = TwitchService().metricsStream.listen((m) {
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
      backgroundColor: const Color(0xFF0D0D12),
      appBar: _buildAppBar(),
      body: m == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9146FF)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStreamInfo(m),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(m),
                  const SizedBox(height: 16),
                  _buildViewerChart(),
                  const SizedBox(height: 16),
                  _buildBitsSection(m),
                  const SizedBox(height: 16),
                  _buildEngagementRate(m),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF14141C),
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
        'Analytics Twitch',
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
            color: const Color(0xFF9146FF).withAlpha(38),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF9146FF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: Color(0xFF9146FF),
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

  Widget _buildStreamInfo(TwitchStreamMetrics m) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF14141C).withAlpha(217),
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
                    color: const Color(0xFF1E1E2A),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9146FF).withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Twitch',
                            style: TextStyle(
                              color: Color(0xFF9146FF),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (m.gameName.isNotEmpty)
                          Flexible(
                            child: Text(
                              m.gameName,
                              style: const TextStyle(
                                color: Color(0xFF8B949E),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
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

  Widget _buildMetricsGrid(TwitchStreamMetrics m) {
    final cards = [
      _MetricCard(
        icon: Icons.remove_red_eye_outlined,
        label: 'Viewers',
        value: _fmt(m.concurrentViewers),
        accent: const Color(0xFF9146FF),
        trend: '+5.2%',
        trendUp: true,
      ),
      _MetricCard(
        icon: Icons.favorite_outline,
        label: 'Followers',
        value: _fmt(m.totalFollowers),
        accent: const Color(0xFFE91916),
        trend: '+1.8%',
        trendUp: true,
      ),
      _MetricCard(
        icon: Icons.chat_bubble_outline,
        label: 'Msgs/min',
        value: m.chatMessagesPerMin.toString(),
        accent: const Color(0xFFFFD60A),
        trend: '-3%',
        trendUp: false,
      ),
      _MetricCard(
        icon: Icons.diamond_outlined,
        label: 'Bits',
        value: _fmt(m.bitsTotal),
        accent: const Color(0xFF30D158),
        trend: '+12%',
        trendUp: true,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: cards
          .map(
            (c) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.accent.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.accent.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(c.icon, color: c.accent, size: 16),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (c.trendUp
                                      ? const Color(0xFF30D158)
                                      : const Color(0xFFFF453A))
                                  .withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.trend,
                          style: TextStyle(
                            color: c.trendUp
                                ? const Color(0xFF30D158)
                                : const Color(0xFFFF453A),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.value,
                        style: TextStyle(
                          color: c.accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        c.label,
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildViewerChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Viewers en Tiempo Real',
            style: TextStyle(
              color: Color(0xFFE6EDF3),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: _viewerHistory.isEmpty
                ? const Center(
                    child: Text(
                      'Cargando datos...',
                      style: TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                    ),
                  )
                : CustomPaint(
                    painter: _SparklinePainter(
                      _viewerHistory,
                      const Color(0xFF9146FF),
                    ),
                    size: const Size(double.infinity, 80),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBitsSection(TwitchStreamMetrics m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💎', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text(
                'Bits & Donaciones',
                style: TextStyle(
                  color: Color(0xFFE6EDF3),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBitsStat(
                  'Total Bits',
                  _fmt(m.bitsTotal),
                  const Color(0xFFFFD700),
                ),
              ),
              Expanded(
                child: _buildBitsStat(
                  'Clips',
                  m.clipCount.toString(),
                  const Color(0xFF9146FF),
                ),
              ),
              Expanded(
                child: _buildBitsStat(
                  'Nuevos Follows',
                  m.newFollowers.toString(),
                  const Color(0xFFE91916),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBitsStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B949E),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEngagementRate(TwitchStreamMetrics m) {
    final rate = m.concurrentViewers > 0
        ? ((m.chatMessagesPerMin / m.concurrentViewers) * 100).clamp(0.0, 100.0)
        : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tasa de Engagement',
            style: TextStyle(
              color: Color(0xFFE6EDF3),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${rate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFF9146FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: rate / 100,
                        backgroundColor: const Color(0xFF1E1E2A),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF9146FF),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'msgs/min por viewer',
                      style: TextStyle(color: Color(0xFF8B949E), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
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

class _MetricCard {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final String trend;
  final bool trendUp;
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.trend,
    required this.trendUp,
  });
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  const _SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final minV = data.reduce((a, b) => a < b ? a : b);
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 1 ? 1.0 : maxV - minV;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withAlpha(80), color.withAlpha(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.data != data;
}
