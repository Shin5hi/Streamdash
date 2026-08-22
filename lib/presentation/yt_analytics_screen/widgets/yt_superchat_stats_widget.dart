import 'dart:ui';

import '../../../core/app_export.dart';

class YtSuperChatStatsWidget extends StatelessWidget {
  final int count;
  final double revenue;
  const YtSuperChatStatsWidget({
    required this.count,
    required this.revenue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD60A).withAlpha(20),
                const Color(0xFF161B22).withAlpha(217),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD60A).withAlpha(51)),
          ),
          child: Row(
            children: [
              const Text('💰', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Super Chats',
                      style: TextStyle(
                        color: Color(0xFFFFD60A),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count received this stream',
                      style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€${revenue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFFFD60A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'total revenue',
                    style: TextStyle(color: Color(0xFF8B949E), fontSize: 10),
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
