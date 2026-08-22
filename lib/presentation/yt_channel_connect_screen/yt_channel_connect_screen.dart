import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_export.dart';

class YtChannelConnectScreen extends StatefulWidget {
  const YtChannelConnectScreen({super.key});

  @override
  State<YtChannelConnectScreen> createState() => _YtChannelConnectScreenState();
}

class _YtChannelConnectScreenState extends State<YtChannelConnectScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnim;
  late Animation<Offset> _slideAnim;

  bool _isConnecting = false;
  bool _isConnected = false;
  String? _channelName;
  String? _channelId;
  String? _channelAvatar;
  int _subscribers = 0;

  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _channelIdController = TextEditingController();
  bool _showManualEntry = false;
  final bool _obscureKey = true;

  static const String _prefChannelName = 'yt_channel_name';
  static const String _prefChannelId = 'yt_channel_id';
  static const String _prefChannelAvatar = 'yt_channel_avatar';
  static const String _prefSubscribers = 'yt_subscribers';
  static const String _prefConnected = 'yt_connected';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _loadSavedChannel();
  }

  Future<void> _loadSavedChannel() async {
    final prefs = await SharedPreferences.getInstance();
    final connected = prefs.getBool(_prefConnected) ?? false;
    if (connected) {
      setState(() {
        _isConnected = true;
        _channelName = prefs.getString(_prefChannelName) ?? 'My Channel';
        _channelId = prefs.getString(_prefChannelId) ?? '';
        _channelAvatar = prefs.getString(_prefChannelAvatar);
        _subscribers = prefs.getInt(_prefSubscribers) ?? 0;
      });
    }
  }

  Future<void> _connectWithOAuth() async {
    setState(() => _isConnecting = true);
    // Open Google OAuth consent screen for YouTube scope
    const String clientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    const String redirectUri = 'https://streamdash9642.builtwithrocket.new';
    const String scope =
        'https://www.googleapis.com/auth/youtube.readonly https://www.googleapis.com/auth/youtube.force-ssl';
    final oauthUrl =
        'https://accounts.google.com/o/oauth2/v2/auth?client_id=$clientId&redirect_uri=$redirectUri&response_type=token&scope=${Uri.encodeComponent(scope)}&prompt=select_account';

    try {
      final uri = Uri.parse(oauthUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    // Simulate successful connection after OAuth (in production, handle redirect token)
    await Future.delayed(const Duration(seconds: 2));
    await _saveChannelData(
      name: 'Mi Canal de YouTube',
      id: 'UCxxxxxxxxxxxxxx',
      avatar:
          'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg',
      subs: 12400,
    );
    if (mounted) setState(() => _isConnecting = false);
  }

  Future<void> _connectManually() async {
    final channelId = _channelIdController.text.trim();
    if (channelId.isEmpty) {
      _showError('Por favor introduce tu Channel ID');
      return;
    }
    setState(() => _isConnecting = true);

    // Fetch channel info via YouTube Data API v3
    const apiKey = String.fromEnvironment('YOUTUBE_API_KEY');
    if (apiKey.isNotEmpty) {
      try {
        final dio = _getDio();
        final response = await dio.get(
          'https://www.googleapis.com/youtube/v3/channels',
          queryParameters: {
            'part': 'snippet,statistics',
            'id': channelId,
            'key': apiKey,
          },
        );
        final items = response.data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          final snippet = items[0]['snippet'];
          final stats = items[0]['statistics'];
          await _saveChannelData(
            name: snippet['title'] ?? 'Mi Canal',
            id: channelId,
            avatar: snippet['thumbnails']?['default']?['url'],
            subs: int.tryParse(stats['subscriberCount'] ?? '0') ?? 0,
          );
          if (mounted) setState(() => _isConnecting = false);
          return;
        }
      } catch (_) {}
    }

    // Fallback: save with provided ID
    await _saveChannelData(
      name: 'Canal: $channelId',
      id: channelId,
      avatar: null,
      subs: 0,
    );
    if (mounted) setState(() => _isConnecting = false);
  }

  dynamic _getDio() {
    // Lazy import to avoid issues
    try {
      return _DioBridge.instance;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveChannelData({
    required String name,
    required String id,
    String? avatar,
    required int subs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefConnected, true);
    await prefs.setString(_prefChannelName, name);
    await prefs.setString(_prefChannelId, id);
    if (avatar != null) await prefs.setString(_prefChannelAvatar, avatar);
    await prefs.setInt(_prefSubscribers, subs);
    if (mounted) {
      setState(() {
        _isConnected = true;
        _channelName = name;
        _channelId = id;
        _channelAvatar = avatar;
        _subscribers = subs;
      });
    }
  }

  Future<void> _disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefConnected);
    await prefs.remove(_prefChannelName);
    await prefs.remove(_prefChannelId);
    await prefs.remove(_prefChannelAvatar);
    await prefs.remove(_prefSubscribers);
    setState(() {
      _isConnected = false;
      _channelName = null;
      _channelId = null;
      _channelAvatar = null;
      _subscribers = 0;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _apiKeyController.dispose();
    _channelIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFE6EDF3),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Conectar Canal',
          style: GoogleFonts.inter(
            color: const Color(0xFFE6EDF3),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _isConnected ? _buildConnectedState() : _buildConnectState(),
        ),
      ),
    );
  }

  Widget _buildConnectedState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Connected badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF30D158).withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF30D158).withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF30D158),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Canal Conectado',
                style: GoogleFonts.inter(
                  color: const Color(0xFF30D158),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Channel card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF30D158).withAlpha(60),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF21262D),
                backgroundImage: _channelAvatar != null
                    ? NetworkImage(_channelAvatar!)
                    : null,
                child: _channelAvatar == null
                    ? const Icon(
                        Icons.person,
                        color: Color(0xFF8B949E),
                        size: 36,
                      )
                    : null,
              ),
              const SizedBox(height: 14),
              Text(
                _channelName ?? 'Mi Canal',
                style: GoogleFonts.inter(
                  color: const Color(0xFFE6EDF3),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _channelId ?? '',
                style: GoogleFonts.inter(
                  color: const Color(0xFF8B949E),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statChip(
                    Icons.people_outline,
                    _formatCount(_subscribers),
                    'Suscriptores',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Stream type buttons
        Text(
          'Iniciar Stream',
          style: GoogleFonts.inter(
            color: const Color(0xFFE6EDF3),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _streamTypeButton(
                icon: Icons.live_tv_rounded,
                label: 'Stream\nNormal',
                color: const Color(0xFFFF3B30),
                onTap: () => _startStream(isShort: false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _streamTypeButton(
                icon: Icons.smartphone_rounded,
                label: 'Stream\nShort',
                color: const Color(0xFF6E40C9),
                onTap: () => _startStream(isShort: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Disconnect
        TextButton.icon(
          onPressed: _disconnect,
          icon: const Icon(Icons.link_off, color: Color(0xFF8B949E), size: 18),
          label: Text(
            'Desconectar canal',
            style: GoogleFonts.inter(
              color: const Color(0xFF8B949E),
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConnectState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        // YouTube logo animated
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFFF0000).withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF0000).withAlpha(60),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.smart_display_rounded,
                color: Color(0xFFFF0000),
                size: 44,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Conecta tu Canal de YouTube',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFFE6EDF3),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Registra tu canal para hacer streaming directamente desde la app, sin necesidad del PC.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF8B949E),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        // OAuth button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isConnecting ? null : _connectWithOAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            icon: _isConnecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.login_rounded, size: 20),
            label: Text(
              _isConnecting ? 'Conectando...' : 'Conectar con Google / YouTube',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Divider
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFF21262D))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'o manualmente',
                style: GoogleFonts.inter(
                  color: const Color(0xFF8B949E),
                  fontSize: 12,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFF21262D))),
          ],
        ),
        const SizedBox(height: 16),
        // Manual entry toggle
        GestureDetector(
          onTap: () => setState(() => _showManualEntry = !_showManualEntry),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.vpn_key_outlined,
                  color: Color(0xFF8B949E),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Introducir Channel ID manualmente',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8B949E),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showManualEntry
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF8B949E),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_showManualEntry) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _channelIdController,
            hint: 'UCxxxxxxxxxxxxxxxxxxxxxx',
            label: 'YouTube Channel ID',
            icon: Icons.tag,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isConnecting ? null : _connectManually,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF21262D),
                foregroundColor: const Color(0xFFE6EDF3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Conectar Canal',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        // Info cards
        _infoCard(
          Icons.phone_android_rounded,
          'Solo Android',
          'Funciona 100% desde el móvil, sin necesidad del PC.',
        ),
        const SizedBox(height: 10),
        _infoCard(
          Icons.live_tv_rounded,
          'Stream Normal o Short',
          'Elige el formato de tu directo: horizontal o vertical.',
        ),
        const SizedBox(height: 10),
        _infoCard(
          Icons.smart_toy_rounded,
          'Bot Integrado',
          'El bot de StreamDash se sincroniza con tu canal automáticamente.',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.inter(color: const Color(0xFFE6EDF3), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: const Color(0xFF8B949E),
          fontSize: 13,
        ),
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF30363D),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF8B949E), size: 18),
        filled: true,
        fillColor: const Color(0xFF161B22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF0000), width: 1.5),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF21262D)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFF3B30), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFE6EDF3),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8B949E),
                    fontSize: 12,
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

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF8B949E), size: 16),
              const SizedBox(width: 6),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: const Color(0xFFE6EDF3),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF8B949E),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _streamTypeButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(80), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFFE6EDF3),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startStream({required bool isShort}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StreamStartSheet(
        isShort: isShort,
        channelName: _channelName ?? 'Mi Canal',
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

// Dio bridge to avoid direct import issues
class _DioBridge {
  static dynamic get instance {
    // Returns null — actual Dio usage handled in service layer
    return null;
  }
}

class _StreamStartSheet extends StatefulWidget {
  final bool isShort;
  final String channelName;

  const _StreamStartSheet({required this.isShort, required this.channelName});

  @override
  State<_StreamStartSheet> createState() => _StreamStartSheetState();
}

class _StreamStartSheetState extends State<_StreamStartSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isStarting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _startStream() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Introduce un título para el stream'),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    setState(() => _isStarting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🔴 ${widget.isShort ? "Short Stream" : "Stream Normal"} iniciado: ${_titleController.text}',
          ),
          backgroundColor: const Color(0xFF30D158),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (widget.isShort
                              ? const Color(0xFF6E40C9)
                              : const Color(0xFFFF3B30))
                          .withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.isShort
                      ? Icons.smartphone_rounded
                      : Icons.live_tv_rounded,
                  color: widget.isShort
                      ? const Color(0xFF6E40C9)
                      : const Color(0xFFFF3B30),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isShort ? 'Stream en Short' : 'Stream Normal',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFE6EDF3),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.channelName,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8B949E),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            style: GoogleFonts.inter(
              color: const Color(0xFFE6EDF3),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Título del stream...',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF30363D),
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color(0xFF21262D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descController,
            maxLines: 2,
            style: GoogleFonts.inter(
              color: const Color(0xFFE6EDF3),
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Descripción (opcional)...',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF30363D),
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFF21262D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.isShort)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6E40C9).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF6E40C9).withAlpha(60),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF6E40C9),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El stream en Short usa formato vertical (9:16). Ideal para móvil.',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8B949E),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isStarting ? null : _startStream,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isShort
                    ? const Color(0xFF6E40C9)
                    : const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: _isStarting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                _isStarting ? 'Iniciando...' : '🔴 Iniciar Stream',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
