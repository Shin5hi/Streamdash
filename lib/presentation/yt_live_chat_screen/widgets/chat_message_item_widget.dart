import '../../../core/app_export.dart';
import '../../../services/youtube_service.dart';

class ChatMessageItemWidget extends StatelessWidget {
  final YTLiveChatMessage message;
  const ChatMessageItemWidget({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    if (message.isSuperChat) return _SuperChatItem(message: message);
    return _NormalChatItem(message: message);
  }
}

class _NormalChatItem extends StatelessWidget {
  final YTLiveChatMessage message;
  const _NormalChatItem({required this.message});

  @override
  Widget build(BuildContext context) {
    final isOwner = message.isOwner;
    final isMod = message.isModerator;

    Color badgeColor = const Color(0xFF8B949E);
    String? badge;
    if (isOwner) {
      badgeColor = const Color(0xFFFF3B30);
      badge = 'STREAMER';
    } else if (isMod) {
      badgeColor = const Color(0xFF0A84FF);
      badge = 'MOD';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(url: message.authorAvatarUrl, isOwner: isOwner, isMod: isMod),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.authorName,
                      style: TextStyle(
                        color: isOwner
                            ? const Color(0xFFFF3B30)
                            : isMod
                            ? const Color(0xFF0A84FF)
                            : const Color(0xFFE6EDF3),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withAlpha(38),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: badgeColor.withAlpha(102)),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _formatTime(message.publishedAt),
                      style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  message.message,
                  style: const TextStyle(
                    color: Color(0xFFB8C4CE),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SuperChatItem extends StatelessWidget {
  final YTLiveChatMessage message;
  const _SuperChatItem({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD60A).withAlpha(38),
            const Color(0xFFFF9500).withAlpha(25),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD60A).withAlpha(102)),
      ),
      child: Row(
        children: [
          const Text('💰', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.authorName,
                      style: const TextStyle(
                        color: Color(0xFFFFD60A),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (message.superChatAmount != null)
                      Text(
                        '€${message.superChatAmount!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFFFD60A),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  message.message,
                  style: const TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final bool isOwner;
  final bool isMod;
  const _Avatar({
    required this.url,
    required this.isOwner,
    required this.isMod,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isOwner
        ? const Color(0xFFFF3B30)
        : isMod
        ? const Color(0xFF0A84FF)
        : Colors.transparent;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ClipOval(
        child: url.isEmpty
            ? Container(
                color: const Color(0xFF21262D),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF8B949E),
                  size: 16,
                ),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFF21262D),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF8B949E),
                    size: 16,
                  ),
                ),
              ),
      ),
    );
  }
}
