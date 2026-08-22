import 'dart:ui';

import '../../../core/app_export.dart';

class _ChatMessage {
  final String username;
  final String message;
  final String timestamp;
  final String avatarUrl;
  final String avatarSemanticLabel;
  final bool isModerator;
  final bool isHighlighted;
  final Color? badgeColor;

  const _ChatMessage({
    required this.username,
    required this.message,
    required this.timestamp,
    required this.avatarUrl,
    required this.avatarSemanticLabel,
    this.isModerator = false,
    this.isHighlighted = false,
    this.badgeColor,
  });
}

class StreamChatFeedWidget extends StatefulWidget {
  final bool isLive;
  final bool compact;
  const StreamChatFeedWidget({
    required this.isLive,
    this.compact = false,
    super.key,
  });

  @override
  State<StreamChatFeedWidget> createState() => _StreamChatFeedWidgetState();
}

class _StreamChatFeedWidgetState extends State<StreamChatFeedWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  static final List<Map<String, dynamic>> _messageMaps = [
    {
      'username': 'TechWithAhmad',
      'message': '🔥 This stream is insane! Keep it up!',
      'timestamp': '20:18',
      'avatarUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_19dc0de1c-1763299821348.png',
      'avatarSemanticLabel': 'Young South Asian man with dark hair smiling',
      'isModerator': true,
      'isHighlighted': false,
      'badgeColor': 0xFF0A84FF,
    },
    {
      'username': 'StreamerFanSofia',
      'message': 'Can you do a !shoutout for my channel?',
      'timestamp': '20:18',
      'avatarUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_12b6af109-1772367723919.png',
      'avatarSemanticLabel': 'Young Latina woman with curly brown hair',
      'isModerator': false,
      'isHighlighted': true,
      'badgeColor': null,
    },
    {
      'username': 'NightOwlGamer',
      'message': 'What GPU are you using? The graphics look amazing',
      'timestamp': '20:17',
      'avatarUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1e5ee34f4-1763296128758.png',
      'avatarSemanticLabel': 'East Asian man with glasses smiling',
      'isModerator': false,
      'isHighlighted': false,
      'badgeColor': null,
    },
    {
      'username': 'BotStream_v2',
      'message':
          '🤖 !socials → Follow on Twitter: @streamdash_yt | Discord: discord.gg/streamdash',
      'timestamp': '20:17',
      'avatarUrl': '',
      'avatarSemanticLabel': 'Bot icon representing automated chat response',
      'isModerator': false,
      'isHighlighted': false,
      'badgeColor': 0xFF30D158,
    },
    {
      'username': 'Priya_Watches',
      'message': 'First time watching — this is amazing content!',
      'timestamp': '20:16',
      'avatarUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1afca3261-1772901906032.png',
      'avatarSemanticLabel':
          'South Asian woman with long black hair in casual attire',
      'isModerator': false,
      'isHighlighted': false,
      'badgeColor': null,
    },
    {
      'username': 'xXModeratorXx',
      'message': 'Cleaned up 3 spam messages 🛡️',
      'timestamp': '20:16',
      'avatarUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1d5dc0229-1780241787306.png',
      'avatarSemanticLabel': 'Black man with beard in dark shirt',
      'isModerator': true,
      'isHighlighted': false,
      'badgeColor': 0xFFFFD60A,
    },
    {
      'username': 'DevMarcelo',
      'message': 'Can you explain how the bot integration works?',
      'timestamp': '20:15',
      'avatarUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1714e01f0-1772870807779.png',
      'avatarSemanticLabel':
          'White man with short brown hair and friendly expression',
      'isModerator': false,
      'isHighlighted': false,
      'badgeColor': null,
    },
    {
      'username': 'ZaraPlays',
      'message': 'LETS GOOO 2847 viewers!! 🎉🎉🎉',
      'timestamp': '20:15',
      'avatarUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_153f63fbd-1772079974830.png',
      'avatarSemanticLabel':
          'Young Black woman with natural hair smiling excitedly',
      'isModerator': false,
      'isHighlighted': false,
      'badgeColor': null,
    },
  ];

  late List<_ChatMessage> _messages;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messages = _messageMaps
        .map(
          (m) => _ChatMessage(
            username: m['username'] as String,
            message: m['message'] as String,
            timestamp: m['timestamp'] as String,
            avatarUrl: m['avatarUrl'] as String,
            avatarSemanticLabel: m['avatarSemanticLabel'] as String,
            isModerator: m['isModerator'] as bool,
            isHighlighted: m['isHighlighted'] as bool,
            badgeColor: m['badgeColor'] != null
                ? Color(m['badgeColor'] as int)
                : null,
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = widget.compact;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161B22).withAlpha(217),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
            ),
            child: Column(
              children: [
                _buildHeader(compact: compact),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                Expanded(
                  child: _messages.isEmpty
                      ? const EmptyStateWidget(
                          iconName: 'chat_bubble',
                          title: 'No chat messages yet',
                          subtitle:
                              'Messages will appear here when the stream goes live',
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) => _ChatMessageItem(
                            message: _messages[i],
                            compact: compact,
                          ),
                        ),
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                _buildReplyBar(compact: compact),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({bool compact = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'chat_bubble',
            color: const Color(0xFF0A84FF),
            size: compact ? 13 : 15,
          ),
          const SizedBox(width: 8),
          Text(
            'Live Chat',
            style: TextStyle(
              color: const Color(0xFFE6EDF3),
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0A84FF).withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_messages.length}',
              style: TextStyle(
                color: const Color(0xFF0A84FF),
                fontSize: compact ? 9 : 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _autoScroll = !_autoScroll),
            child: Text(
              _autoScroll ? '⏸ Pause' : '▶ Resume',
              style: TextStyle(
                color: const Color(0xFF8B949E),
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBar({bool compact = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: compact ? 30 : 36,
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
              ),
              child: TextField(
                controller: _replyController,
                style: TextStyle(
                  color: const Color(0xFFE6EDF3),
                  fontSize: compact ? 11 : 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Send a message...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF8B949E),
                    fontSize: compact ? 10 : 12,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: compact ? 6 : 8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: compact ? 30 : 36,
            height: compact ? 30 : 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B30),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                // TODO: Connect to YouTube Live Chat API
                _replyController.clear();
              },
              icon: CustomIconWidget(
                iconName: 'send',
                color: Colors.white,
                size: compact ? 13 : 16,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageItem extends StatelessWidget {
  final _ChatMessage message;
  final bool compact;
  const _ChatMessageItem({required this.message, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isBotMessage = message.username.toLowerCase().contains('bot');
    final double avatarSize = compact ? 22 : 28;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 3,
      ),
      padding: EdgeInsets.all(compact ? 6 : 10),
      decoration: BoxDecoration(
        color: message.isHighlighted
            ? const Color(0xFFFFD60A).withAlpha(15)
            : isBotMessage
            ? const Color(0xFF30D158).withAlpha(13)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: message.isHighlighted
            ? Border.all(color: const Color(0xFFFFD60A).withAlpha(51), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(avatarSize / 2),
            child: message.avatarUrl.isEmpty
                ? Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF30D158).withAlpha(38),
                      borderRadius: BorderRadius.circular(avatarSize / 2),
                    ),
                    child: CustomIconWidget(
                      iconName: 'smart_toy',
                      color: const Color(0xFF30D158),
                      size: compact ? 12 : 16,
                    ),
                  )
                : CustomImageWidget(
                    imageUrl: message.avatarUrl,
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.cover,
                    semanticLabel: message.avatarSemanticLabel,
                  ),
          ),
          SizedBox(width: compact ? 5 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        message.username,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              message.badgeColor ??
                              (message.isModerator
                                  ? const Color(0xFF0A84FF)
                                  : const Color(0xFFE6EDF3)),
                          fontSize: compact ? 10 : 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (message.isModerator) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A84FF).withAlpha(38),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'MOD',
                          style: TextStyle(
                            color: const Color(0xFF0A84FF),
                            fontSize: compact ? 7 : 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      message.timestamp,
                      style: TextStyle(
                        color: const Color(0xFF8B949E),
                        fontSize: compact ? 8 : 10,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 1 : 2),
                Text(
                  message.message,
                  style: TextStyle(
                    color: const Color(0xFFB8C4CE),
                    fontSize: compact ? 10 : 12,
                    fontWeight: FontWeight.w400,
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
