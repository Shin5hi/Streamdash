import 'dart:async';

import '../../core/app_export.dart';
import '../../services/twitch_service.dart';

class TwitchLiveChatScreen extends StatefulWidget {
  const TwitchLiveChatScreen({super.key});

  @override
  State<TwitchLiveChatScreen> createState() => _TwitchLiveChatScreenState();
}

class _TwitchLiveChatScreenState extends State<TwitchLiveChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _msgController = TextEditingController();
  final List<TwitchChatMessage> _messages = [];
  StreamSubscription<TwitchChatMessage>? _chatSub;
  bool _autoScroll = true;

  static const List<String> _quickEmojis = [
    'PogChamp',
    'LUL',
    'Kappa',
    '🔥',
    '❤️',
    '😂',
    '👏',
    '🎉',
    '💯',
    'KEKW',
  ];

  @override
  void initState() {
    super.initState();
    TwitchService().startMockChatStream();
    _chatSub = TwitchService().chatStream.listen(_onNewMessage);
  }

  void _onNewMessage(TwitchChatMessage msg) {
    if (!mounted) return;
    setState(() {
      _messages.insert(0, msg);
      if (_messages.length > 100) _messages.removeLast();
    });
    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    final msg = TwitchChatMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Streamer',
      authorAvatarUrl: '',
      message: text,
      publishedAt: DateTime.now(),
      isOwner: true,
      badgeColor: const Color(0xFF9146FF),
    );
    setState(() => _messages.insert(0, msg));
    _msgController.clear();
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    _scrollController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('💬', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'Esperando mensajes del chat...',
                          style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _buildMessageItem(_messages[i]),
                  ),
          ),
          _buildEmojiBar(),
          _buildInputBar(),
        ],
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
      title: Row(
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
            'Chat Twitch',
            style: TextStyle(
              color: Color(0xFFE6EDF3),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _autoScroll = !_autoScroll),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _autoScroll
                  ? const Color(0xFF9146FF).withAlpha(38)
                  : const Color(0xFF1E1E2A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _autoScroll
                    ? const Color(0xFF9146FF).withAlpha(102)
                    : const Color(0x1AFFFFFF),
              ),
            ),
            child: Text(
              _autoScroll ? '⏸ Pausar' : '▶ En Vivo',
              style: TextStyle(
                color: _autoScroll
                    ? const Color(0xFF9146FF)
                    : const Color(0xFF8B949E),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(TwitchChatMessage msg) {
    Color nameColor = msg.isOwner
        ? const Color(0xFFFFD700)
        : msg.isModerator
        ? const Color(0xFF00AD03)
        : msg.isSubscriber
        ? const Color(0xFF9146FF)
        : const Color(0xFF8B949E);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (msg.authorAvatarUrl.isNotEmpty)
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: msg.authorAvatarUrl,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF9146FF).withAlpha(60),
                  child: Text(
                    msg.authorName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF9146FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
          else
            CircleAvatar(
              radius: 14,
              backgroundColor: nameColor.withAlpha(40),
              child: Text(
                msg.authorName[0].toUpperCase(),
                style: TextStyle(
                  color: nameColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (msg.isModerator)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.shield,
                          color: Color(0xFF00AD03),
                          size: 12,
                        ),
                      ),
                    if (msg.isSubscriber)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.star,
                          color: Color(0xFF9146FF),
                          size: 12,
                        ),
                      ),
                    if (msg.isOwner)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.verified,
                          color: Color(0xFFFFD700),
                          size: 12,
                        ),
                      ),
                    Text(
                      msg.authorName,
                      style: TextStyle(
                        color: nameColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (msg.bitsAmount != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '💎 ${msg.bitsAmount} bits',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  msg.message,
                  style: const TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiBar() {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFF14141C),
        border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _quickEmojis.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            _msgController.text += ' ${_quickEmojis[i]}';
            _msgController.selection = TextSelection.fromPosition(
              TextPosition(offset: _msgController.text.length),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF9146FF).withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF9146FF).withAlpha(60)),
            ),
            child: Text(
              _quickEmojis[i],
              style: const TextStyle(
                color: Color(0xFF9146FF),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF14141C),
        border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Escribe en el chat...',
                hintStyle: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E2A),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9146FF), Color(0xFF6441A5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
