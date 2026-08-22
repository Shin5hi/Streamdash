import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

/// YouTube Live Stream data models and real YouTube Data API v3 service

class YTLiveChatMessage {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String message;
  final DateTime publishedAt;
  final bool isModerator;
  final bool isOwner;
  final bool isSuperChat;
  final double? superChatAmount;
  final Color? superChatColor;
  final List<String> emojis;

  const YTLiveChatMessage({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.message,
    required this.publishedAt,
    this.isModerator = false,
    this.isOwner = false,
    this.isSuperChat = false,
    this.superChatAmount,
    this.superChatColor,
    this.emojis = const [],
  });
}

class YTStreamMetrics {
  final int concurrentViewers;
  final int totalLikes;
  final int totalComments;
  final int newSubscribers;
  final int superChatCount;
  final double superChatRevenue;
  final String streamDuration;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final bool isLive;

  const YTStreamMetrics({
    required this.concurrentViewers,
    required this.totalLikes,
    required this.totalComments,
    required this.newSubscribers,
    required this.superChatCount,
    required this.superChatRevenue,
    required this.streamDuration,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.isLive,
  });
}

class YTChannelInfo {
  final String channelId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int subscriberCount;
  final int videoCount;
  final int viewCount;
  final String customUrl;

  const YTChannelInfo({
    required this.channelId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.subscriberCount,
    required this.videoCount,
    required this.viewCount,
    required this.customUrl,
  });
}

class YTRecordedStream {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final DateTime publishedAt;
  final int viewCount;
  final int likeCount;
  final String duration;
  final bool isLive;

  const YTRecordedStream({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.viewCount,
    required this.likeCount,
    required this.duration,
    required this.isLive,
  });
}

class YTBotCommand {
  final String trigger;
  final String response;
  final String category;
  final bool enabled;
  final int usageCount;

  const YTBotCommand({
    required this.trigger,
    required this.response,
    required this.category,
    this.enabled = true,
    this.usageCount = 0,
  });

  YTBotCommand copyWith({bool? enabled}) => YTBotCommand(
    trigger: trigger,
    response: response,
    category: category,
    enabled: enabled ?? this.enabled,
    usageCount: usageCount,
  );
}

class YouTubeService {
  static final YouTubeService _instance = YouTubeService._internal();
  factory YouTubeService() => _instance;
  YouTubeService._internal();

  static const String _apiKey = String.fromEnvironment('YOUTUBE_API_KEY');
  static const String _channelId = String.fromEnvironment('YOUTUBE_CHANNEL_ID');
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Stream controllers for live updates
  final _chatController = StreamController<YTLiveChatMessage>.broadcast();
  final _metricsController = StreamController<YTStreamMetrics>.broadcast();

  Stream<YTLiveChatMessage> get chatStream => _chatController.stream;
  Stream<YTStreamMetrics> get metricsStream => _metricsController.stream;

  Timer? _chatTimer;
  Timer? _metricsTimer;
  int _msgIndex = 0;

  // Cached data
  YTChannelInfo? _cachedChannelInfo;
  YTStreamMetrics? _cachedMetrics;
  String? _activeLiveVideoId;

  bool get hasApiKey =>
      _apiKey.isNotEmpty && _apiKey != 'YOUR_YOUTUBE_API_KEY_HERE';
  bool get hasChannelId =>
      _channelId.isNotEmpty && _channelId != 'YOUR_CHANNEL_ID_HERE';

  // ─── Channel Metadata ────────────────────────────────────────────────────────

  /// Fetch real channel metadata: title, description, thumbnail, subscriber count, video count
  Future<YTChannelInfo?> fetchChannelInfo() async {
    if (!hasApiKey) return null;

    try {
      final channelParam = hasChannelId ? 'id=$_channelId' : 'mine=true';
      final response = await _dio.get(
        '/channels',
        queryParameters: {
          'part': 'snippet,statistics',
          if (hasChannelId) 'id': _channelId,
          if (!hasChannelId) 'mine': true,
          'key': _apiKey,
        },
      );

      final items = response.data['items'] as List?;
      if (items == null || items.isEmpty) return null;

      final item = items[0];
      final snippet = item['snippet'] as Map<String, dynamic>;
      final stats = item['statistics'] as Map<String, dynamic>;

      _cachedChannelInfo = YTChannelInfo(
        channelId: item['id'] as String,
        title: snippet['title'] as String? ?? '',
        description: snippet['description'] as String? ?? '',
        thumbnailUrl:
            (snippet['thumbnails']?['high']?['url'] ??
                    snippet['thumbnails']?['medium']?['url'] ??
                    snippet['thumbnails']?['default']?['url'] ??
                    '')
                as String,
        subscriberCount:
            int.tryParse(stats['subscriberCount']?.toString() ?? '0') ?? 0,
        videoCount: int.tryParse(stats['videoCount']?.toString() ?? '0') ?? 0,
        viewCount: int.tryParse(stats['viewCount']?.toString() ?? '0') ?? 0,
        customUrl: snippet['customUrl'] as String? ?? '',
      );

      return _cachedChannelInfo;
    } on DioException catch (e) {
      debugPrint(
        'YouTube API error (channels): ${e.response?.data ?? e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('YouTube fetchChannelInfo error: $e');
      return null;
    }
  }

  // ─── Live Stream Detection ────────────────────────────────────────────────────

  /// Search for an active live broadcast on the channel
  Future<Map<String, dynamic>?> _findActiveLiveBroadcast() async {
    if (!hasApiKey || !hasChannelId) return null;

    try {
      // Search for live videos on the channel
      final searchResp = await _dio.get(
        '/search',
        queryParameters: {
          'part': 'id,snippet',
          'channelId': _channelId,
          'eventType': 'live',
          'type': 'video',
          'key': _apiKey,
          'maxResults': 1,
        },
      );

      final items = searchResp.data['items'] as List?;
      if (items == null || items.isEmpty) return null;

      final videoId = items[0]['id']?['videoId'] as String?;
      if (videoId == null) return null;

      _activeLiveVideoId = videoId;

      // Fetch detailed video info including liveStreamingDetails
      final videoResp = await _dio.get(
        '/videos',
        queryParameters: {
          'part': 'snippet,statistics,liveStreamingDetails',
          'id': videoId,
          'key': _apiKey,
        },
      );

      final videoItems = videoResp.data['items'] as List?;
      if (videoItems == null || videoItems.isEmpty) return null;

      return videoItems[0] as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint(
        'YouTube API error (live search): ${e.response?.data ?? e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('YouTube findActiveLiveBroadcast error: $e');
      return null;
    }
  }

  // ─── Live Metrics ─────────────────────────────────────────────────────────────

  /// Fetch real-time metrics for the active live stream
  Future<YTStreamMetrics?> fetchLiveMetrics() async {
    if (!hasApiKey) return null;

    try {
      final liveVideo = await _findActiveLiveBroadcast();

      if (liveVideo != null) {
        final snippet = liveVideo['snippet'] as Map<String, dynamic>;
        final stats = liveVideo['statistics'] as Map<String, dynamic>? ?? {};
        final liveDetails =
            liveVideo['liveStreamingDetails'] as Map<String, dynamic>? ?? {};

        final concurrentViewers =
            int.tryParse(liveDetails['concurrentViewers']?.toString() ?? '0') ??
            0;

        final likeCount =
            int.tryParse(stats['likeCount']?.toString() ?? '0') ?? 0;
        final commentCount =
            int.tryParse(stats['commentCount']?.toString() ?? '0') ?? 0;

        final actualStartTime = liveDetails['actualStartTime'] as String?;
        String duration = '0:00:00';
        if (actualStartTime != null) {
          final start = DateTime.tryParse(actualStartTime);
          if (start != null) {
            final elapsed = DateTime.now().toUtc().difference(start);
            final h = elapsed.inHours;
            final m = elapsed.inMinutes % 60;
            final s = elapsed.inSeconds % 60;
            duration =
                '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
          }
        }

        final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
        final thumbnailUrl =
            (thumbnails['high']?['url'] ??
                    thumbnails['medium']?['url'] ??
                    thumbnails['default']?['url'] ??
                    'https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg')
                as String;

        _cachedMetrics = YTStreamMetrics(
          concurrentViewers: concurrentViewers,
          totalLikes: likeCount,
          totalComments: commentCount,
          newSubscribers: _cachedChannelInfo?.subscriberCount ?? 0,
          superChatCount: 0,
          superChatRevenue: 0,
          streamDuration: duration,
          title: snippet['title'] as String? ?? 'Live Stream',
          channelName: snippet['channelTitle'] as String? ?? '',
          thumbnailUrl: thumbnailUrl,
          isLive: true,
        );

        return _cachedMetrics;
      }

      // No active live stream — return channel stats as offline metrics
      final channelInfo = _cachedChannelInfo ?? await fetchChannelInfo();
      return YTStreamMetrics(
        concurrentViewers: 0,
        totalLikes: 0,
        totalComments: 0,
        newSubscribers: channelInfo?.subscriberCount ?? 0,
        superChatCount: 0,
        superChatRevenue: 0,
        streamDuration: '0:00:00',
        title: channelInfo?.title ?? 'No active stream',
        channelName: channelInfo?.title ?? '',
        thumbnailUrl:
            channelInfo?.thumbnailUrl ??
            'https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg',
        isLive: false,
      );
    } catch (e) {
      debugPrint('YouTube fetchLiveMetrics error: $e');
      return null;
    }
  }

  // ─── Recorded Streams ─────────────────────────────────────────────────────────

  /// Fetch recorded/completed live streams from the channel
  Future<List<YTRecordedStream>> fetchRecordedStreams({
    int maxResults = 10,
  }) async {
    if (!hasApiKey || !hasChannelId) return [];

    try {
      // Search for completed live streams
      final searchResp = await _dio.get(
        '/search',
        queryParameters: {
          'part': 'id,snippet',
          'channelId': _channelId,
          'eventType': 'completed',
          'type': 'video',
          'order': 'date',
          'maxResults': maxResults,
          'key': _apiKey,
        },
      );

      final items = searchResp.data['items'] as List?;
      if (items == null || items.isEmpty) return [];

      final videoIds = items
          .map((item) => item['id']?['videoId'] as String?)
          .where((id) => id != null)
          .join(',');

      if (videoIds.isEmpty) return [];

      // Fetch video details with statistics and content details
      final videoResp = await _dio.get(
        '/videos',
        queryParameters: {
          'part': 'snippet,statistics,contentDetails',
          'id': videoIds,
          'key': _apiKey,
        },
      );

      final videoItems = videoResp.data['items'] as List?;
      if (videoItems == null) return [];

      return videoItems.map((video) {
        final snippet = video['snippet'] as Map<String, dynamic>;
        final stats = video['statistics'] as Map<String, dynamic>? ?? {};
        final contentDetails =
            video['contentDetails'] as Map<String, dynamic>? ?? {};

        final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
        final thumbnailUrl =
            (thumbnails['high']?['url'] ??
                    thumbnails['medium']?['url'] ??
                    thumbnails['default']?['url'] ??
                    '')
                as String;

        final publishedAt =
            DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
            DateTime.now();

        return YTRecordedStream(
          videoId: video['id'] as String,
          title: snippet['title'] as String? ?? 'Untitled',
          thumbnailUrl: thumbnailUrl,
          publishedAt: publishedAt,
          viewCount: int.tryParse(stats['viewCount']?.toString() ?? '0') ?? 0,
          likeCount: int.tryParse(stats['likeCount']?.toString() ?? '0') ?? 0,
          duration: _parseIsoDuration(
            contentDetails['duration'] as String? ?? '',
          ),
          isLive: false,
        );
      }).toList();
    } on DioException catch (e) {
      debugPrint(
        'YouTube API error (recorded streams): ${e.response?.data ?? e.message}',
      );
      return [];
    } catch (e) {
      debugPrint('YouTube fetchRecordedStreams error: $e');
      return [];
    }
  }

  /// Parse ISO 8601 duration (PT1H2M3S) to human-readable string
  String _parseIsoDuration(String iso) {
    if (iso.isEmpty) return '0:00';
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(iso);
    if (match == null) return '0:00';
    final h = int.tryParse(match.group(1) ?? '0') ?? 0;
    final m = int.tryParse(match.group(2) ?? '0') ?? 0;
    final s = int.tryParse(match.group(3) ?? '0') ?? 0;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // ─── Polling / Streams ────────────────────────────────────────────────────────

  /// Start polling real YouTube metrics every 30 seconds
  void startRealTimePolling() {
    _metricsTimer?.cancel();
    _fetchAndEmitMetrics();
    _metricsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchAndEmitMetrics();
    });

    // Keep mock chat for live chat widget (YouTube Live Chat API requires OAuth)
    _startMockChat();
  }

  Future<void> _fetchAndEmitMetrics() async {
    final metrics = await fetchLiveMetrics();
    if (metrics != null && !_metricsController.isClosed) {
      _metricsController.add(metrics);
    }
  }

  void stopPolling() {
    _chatTimer?.cancel();
    _metricsTimer?.cancel();
  }

  // ─── Mock Chat (kept for live chat widget) ────────────────────────────────────

  void _startMockChat() {
    _chatTimer?.cancel();
    _chatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final msg = _mockMessages[_msgIndex % _mockMessages.length];
      _msgIndex++;
      final isSuperChat = msg['isSuperChat'] == true;
      _chatController.add(
        YTLiveChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          authorName: msg['author'] as String,
          authorAvatarUrl: msg['avatar'] as String,
          message: msg['message'] as String,
          publishedAt: DateTime.now(),
          isModerator: msg['isModerator'] as bool? ?? false,
          isSuperChat: isSuperChat,
          superChatAmount: isSuperChat
              ? (msg['superChatAmount'] as double?)
              : null,
          superChatColor: isSuperChat ? const Color(0xFFFFD60A) : null,
        ),
      );
    });
  }

  /// Legacy method kept for backward compatibility
  void startMockStream() => startRealTimePolling();
  void stopMockStream() => stopPolling();

  static const List<Map<String, dynamic>> _mockMessages = [
    {
      'author': 'TechWithAhmad',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1dbd4216c-1781236037715.png',
      'message': '🔥 This stream is insane! Keep it up!',
      'isModerator': true,
    },
    {
      'author': 'StreamerFanSofia',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1edf0cd96-1775002085658.png',
      'message': '¡Increíble directo! 🎉🎉',
      'isModerator': false,
    },
    {
      'author': 'NightOwlGamer',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_16e0e9418-1772804601301.png',
      'message': 'What GPU are you using? The graphics look amazing 👀',
      'isModerator': false,
    },
    {
      'author': 'ZaraPlays',
      'avatar': 'https://images.unsplash.com/photo-1646577546835-7cd645c46218',
      'message': 'LETS GOOO 🎉🎉🎉 first time here!',
      'isModerator': false,
    },
    {
      'author': 'DevMarcelo',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_12ed63b61-1780413005585.png',
      'message': 'Can you explain how the bot integration works?',
      'isModerator': false,
    },
    {
      'author': 'Priya_Watches',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1905ef3d7-1763299465501.png',
      'message': 'First time watching — amazing content! 💯',
      'isModerator': false,
    },
    {
      'author': 'SuperFan_Carlos',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1f2454cdd-1766988361399.png',
      'message': '💰 Super Chat: Keep it up streamer!',
      'isModerator': false,
      'isSuperChat': true,
      'superChatAmount': 5.00,
    },
    {
      'author': 'xXModeratorXx',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1432fb18d-1765886126250.png',
      'message': 'Cleaned up 3 spam messages 🛡️',
      'isModerator': true,
    },
    {
      'author': 'GamingWithLuis',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_19dc0de1c-1763299821348.png',
      'message': '!socials please! 🙏',
      'isModerator': false,
    },
    {
      'author': 'StreamQueen_Ana',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1a645b44e-1776702606185.png',
      'message': 'New subscriber here! Love the content ❤️',
      'isModerator': false,
    },
  ];

  static const List<YTBotCommand> defaultCommands = [
    YTBotCommand(
      trigger: '!socials',
      response:
          '🌐 Twitter: @streamdash_yt | Discord: discord.gg/streamdash | Instagram: @streamdash',
      category: 'Info',
    ),
    YTBotCommand(
      trigger: '!uptime',
      response: '⏱️ Stream has been live for {uptime}',
      category: 'Info',
    ),
    YTBotCommand(
      trigger: '!discord',
      response: '💬 Join our Discord: discord.gg/streamdash',
      category: 'Community',
    ),
    YTBotCommand(
      trigger: '!shoutout',
      response: '📢 Shoutout to @{user} — go check them out!',
      category: 'Community',
    ),
    YTBotCommand(
      trigger: '!schedule',
      response: '📅 Next stream: Tomorrow at 8PM CET',
      category: 'Info',
    ),
    YTBotCommand(
      trigger: '!lurk',
      response: '👻 {user} is lurking in the shadows...',
      category: 'Fun',
    ),
    YTBotCommand(
      trigger: '!hype',
      response: '🔥🔥🔥 HYPE TRAIN! LETS GOOO! 🔥🔥🔥',
      category: 'Fun',
    ),
    YTBotCommand(
      trigger: '!clip',
      response: '✂️ Clip created! Share it with #StreamDash',
      category: 'Stream',
    ),
  ];

  void dispose() {
    _chatTimer?.cancel();
    _metricsTimer?.cancel();
    _chatController.close();
    _metricsController.close();
  }
}
