import 'dart:ui';

import '../../../core/app_export.dart';

class StreamMetricsWidget extends StatelessWidget {
  final int concurrentViewers;
  final int totalLikes;
  final int commentsPerMin;
  final int newSubs;

  const StreamMetricsWidget({
    required this.concurrentViewers,
    required this.totalLikes,
    required this.commentsPerMin,
    required this.newSubs,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        icon: 'visibility',
        label: 'Viewers',
        value: _fmt(concurrentViewers),
        trend: '+4.2%',
        trendUp: true,
        accent: const Color(0xFF0A84FF),
      ),
      _MetricData(
        icon: 'thumb_up',
        label: 'Likes',
        value: _fmt(totalLikes),
        trend: '+2.1%',
        trendUp: true,
        accent: const Color(0xFFFF3B30),
      ),
      _MetricData(
        icon: 'chat_bubble',
        label: 'Msgs/min',
        value: commentsPerMin.toString(),
        trend: '-8%',
        trendUp: false,
        accent: const Color(0xFFFFD60A),
      ),
      _MetricData(
        icon: 'group_add',
        label: 'New Subs',
        value: newSubs.toString(),
        trend: '+3',
        trendUp: true,
        accent: const Color(0xFF30D158),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: metrics.map((m) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _MetricCard(data: m),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}

class _MetricData {
  final String icon;
  final String label;
  final String value;
  final String trend;
  final bool trendUp;
  final Color accent;

  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.accent,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withAlpha(217),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomIconWidget(
                iconName: data.icon,
                color: data.accent,
                size: 16,
              ),
              const SizedBox(height: 6),
              Text(
                data.value,
                style: const TextStyle(
                  color: Color(0xFFE6EDF3),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.label,
                style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: data.trendUp ? 'trending_up' : 'trending_up',
                    color: data.trendUp
                        ? const Color(0xFF30D158)
                        : const Color(0xFFFF453A),
                    size: 11,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    data.trend,
                    style: TextStyle(
                      color: data.trendUp
                          ? const Color(0xFF30D158)
                          : const Color(0xFFFF453A),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
