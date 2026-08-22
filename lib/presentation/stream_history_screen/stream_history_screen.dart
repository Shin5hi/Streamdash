import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/youtube_service.dart';

class StreamHistoryScreen extends StatefulWidget {
  const StreamHistoryScreen({super.key});

  @override
  State<StreamHistoryScreen> createState() => _StreamHistoryScreenState();
}

class _StreamHistoryScreenState extends State<StreamHistoryScreen> {
  final YouTubeService _ytService = YouTubeService();

  List<_StreamRecord> _records = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecordedStreams();
  }

  Future<void> _loadRecordedStreams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!_ytService.hasApiKey || !_ytService.hasChannelId) {
      setState(() {
        _isLoading = false;
        _errorMessage = _ytService.hasApiKey
            ? 'Configure YOUTUBE_CHANNEL_ID to load recorded streams.'
            : 'Configure YOUTUBE_API_KEY to load recorded streams.';
        _records = _mockFallback();
      });
      return;
    }

    try {
      final streams = await _ytService.fetchRecordedStreams(maxResults: 15);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (streams.isEmpty) {
          _errorMessage = 'No completed live streams found on this channel.';
          _records = [];
        } else {
          _records = streams
              .map(
                (s) => _StreamRecord(
                  id: s.videoId,
                  title: s.title,
                  thumbnailUrl: s.thumbnailUrl,
                  date: s.publishedAt,
                  duration: Duration
                      .zero, // duration from ISO string already formatted
                  durationLabel: s.duration,
                  peakViewers: s.viewCount,
                  likeCount: s.likeCount,
                  recorded: true,
                ),
              )
              .toList();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load streams: $e';
        _records = _mockFallback();
      });
    }
  }

  List<_StreamRecord> _mockFallback() => [
    _StreamRecord(
      id: '1',
      title: 'Late Night Gaming Session — Elden Ring DLC',
      thumbnailUrl:
          'https://images.pexels.com/photos/3165335/pexels-photo-3165335.jpeg?auto=compress&cs=tinysrgb&w=400',
      date: DateTime(2026, 8, 19, 22, 30),
      duration: const Duration(hours: 3, minutes: 47),
      durationLabel: '3:47:00',
      peakViewers: 4821,
      likeCount: 312,
      recorded: true,
    ),
    _StreamRecord(
      id: '2',
      title: 'Chill Coding Stream — Flutter App Dev',
      thumbnailUrl:
          'https://images.pixabay.com/photo/2016/11/19/14/00/code-1839406_640.jpg',
      date: DateTime(2026, 8, 17, 18, 0),
      duration: const Duration(hours: 2, minutes: 12),
      durationLabel: '2:12:00',
      peakViewers: 1340,
      likeCount: 98,
      recorded: true,
    ),
    _StreamRecord(
      id: '3',
      title: 'Q&A + Subscriber Milestones 🎉',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1598550476439-6847785fcea6?w=400&auto=format&fit=crop',
      date: DateTime(2026, 8, 14, 20, 0),
      duration: const Duration(hours: 1, minutes: 58),
      durationLabel: '1:58:00',
      peakViewers: 7203,
      likeCount: 541,
      recorded: true,
    ),
  ];

  void _onReplay(_StreamRecord record) {
    if (!record.recorded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No recording available for this stream.',
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFE6EDF3),
              fontSize: 13,
            ),
          ),
          backgroundColor: const Color(0xFF21262D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _ReplayDialog(record: record),
    );
  }

  void _onDelete(_StreamRecord record) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x1AFFFFFF)),
        ),
        title: Text(
          'Remove from history?',
          style: GoogleFonts.ibmPlexSans(
            color: const Color(0xFFE6EDF3),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will remove "${record.title}" from your local history.',
          style: GoogleFonts.ibmPlexSans(
            color: const Color(0xFF8B949E),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.ibmPlexSans(
                color: const Color(0xFF8B949E),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _records.removeWhere((r) => r.id == record.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Removed from history.',
                    style: GoogleFonts.ibmPlexSans(
                      color: const Color(0xFFE6EDF3),
                      fontSize: 13,
                    ),
                  ),
                  backgroundColor: const Color(0xFF21262D),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(
              'Remove',
              style: GoogleFonts.ibmPlexSans(
                color: const Color(0xFFFF453A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoading()
          : (_records.isEmpty ? _buildEmpty() : _buildList()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF161B22),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30).withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.video_library_outlined,
              color: Color(0xFFFF3B30),
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Stream History',
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFE6EDF3),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        if (!_isLoading)
          IconButton(
            onPressed: _loadRecordedStreams,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF8B949E),
              size: 20,
            ),
            tooltip: 'Refresh',
          ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF21262D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: Text(
            '${_records.length} broadcasts',
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFF8B949E),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD60A).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD60A).withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFFD60A),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.ibmPlexSans(
                      color: const Color(0xFFFFD60A),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: _records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _StreamCard(
              record: _records[index],
              onReplay: _onReplay,
              onDelete: _onDelete,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: const Icon(
              Icons.video_library_outlined,
              color: Color(0xFF8B949E),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No past broadcasts',
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFE6EDF3),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? 'Your completed streams will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFF8B949E),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stream Card ────────────────────────────────────────────────────────────

class _StreamCard extends StatelessWidget {
  final _StreamRecord record;
  final void Function(_StreamRecord) onReplay;
  final void Function(_StreamRecord) onDelete;

  const _StreamCard({
    required this.record,
    required this.onReplay,
    required this.onDelete,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$min $ampm';
  }

  String _formatCount(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withAlpha(220),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnail(),
                  Expanded(child: _buildInfo()),
                ],
              ),
              const Divider(height: 1, color: Color(0x1AFFFFFF)),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
          child: Image.network(
            record.thumbnailUrl,
            width: 110,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 110,
              height: 80,
              color: const Color(0xFF21262D),
              child: const Icon(
                Icons.live_tv,
                color: Color(0xFF8B949E),
                size: 28,
              ),
            ),
            semanticLabel: record.title,
          ),
        ),
        Positioned(
          bottom: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(180),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              record.durationLabel,
              style: const TextStyle(
                color: Color(0xFFE6EDF3),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.title,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFE6EDF3),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF8B949E),
                size: 11,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _formatDate(record.date),
                  style: GoogleFonts.ibmPlexSans(
                    color: const Color(0xFF8B949E),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _statChip(
                Icons.visibility_outlined,
                '${_formatCount(record.peakViewers)} views',
                const Color(0xFF0A84FF),
              ),
              const SizedBox(width: 8),
              _statChip(
                Icons.thumb_up_outlined,
                _formatCount(record.likeCount),
                const Color(0xFFFF3B30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onReplay(record),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFF3B30).withAlpha(80),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_circle_outline,
                      color: Color(0xFFFF3B30),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Watch',
                      style: GoogleFonts.ibmPlexSans(
                        color: const Color(0xFFFF3B30),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => onDelete(record),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFF453A).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFF453A).withAlpha(60),
                ),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF453A),
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Replay Dialog ───────────────────────────────────────────────────────────

class _ReplayDialog extends StatelessWidget {
  final _StreamRecord record;
  const _ReplayDialog({required this.record});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22).withAlpha(230),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        record.thumbnailUrl,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        semanticLabel: record.title,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: const Color(0xFF21262D),
                          child: const Icon(
                            Icons.live_tv,
                            color: Color(0xFF8B949E),
                            size: 40,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(160),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Positioned.fill(
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 52,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(180),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            record.durationLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  record.title,
                  style: GoogleFonts.ibmPlexSans(
                    color: const Color(0xFFE6EDF3),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF21262D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Close',
                          style: GoogleFonts.ibmPlexSans(
                            color: const Color(0xFF8B949E),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Watch Replay',
                              style: GoogleFonts.ibmPlexSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Data Model ─────────────────────────────────────────────────────────────

class _StreamRecord {
  final String id;
  final String title;
  final String thumbnailUrl;
  final DateTime date;
  final Duration duration;
  final String durationLabel;
  final int peakViewers;
  final int likeCount;
  final bool recorded;

  const _StreamRecord({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.date,
    required this.duration,
    required this.durationLabel,
    required this.peakViewers,
    required this.likeCount,
    required this.recorded,
  });
}
