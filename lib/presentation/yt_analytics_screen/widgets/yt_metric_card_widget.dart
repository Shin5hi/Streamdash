import 'dart:ui';

import '../../../core/app_export.dart';

class YtMetricCardData {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final String trend;
  final bool trendUp;

  const YtMetricCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.trend,
    required this.trendUp,
  });
}

class YtMetricCardWidget extends StatelessWidget {
  final YtMetricCardData data;
  const YtMetricCardWidget({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withAlpha(217),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(data.icon, color: data.accent, size: 16),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (data.trendUp
                                  ? const Color(0xFF30D158)
                                  : const Color(0xFFFF453A))
                              .withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          data.trendUp
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: data.trendUp
                              ? const Color(0xFF30D158)
                              : const Color(0xFFFF453A),
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          data.trend,
                          style: TextStyle(
                            color: data.trendUp
                                ? const Color(0xFF30D158)
                                : const Color(0xFFFF453A),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.value,
                    style: const TextStyle(
                      color: Color(0xFFE6EDF3),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    data.label,
                    style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
