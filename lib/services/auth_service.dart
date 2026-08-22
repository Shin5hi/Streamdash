import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyCurrentUser = 'auth_current_user';
  static const String _keyUsersDb = 'auth_users_db';
  static const String _keyYoutubeApiKey = 'yt_api_key';
  static const String _keyYoutubeChannelId = 'yt_channel_id';
  static const String _keyYoutubeChannelName = 'yt_channel_name';
  static const String _keyYoutubeAccessToken = 'yt_access_token';

  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  String _hashPassword(String password) {
    final bytes = utf8.encode('${password}streamdash_salt_2026');
    return sha256.convert(bytes).toString();
  }

  // ─── Registration ───────────────────────────────────────────────────────────

  Future<AuthResult> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final email_ = email.trim().toLowerCase();
    if (!email_.contains('@') || !email_.contains('.')) {
      return AuthResult.failure('Please enter a valid email address.');
    }
    if (password.length < 6) {
      return AuthResult.failure('Password must be at least 6 characters.');
    }

    final usersRaw = prefs.getString(_keyUsersDb);
    final Map<String, dynamic> users = usersRaw != null
        ? jsonDecode(usersRaw) as Map<String, dynamic>
        : {};

    if (users.containsKey(email_)) {
      return AuthResult.failure('An account with this email already exists.');
    }

    users[email_] = {
      'email': email_,
      'passwordHash': _hashPassword(password),
      'displayName': displayName ?? email_.split('@').first,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_keyUsersDb, jsonEncode(users));
    await _setSession(email_, users[email_] as Map<String, dynamic>);

    return AuthResult.success(
      StreamerUser(
        email: email_,
        displayName: users[email_]['displayName'] as String,
      ),
    );
  }

  // ─── Login ───────────────────────────────────────────────────────────────────

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final email_ = email.trim().toLowerCase();

    // Allow built-in demo account
    if (email_ == 'streamer@streamdash.app' && password == 'Stream@2026') {
      final demoUser = {
        'email': email_,
        'passwordHash': _hashPassword(password),
        'displayName': 'Demo Streamer',
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _setSession(email_, demoUser);
      return AuthResult.success(
        StreamerUser(email: email_, displayName: 'Demo Streamer'),
      );
    }

    final usersRaw = prefs.getString(_keyUsersDb);
    if (usersRaw == null) {
      return AuthResult.failure('No account found. Please register first.');
    }

    final Map<String, dynamic> users =
        jsonDecode(usersRaw) as Map<String, dynamic>;

    if (!users.containsKey(email_)) {
      return AuthResult.failure('No account found with this email.');
    }

    final userData = users[email_] as Map<String, dynamic>;
    if (userData['passwordHash'] != _hashPassword(password)) {
      return AuthResult.failure('Incorrect password. Please try again.');
    }

    await _setSession(email_, userData);
    return AuthResult.success(
      StreamerUser(
        email: email_,
        displayName: userData['displayName'] as String? ?? email_,
      ),
    );
  }

  // ─── Session ─────────────────────────────────────────────────────────────────

  Future<void> _setSession(String email, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyCurrentUser, jsonEncode(userData));
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<StreamerUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCurrentUser);
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return StreamerUser(
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyCurrentUser);
  }

  // ─── YouTube Credentials ─────────────────────────────────────────────────────

  Future<void> saveYouTubeCredentials({
    String? apiKey,
    String? channelId,
    String? channelName,
    String? accessToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (apiKey != null) await prefs.setString(_keyYoutubeApiKey, apiKey);
    if (channelId != null) {
      await prefs.setString(_keyYoutubeChannelId, channelId);
    }
    if (channelName != null) {
      await prefs.setString(_keyYoutubeChannelName, channelName);
    }
    if (accessToken != null) {
      await prefs.setString(_keyYoutubeAccessToken, accessToken);
    }
  }

  Future<YouTubeCredentials> getYouTubeCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return YouTubeCredentials(
      apiKey: prefs.getString(_keyYoutubeApiKey),
      channelId: prefs.getString(_keyYoutubeChannelId),
      channelName: prefs.getString(_keyYoutubeChannelName),
      accessToken: prefs.getString(_keyYoutubeAccessToken),
    );
  }

  Future<void> clearYouTubeCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyYoutubeApiKey);
    await prefs.remove(_keyYoutubeChannelId);
    await prefs.remove(_keyYoutubeChannelName);
    await prefs.remove(_keyYoutubeAccessToken);
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class StreamerUser {
  final String email;
  final String displayName;

  const StreamerUser({required this.email, required this.displayName});
}

class YouTubeCredentials {
  final String? apiKey;
  final String? channelId;
  final String? channelName;
  final String? accessToken;

  const YouTubeCredentials({
    this.apiKey,
    this.channelId,
    this.channelName,
    this.accessToken,
  });

  bool get hasCredentials =>
      apiKey != null && apiKey!.isNotEmpty ||
      channelId != null && channelId!.isNotEmpty;
}

class AuthResult {
  final bool success;
  final String? errorMessage;
  final StreamerUser? user;

  const AuthResult._({required this.success, this.errorMessage, this.user});

  factory AuthResult.success(StreamerUser user) =>
      AuthResult._(success: true, user: user);

  factory AuthResult.failure(String message) =>
      AuthResult._(success: false, errorMessage: message);
}
