import 'dart:async';

import '../../core/app_export.dart';
import '../../services/youtube_service.dart';
import './widgets/chat_message_item_widget.dart';
import './widgets/emoji_reaction_bar_widget.dart';
import './widgets/superchat_banner_widget.dart';

class YtLiveChatScreen extends StatefulWidget {
  const YtLiveChatScreen({super.key});

  @override
  State<YtLiveChatScreen> createState() => _YtLiveChatScreenState();
}

class _YtLiveChatScreenState extends State<YtLiveChatScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _msgController = TextEditingController();
  final List<YTLiveChatMessage> _messages = [];
  final List<_FloatingEmoji> _floatingEmojis = [];
  StreamSubscription<YTLiveChatMessage>? _chatSub;
  bool _autoScroll = true;
  YTLiveChatMessage? _activeSuperChat;
  Timer? _superChatTimer;

  static const List<String> _quickEmojis = [
    '🔥',
    '❤️',
    '😂',
    '👏',
    '🎉',
    '💯',
    '😍',
    '🚀',
    '👀',
    '💪',
  ];

  @override
  void initState() {
    super.initState();
    YouTubeService().startMockStream();
    _chatSub = YouTubeService().chatStream.listen(_onNewMessage);
  }

  void _onNewMessage(YTLiveChatMessage msg) {
    if (!mounted) return;
    setState(() {
      _messages.insert(0, msg);
      if (_messages.length > 100) _messages.removeLast();
      if (msg.isSuperChat) {
        _activeSuperChat = msg;
        _superChatTimer?.cancel();
        _superChatTimer = Timer(const Duration(seconds: 8), () {
          if (mounted) setState(() => _activeSuperChat = null);
        });
      }
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

  void _sendEmoji(String emoji) {
    setState(() {
      _floatingEmojis.add(
        _FloatingEmoji(emoji: emoji, id: DateTime.now().millisecondsSinceEpoch),
      );
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _floatingEmojis.removeWhere(
            (e) => e.id == _floatingEmojis.firstOrNull?.id,
          );
        });
      }
    });
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    final msg = YTLiveChatMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'You (Streamer)',
      authorAvatarUrl: '',
      message: text,
      publishedAt: DateTime.now(),
      isOwner: true,
    );
    setState(() {
      _messages.insert(0, msg);
    });
    _msgController.clear();
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    _superChatTimer?.cancel();
    _scrollController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              if (_activeSuperChat != null)
                SuperChatBannerWidget(message: _activeSuperChat!),
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          left: 12,
                          right: 12,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) =>
                            ChatMessageItemWidget(message: _messages[i]),
                      ),
              ),
              EmojiReactionBarWidget(
                emojis: _quickEmojis,
                onEmojiTap: _sendEmoji,
              ),
              _buildInputBar(),
            ],
          ),
          // Floating emoji animations
          ..._floatingEmojis.map((fe) => _FloatingEmojiWidget(data: fe)),
        ],
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
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B30),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Live Chat',
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
                  ? const Color(0xFF30D158).withAlpha(38)
                  : const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _autoScroll
                    ? const Color(0xFF30D158).withAlpha(102)
                    : const Color(0x1AFFFFFF),
              ),
            ),
            child: Text(
              _autoScroll ? '⏸ Pause' : '▶ Live',
              style: TextStyle(
                color: _autoScroll
                    ? const Color(0xFF30D158)
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('💬', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text(
            'Waiting for chat messages...',
            style: TextStyle(color: Color(0xFF8B949E), fontSize: 14),
          ),
        ],
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
        color: Color(0xFF161B22),
        border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Reply to chat...',
                hintStyle: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFF21262D),
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
                color: const Color(0xFFFF3B30),
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

class _FloatingEmoji {
  final String emoji;
  final int id;
  _FloatingEmoji({required this.emoji, required this.id});
}

class _FloatingEmojiWidget extends StatefulWidget {
  final _FloatingEmoji data;
  const _FloatingEmojiWidget({required this.data});

  @override
  State<_FloatingEmojiWidget> createState() => _FloatingEmojiWidgetState();
}

class _FloatingEmojiWidgetState extends State<_FloatingEmojiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _y;
  final double _xPos = 20 + (40.0 * (DateTime.now().millisecond % 10) / 10);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_ctrl);
    _y = Tween(
      begin: 0.0,
      end: -180.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: _xPos,
      bottom: 120,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _y.value),
          child: Opacity(
            opacity: _opacity.value,
            child: Text(
              widget.data.emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      ),
    );
  }
}
