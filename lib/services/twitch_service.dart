import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

/// Twitch data models and service

class TwitchChatMessage {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String message;
  final DateTime publishedAt;
  final bool isModerator;
  final bool isSubscriber;
  final bool isOwner;
  final Color badgeColor;
  final List<String> emotes;
  final int? bitsAmount;

  const TwitchChatMessage({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.message,
    required this.publishedAt,
    this.isModerator = false,
    this.isSubscriber = false,
    this.isOwner = false,
    this.badgeColor = const Color(0xFF9146FF),
    this.emotes = const [],
    this.bitsAmount,
  });
}

class TwitchStreamMetrics {
  final int concurrentViewers;
  final int totalFollowers;
  final int newFollowers;
  final int chatMessagesPerMin;
  final int bitsTotal;
  final int clipCount;
  final String streamDuration;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final String gameName;
  final bool isLive;

  const TwitchStreamMetrics({
    required this.concurrentViewers,
    required this.totalFollowers,
    required this.newFollowers,
    required this.chatMessagesPerMin,
    required this.bitsTotal,
    required this.clipCount,
    required this.streamDuration,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.gameName,
    required this.isLive,
  });
}

class TwitchChannelInfo {
  final String channelId;
  final String login;
  final String displayName;
  final String description;
  final String profileImageUrl;
  final int followerCount;
  final String broadcasterType;

  const TwitchChannelInfo({
    required this.channelId,
    required this.login,
    required this.displayName,
    required this.description,
    required this.profileImageUrl,
    required this.followerCount,
    required this.broadcasterType,
  });
}

class TwitchPastStream {
  final String id;
  final String title;
  final String thumbnailUrl;
  final DateTime createdAt;
  final int viewCount;
  final String duration;
  final String gameName;

  const TwitchPastStream({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.viewCount,
    required this.duration,
    required this.gameName,
  });
}

class TwitchService {
  static final TwitchService _instance = TwitchService._internal();
  factory TwitchService() => _instance;
  static const String _baseUrl = 'https://api.twitch.tv/helix';

  TwitchService._internal()
    : _clientId = const String.fromEnvironment('TWITCH_CLIENT_ID'),
      _accessToken = const String.fromEnvironment('TWITCH_ACCESS_TOKEN'),
      _channelLogin = const String.fromEnvironment('TWITCH_CHANNEL_LOGIN'),
      _dio = _createDio();

  @visibleForTesting
  TwitchService.forTesting({
    required Dio dio,
    required String clientId,
    required String accessToken,
    required String channelLogin,
  }) : _dio = dio,
       _clientId = clientId,
       _accessToken = accessToken,
       _channelLogin = channelLogin;

  final String _clientId;
  final String _accessToken;
  final String _channelLogin;
  final Dio _dio;

  static Dio _createDio() => Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final _chatController = StreamController<TwitchChatMessage>.broadcast();
  final _metricsController = StreamController<TwitchStreamMetrics>.broadcast();

  Stream<TwitchChatMessage> get chatStream => _chatController.stream;
  Stream<TwitchStreamMetrics> get metricsStream => _metricsController.stream;

  Timer? _chatTimer;
  Timer? _metricsTimer;
  int _msgIndex = 0;

  TwitchChannelInfo? _cachedChannelInfo;
  TwitchStreamMetrics? _cachedMetrics;

  String? get configurationError {
    if (_clientId.trim().isEmpty || _clientId == 'YOUR_TWITCH_CLIENT_ID') {
      return 'Twitch Client ID is not configured.';
    }
    if (_helixAccessToken.isEmpty ||
        _helixAccessToken == 'YOUR_TWITCH_ACCESS_TOKEN') {
      return 'Twitch access token is not configured.';
    }
    return null;
  }

  bool get hasCredentials => configurationError == null;

  bool get hasChannelLogin =>
      _channelLogin.trim().isNotEmpty &&
      _channelLogin != 'YOUR_TWITCH_CHANNEL_LOGIN';

  String get _helixAccessToken {
    final token = _accessToken.trim();
    return token
        .replaceFirst(RegExp(r'^oauth:', caseSensitive: false), '')
        .trim();
  }

  Map<String, String> get _headers => {
    'Client-Id': _clientId,
    'Authorization': 'Bearer $_helixAccessToken',
  };

  // ─── Channel Metadata ────────────────────────────────────────────────────────

  Future<TwitchChannelInfo?> fetchChannelInfo() async {
    if (!hasCredentials || !hasChannelLogin) return null;

    try {
      final resp = await _dio.get(
        '/users',
        queryParameters: {'login': _channelLogin},
        options: Options(headers: _headers),
      );
      final items = resp.data['data'] as List?;
      if (items == null || items.isEmpty) return null;

      final item = items[0] as Map<String, dynamic>;

      // Fetch follower count
      int followers = 0;
      try {
        final fResp = await _dio.get(
          '/channels/followers',
          queryParameters: {'broadcaster_id': item['id']},
          options: Options(headers: _headers),
        );
        followers = fResp.data['total'] as int? ?? 0;
      } catch (_) {}

      _cachedChannelInfo = TwitchChannelInfo(
        channelId: item['id'] as String,
        login: item['login'] as String,
        displayName: item['display_name'] as String,
        description: item['description'] as String? ?? '',
        profileImageUrl: item['profile_image_url'] as String? ?? '',
        followerCount: followers,
        broadcasterType: item['broadcaster_type'] as String? ?? '',
      );
      return _cachedChannelInfo;
    } on DioException catch (e) {
      debugPrint('Twitch API error (users): ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      debugPrint('Twitch fetchChannelInfo error: $e');
      return null;
    }
  }

  // ─── Live Metrics ─────────────────────────────────────────────────────────────

  Future<TwitchStreamMetrics?> fetchLiveMetrics() async {
    if (!hasCredentials || !hasChannelLogin) return null;

    try {
      final resp = await _dio.get(
        '/streams',
        queryParameters: {'user_login': _channelLogin},
        options: Options(headers: _headers),
      );
      final items = resp.data['data'] as List?;
      final isLive = items != null && items.isNotEmpty;

      if (!isLive) {
        _cachedMetrics = TwitchStreamMetrics(
          concurrentViewers: 0,
          totalFollowers: _cachedChannelInfo?.followerCount ?? 0,
          newFollowers: 0,
          chatMessagesPerMin: 0,
          bitsTotal: 0,
          clipCount: 0,
          streamDuration: '0:00:00',
          title: 'Offline',
          channelName: _cachedChannelInfo?.displayName ?? _channelLogin,
          thumbnailUrl: _cachedChannelInfo?.profileImageUrl ?? '',
          gameName: '',
          isLive: false,
        );
        _metricsController.add(_cachedMetrics!);
        return _cachedMetrics;
      }

      final stream = items[0] as Map<String, dynamic>;
      final startedAt = DateTime.tryParse(
        stream['started_at'] as String? ?? '',
      );
      String duration = '0:00:00';
      if (startedAt != null) {
        final diff = DateTime.now().toUtc().difference(startedAt);
        duration =
            '${diff.inHours}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
      }

      // Thumbnail URL: replace {width}x{height} placeholders
      String thumb = (stream['thumbnail_url'] as String? ?? '')
          .replaceAll('{width}', '640')
          .replaceAll('{height}', '360');

      _cachedMetrics = TwitchStreamMetrics(
        concurrentViewers: stream['viewer_count'] as int? ?? 0,
        totalFollowers: _cachedChannelInfo?.followerCount ?? 0,
        newFollowers: 0,
        chatMessagesPerMin: 0,
        bitsTotal: 0,
        clipCount: 0,
        streamDuration: duration,
        title: stream['title'] as String? ?? '',
        channelName: stream['user_name'] as String? ?? _channelLogin,
        thumbnailUrl: thumb,
        gameName: stream['game_name'] as String? ?? '',
        isLive: true,
      );
      _metricsController.add(_cachedMetrics!);
      return _cachedMetrics;
    } on DioException catch (e) {
      debugPrint(
        'Twitch API error (streams): ${e.response?.data ?? e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('Twitch fetchLiveMetrics error: $e');
      return null;
    }
  }

  // ─── Past Streams (Videos) ────────────────────────────────────────────────────

  Future<List<TwitchPastStream>> fetchPastStreams({int maxResults = 15}) async {
    if (!hasCredentials || !hasChannelLogin) return [];

    try {
      // First get user ID
      String userId = _cachedChannelInfo?.channelId ?? '';
      if (userId.isEmpty) {
        final info = await fetchChannelInfo();
        userId = info?.channelId ?? '';
      }
      if (userId.isEmpty) return [];

      final resp = await _dio.get(
        '/videos',
        queryParameters: {
          'user_id': userId,
          'type': 'archive',
          'first': maxResults,
        },
        options: Options(headers: _headers),
      );
      final items = resp.data['data'] as List? ?? [];
      return items.map((v) {
        final thumb = (v['thumbnail_url'] as String? ?? '')
            .replaceAll('%{width}', '640')
            .replaceAll('%{height}', '360');
        return TwitchPastStream(
          id: v['id'] as String,
          title: v['title'] as String? ?? '',
          thumbnailUrl: thumb,
          createdAt:
              DateTime.tryParse(v['created_at'] as String? ?? '') ??
              DateTime.now(),
          viewCount: v['view_count'] as int? ?? 0,
          duration: v['duration'] as String? ?? '',
          gameName: '',
        );
      }).toList();
    } on DioException catch (e) {
      debugPrint('Twitch API error (videos): ${e.response?.data ?? e.message}');
      return [];
    } catch (e) {
      debugPrint('Twitch fetchPastStreams error: $e');
      return [];
    }
  }

  // ─── Real-time polling ────────────────────────────────────────────────────────

  void startRealTimePolling() {
    _metricsTimer?.cancel();
    fetchLiveMetrics();
    _metricsTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchLiveMetrics(),
    );
    startMockChatStream();
  }

  void stopPolling() {
    _metricsTimer?.cancel();
    _chatTimer?.cancel();
  }

  // ─── Mock streams (fallback when no credentials) ──────────────────────────────

  void startMockStream() {
    _chatTimer?.cancel();
    _metricsTimer?.cancel();
    startMockChatStream();
    _startMockMetricsStream();
  }

  void startMockChatStream() {
    _chatTimer?.cancel();
    _chatTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      _chatController.add(_mockMessages[_msgIndex % _mockMessages.length]);
      _msgIndex++;
    });
  }

  void _startMockMetricsStream() {
    final rng = Random();
    int viewers = 3240;
    _metricsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      viewers += rng.nextInt(40) - 18;
      if (viewers < 100) viewers = 100;
      _metricsController.add(
        TwitchStreamMetrics(
          concurrentViewers: viewers,
          totalFollowers: 18450,
          newFollowers: rng.nextInt(8),
          chatMessagesPerMin: 42 + rng.nextInt(20),
          bitsTotal: 1250 + rng.nextInt(100),
          clipCount: 7,
          streamDuration:
              '2:${(rng.nextInt(59)).toString().padLeft(2, '0')}:${(rng.nextInt(59)).toString().padLeft(2, '0')}',
          title: 'Jugando Valorant con subs — !discord !clip',
          channelName: 'StreamDash',
          thumbnailUrl:
              'https://images.pexels.com/photos/3165335/pexels-photo-3165335.jpeg?auto=compress&cs=tinysrgb&w=640',
          gameName: 'Valorant',
          isLive: true,
        ),
      );
    });
  }

  static final List<TwitchChatMessage> _mockMessages = [
    TwitchChatMessage(
      id: 't1',
      authorName: 'xXGamerXx',
      authorAvatarUrl: 'https://i.pravatar.cc/40?img=1',
      message: 'PogChamp qué jugada!!',
      publishedAt: DateTime.now(),
      isSubscriber: true,
      badgeColor: const Color(0xFF9146FF),
    ),
    TwitchChatMessage(
      id: 't2',
      authorName: 'StreamFan99',
      authorAvatarUrl: 'https://i.pravatar.cc/40?img=2',
      message: 'LUL LUL LUL',
      publishedAt: DateTime.now(),
      badgeColor: const Color(0xFF9146FF),
    ),
    TwitchChatMessage(
      id: 't3',
      authorName: 'ModeratorPro',
      authorAvatarUrl: 'https://i.pravatar.cc/40?img=3',
      message: 'Bienvenidos al stream! Recuerda las reglas del chat 🛡️',
      publishedAt: DateTime.now(),
      isModerator: true,
      badgeColor: const Color(0xFF00AD03),
    ),
    TwitchChatMessage(
      id: 't4',
      authorName: 'BitsDonator',
      authorAvatarUrl: 'https://i.pravatar.cc/40?img=4',
      message: 'cheer100 Increíble stream! Sigue así!',
      publishedAt: DateTime.now(),
      bitsAmount: 100,
      badgeColor: const Color(0xFFFFD700),
    ),
    TwitchChatMessage(
      id: 't5',
      authorName: 'SubGifter',
      authorAvatarUrl: 'https://i.pravatar.cc/40?img=5',
      message: 'Acabo de gifted 5 subs! KEKW',
      publishedAt: DateTime.now(),
      isSubscriber: true,
      badgeColor: const Color(0xFF9146FF),
    ),
    TwitchChatMessage(
      id: 't6',
      authorName: 'NightBot',
      authorAvatarUrl: 'https://i.pravatar.cc/40?img=6',
      message: '!discord → discord.gg/streamdash',
      publishedAt: DateTime.now(),
      badgeColor: const Color(0xFF9146FF),
    ),
    TwitchChatMessage(
      id: 't7',
      authorName: 'ViewerAnon',
      authorAvatarUrl: 'https://i.pravatar.cc/40?img=7',
      message: 'Cuándo vas a jugar Fortnite?',
      publishedAt: DateTime.now(),
      badgeColor: const Color(0xFF9146FF),
    ),
    TwitchChatMessage(
      id: 't8',
      authorName: 'HypeTrainer',
      authorAvatarUrl: 'https://i.pravatar.cc/40?img=8',
      message: 'HYPE HYPE HYPE 🔥🔥🔥',
      publishedAt: DateTime.now(),
      isSubscriber: true,
      badgeColor: const Color(0xFF9146FF),
    ),
    TwitchChatMessage(
      id: 't9',
      authorName: 'ClipMaster',
      authorAvatarUrl: 'https://i.pravatar.cc/40?img=9',
      message: '!clip eso fue un clip seguro',
      publishedAt: DateTime.now(),
      badgeColor: const Color(0xFF9146FF),
    ),
    TwitchChatMessage(
      id: 't10',
      authorName: 'RaidLeader',
      authorAvatarUrl: 'https://i.pravatar.cc/40?img=10',
      message: 'Raid incoming de 500 viewers! Prepárense!',
      publishedAt: DateTime.now(),
      isModerator: true,
      badgeColor: const Color(0xFF00AD03),
    ),
  ];
}
