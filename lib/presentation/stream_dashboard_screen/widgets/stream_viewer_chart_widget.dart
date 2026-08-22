import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';

import '../../../core/app_export.dart';

class StreamViewerChartWidget extends StatefulWidget {
  final bool isLive;
  const StreamViewerChartWidget({required this.isLive, super.key});

  @override
  State<StreamViewerChartWidget> createState() =>
      _StreamViewerChartWidgetState();
}

class _StreamViewerChartWidgetState extends State<StreamViewerChartWidget> {
  // Mock viewer data over the last 30 minutes (6 data points, 5-min intervals)
  final List<FlSpot> _viewerSpots = const [
    FlSpot(0, 1200),
    FlSpot(5, 1580),
    FlSpot(10, 2100),
    FlSpot(15, 1870),
    FlSpot(20, 2400),
    FlSpot(25, 2847),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0A84FF);
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
                      iconName: 'bar_chart',
                      color: primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Viewer Trend (30 min)',
                      style: TextStyle(
                        color: Color(0xFFE6EDF3),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (widget.isLive)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF30D158),
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (widget.isLive) ...[
                      const SizedBox(width: 4),
                      const Text(
                        'Live',
                        style: TextStyle(
                          color: Color(0xFF30D158),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 500,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: const Color(0x1AFFFFFF),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1000,
                            reservedSize: 36,
                            getTitlesWidget: (v, _) => Text(
                              '${(v / 1000).toStringAsFixed(0)}K',
                              style: const TextStyle(
                                color: Color(0xFF8B949E),
                                fontSize: 10,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}m',
                              style: const TextStyle(
                                color: Color(0xFF8B949E),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _viewerSpots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: primary,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                primary.withAlpha(64),
                                primary.withAlpha(0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: const Color(0xFF21262D),
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (spots) => spots
                              .map(
                                (s) => LineTooltipItem(
                                  '${s.y.toInt()} viewers',
                                  const TextStyle(
                                    color: Color(0xFFE6EDF3),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              .toList(),
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
    );
  }
}
