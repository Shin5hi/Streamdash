import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class StreamerAccountScreen extends StatefulWidget {
  const StreamerAccountScreen({super.key});

  @override
  State<StreamerAccountScreen> createState() => _StreamerAccountScreenState();
}

class _StreamerAccountScreenState extends State<StreamerAccountScreen> {
  // Account info
  final _displayNameController = TextEditingController(text: 'StreamerPro_ES');
  final _emailController = TextEditingController(text: 'streamer@example.com');
  final _bioController = TextEditingController(
    text: 'Streamer de contenido gaming y tecnología 🎮',
  );
  bool _editingAccount = false;

  // Connected YouTube channels
  final List<Map<String, dynamic>> _channels = [
    {
      'id': 'UC1234567890',
      'name': 'StreamerPro ES',
      'subscribers': '12.4K',
      'avatar':
          'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg',
      'connected': true,
      'primary': true,
    },
    {
      'id': 'UC0987654321',
      'name': 'Gaming Clips ES',
      'subscribers': '3.1K',
      'avatar':
          'https://images.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png',
      'connected': false,
      'primary': false,
    },
  ];

  // Streaming quality
  String _selectedResolution = '1080p';
  String _selectedFps = '60';
  int _bitrateKbps = 6000;
  String _selectedEncoder = 'H.264';
  bool _adaptiveBitrate = true;

  static const List<String> _resolutions = ['720p', '1080p', '1440p', '4K'];
  static const List<String> _fpsList = ['30', '60'];
  static const List<String> _encoders = ['H.264', 'H.265', 'VP9'];

  // Notifications
  bool _notifNewFollower = true;
  bool _notifSuperChat = true;
  bool _notifNewSubscriber = true;
  bool _notifStreamHealth = true;
  bool _notifChatMention = false;
  bool _notifBotAlert = true;

  // Chat Admins / Moderators
  final List<Map<String, dynamic>> _chatAdmins = [
    {
      'id': 'admin_1',
      'name': 'ModeradorPro',
      'avatar':
          'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg',
      'role': 'Admin',
      'canBan': true,
      'canTimeout': true,
      'canDeleteMessages': true,
      'canPinMessages': false,
      'canManageBot': false,
    },
    {
      'id': 'admin_2',
      'name': 'ChatHelper_ES',
      'avatar':
          'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
      'role': 'Moderador',
      'canBan': false,
      'canTimeout': true,
      'canDeleteMessages': true,
      'canPinMessages': true,
      'canManageBot': false,
    },
  ];

  final _newAdminController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _newAdminController.dispose();
    super.dispose();
  }

  void _saveAccountInfo() {
    setState(() => _editingAccount = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Información de cuenta actualizada',
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleChannelConnection(int index) {
    setState(() {
      _channels[index]['connected'] = !_channels[index]['connected'];
    });
    final ch = _channels[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ch['connected']
              ? '${ch['name']} conectado'
              : '${ch['name']} desconectado',
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: ch['connected']
            ? AppTheme.secondary
            : AppTheme.surfaceVariantDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _setPrimaryChannel(int index) {
    setState(() {
      for (int i = 0; i < _channels.length; i++) {
        _channels[i]['primary'] = i == index;
      }
    });
  }

  void _saveStreamingPrefs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Preferencias de streaming guardadas',
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountInfoSection(),
                    SizedBox(height: 2.h),
                    _buildYouTubeChannelsSection(),
                    SizedBox(height: 2.h),
                    _buildChatAdminsSection(),
                    SizedBox(height: 2.h),
                    _buildStreamingQualitySection(),
                    SizedBox(height: 2.h),
                    _buildNotificationsSection(),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primary.withAlpha(60),
                width: 1,
              ),
            ),
            child: const CustomIconWidget(
              iconName: 'person',
              color: AppTheme.primary,
              size: 18,
            ),
          ),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi Cuenta',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE6EDF3),
                ),
              ),
              Text(
                'Gestiona tu perfil y preferencias',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  color: const Color(0xFF8B949E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SECTION: Account Info ────────────────────────────────────────────────

  Widget _buildAccountInfoSection() {
    return _SectionCard(
      icon: 'manage_accounts',
      iconColor: AppTheme.info,
      title: 'Información de Cuenta',
      trailing: GestureDetector(
        onTap: () {
          if (_editingAccount) {
            _saveAccountInfo();
          } else {
            setState(() => _editingAccount = true);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _editingAccount
                ? AppTheme.secondary.withAlpha(30)
                : AppTheme.glassWhite8,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _editingAccount
                  ? AppTheme.secondary.withAlpha(80)
                  : const Color(0x1AFFFFFF),
              width: 1,
            ),
          ),
          child: Text(
            _editingAccount ? 'Guardar' : 'Editar',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _editingAccount
                  ? AppTheme.secondary
                  : const Color(0xFFE6EDF3),
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          // Avatar row
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primary.withAlpha(80),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg',
                        fit: BoxFit.cover,
                        semanticLabel:
                            'Avatar del streamer, hombre con fondo oscuro',
                      ),
                    ),
                  ),
                  if (_editingAccount)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.backgroundDark,
                            width: 2,
                          ),
                        ),
                        child: const CustomIconWidget(
                          iconName: 'camera_alt',
                          color: Colors.white,
                          size: 11,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayNameController.text,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE6EDF3),
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Cuenta activa',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _displayNameController,
            label: 'Nombre de streamer',
            icon: 'badge',
            enabled: _editingAccount,
          ),
          SizedBox(height: 1.2.h),
          _buildTextField(
            controller: _emailController,
            label: 'Correo electrónico',
            icon: 'email',
            enabled: _editingAccount,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 1.2.h),
          _buildTextField(
            controller: _bioController,
            label: 'Bio',
            icon: 'edit_note',
            enabled: _editingAccount,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.ibmPlexSans(
        fontSize: 13,
        color: enabled ? const Color(0xFFE6EDF3) : const Color(0xFF8B949E),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CustomIconWidget(
            iconName: icon,
            color: enabled ? AppTheme.info : const Color(0xFF8B949E),
            size: 16,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        filled: true,
        fillColor: enabled ? AppTheme.glassWhite8 : AppTheme.glassWhite5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x33FFFFFF), width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x0DFFFFFF), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.info, width: 1.5),
        ),
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          color: const Color(0xFF8B949E),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  // ─── SECTION: YouTube Channels ───────────────────────────────────────────

  Widget _buildYouTubeChannelsSection() {
    return _SectionCard(
      icon: 'smart_display',
      iconColor: AppTheme.primary,
      title: 'Canales de YouTube',
      trailing: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Conectar nuevo canal de YouTube',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppTheme.surfaceVariantDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primary.withAlpha(60), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomIconWidget(
                iconName: 'add',
                color: AppTheme.primary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Añadir',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Column(
        children: List.generate(_channels.length, (i) {
          final ch = _channels[i];
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < _channels.length - 1 ? 1.2.h : 0,
            ),
            child: _buildChannelTile(i, ch),
          );
        }),
      ),
    );
  }

  Widget _buildChannelTile(int index, Map<String, dynamic> ch) {
    final bool connected = ch['connected'] as bool;
    final bool primary = ch['primary'] as bool;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: connected
            ? AppTheme.secondary.withAlpha(12)
            : AppTheme.glassWhite5,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: connected
              ? AppTheme.secondary.withAlpha(50)
              : const Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              ch['avatar'] as String,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              semanticLabel: 'Avatar del canal ${ch['name']}',
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        ch['name'] as String,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE6EDF3),
                        ),
                      ),
                    ),
                    if (primary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.warning.withAlpha(80),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Principal',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.warning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const CustomIconWidget(
                      iconName: 'people',
                      color: Color(0xFF8B949E),
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ch['subscribers']} suscriptores',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11,
                        color: const Color(0xFF8B949E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Connect toggle
              GestureDetector(
                onTap: () => _toggleChannelConnection(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: connected
                        ? AppTheme.secondary.withAlpha(25)
                        : AppTheme.glassWhite8,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: connected
                          ? AppTheme.secondary.withAlpha(80)
                          : const Color(0x1AFFFFFF),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    connected ? 'Conectado' : 'Conectar',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: connected
                          ? AppTheme.secondary
                          : const Color(0xFFE6EDF3),
                    ),
                  ),
                ),
              ),
              if (connected && !primary) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _setPrimaryChannel(index),
                  child: Text(
                    'Hacer principal',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 10,
                      color: AppTheme.info,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.info,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── SECTION: Chat Admins / Moderators ───────────────────────────────────

  Widget _buildChatAdminsSection() {
    return _SectionCard(
      icon: 'shield',
      iconColor: const Color(0xFF7C3AED),
      title: 'Admins del Chat',
      trailing: GestureDetector(
        onTap: _showAddAdminDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF7C3AED).withAlpha(70),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomIconWidget(
                iconName: 'person_add',
                color: Color(0xFF7C3AED),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Añadir',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
        ),
      ),
      child: _chatAdmins.isEmpty
          ? _buildEmptyAdmins()
          : Column(
              children: List.generate(_chatAdmins.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < _chatAdmins.length - 1 ? 1.5.h : 0,
                  ),
                  child: _buildAdminCard(i),
                );
              }),
            ),
    );
  }

  Widget _buildEmptyAdmins() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Column(
          children: [
            const CustomIconWidget(
              iconName: 'shield',
              color: Color(0xFF8B949E),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Sin admins asignados',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                color: const Color(0xFF8B949E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(int index) {
    final admin = _chatAdmins[index];
    final bool isAdmin = admin['role'] == 'Admin';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7C3AED).withAlpha(40),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Admin header row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    admin['avatar'] as String,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    semanticLabel: 'Avatar de ${admin['name']}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin['name'] as String,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE6EDF3),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? const Color(0xFF7C3AED).withAlpha(35)
                              : AppTheme.info.withAlpha(30),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isAdmin
                                ? const Color(0xFF7C3AED).withAlpha(80)
                                : AppTheme.info.withAlpha(70),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          admin['role'] as String,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isAdmin
                                ? const Color(0xFFB57BFF)
                                : AppTheme.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Role toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _chatAdmins[index]['role'] = isAdmin
                          ? 'Moderador'
                          : 'Admin';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.glassWhite8,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0x1AFFFFFF),
                        width: 1,
                      ),
                    ),
                    child: const CustomIconWidget(
                      iconName: 'swap_vert',
                      color: Color(0xFF8B949E),
                      size: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Remove admin
                GestureDetector(
                  onTap: () => _removeAdmin(index),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primary.withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: const CustomIconWidget(
                      iconName: 'person_remove',
                      color: AppTheme.primary,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0x1AFFFFFF), height: 1),
          // Permissions grid
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permisos',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B949E),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPermissionRow(
                  index: index,
                  icon: 'gavel',
                  label: 'Banear usuarios',
                  permKey: 'canBan',
                  color: AppTheme.primary,
                ),
                _buildPermissionRow(
                  index: index,
                  icon: 'timer_off',
                  label: 'Timeout',
                  permKey: 'canTimeout',
                  color: AppTheme.warning,
                ),
                _buildPermissionRow(
                  index: index,
                  icon: 'delete_sweep',
                  label: 'Eliminar mensajes',
                  permKey: 'canDeleteMessages',
                  color: AppTheme.info,
                ),
                _buildPermissionRow(
                  index: index,
                  icon: 'push_pin',
                  label: 'Fijar mensajes',
                  permKey: 'canPinMessages',
                  color: AppTheme.secondary,
                ),
                _buildPermissionRow(
                  index: index,
                  icon: 'smart_toy',
                  label: 'Gestionar bot',
                  permKey: 'canManageBot',
                  color: const Color(0xFF7C3AED),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow({
    required int index,
    required String icon,
    required String label,
    required String permKey,
    required Color color,
  }) {
    final bool value = _chatAdmins[index][permKey] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(7),
            ),
            child: CustomIconWidget(iconName: icon, color: color, size: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: const Color(0xFFE6EDF3),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: (v) {
                setState(() {
                  _chatAdmins[index][permKey] = v;
                });
              },
              activeThumbColor: color,
              activeTrackColor: color.withAlpha(60),
              inactiveThumbColor: const Color(0xFF8B949E),
              inactiveTrackColor: AppTheme.glassWhite8,
            ),
          ),
        ],
      ),
    );
  }

  void _removeAdmin(int index) {
    final name = _chatAdmins[index]['name'];
    setState(() => _chatAdmins.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$name eliminado de admins',
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddAdminDialog() {
    _newAdminController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Añadir Admin/Moderador',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE6EDF3),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Introduce el nombre de usuario del chat',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: const Color(0xFF8B949E),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newAdminController,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                color: const Color(0xFFE6EDF3),
              ),
              decoration: InputDecoration(
                hintText: 'Nombre de usuario',
                hintStyle: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: const Color(0xFF8B949E),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: Color(0xFF7C3AED),
                    size: 16,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 44),
                filled: true,
                fillColor: AppTheme.glassWhite8,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0x1AFFFFFF),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF7C3AED),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0x33FFFFFF),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                color: const Color(0xFF8B949E),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              final name = _newAdminController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _chatAdmins.add({
                    'id': 'admin_${DateTime.now().millisecondsSinceEpoch}',
                    'name': name,
                    'avatar':
                        'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg',
                    'role': 'Moderador',
                    'canBan': false,
                    'canTimeout': true,
                    'canDeleteMessages': true,
                    'canPinMessages': false,
                    'canManageBot': false,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$name añadido como Moderador',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFF7C3AED),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Añadir',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTION: Streaming Quality ──────────────────────────────────────────

  Widget _buildStreamingQualitySection() {
    return _SectionCard(
      icon: 'high_quality',
      iconColor: AppTheme.warning,
      title: 'Calidad y Bitrate',
      trailing: GestureDetector(
        onTap: _saveStreamingPrefs,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.warning.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.warning.withAlpha(70), width: 1),
          ),
          child: Text(
            'Guardar',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.warning,
            ),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resolution + FPS row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Resolución',
                  icon: 'monitor',
                  value: _selectedResolution,
                  items: _resolutions,
                  onChanged: (v) => setState(() => _selectedResolution = v!),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildDropdownField(
                  label: 'FPS',
                  icon: 'speed',
                  value: _selectedFps,
                  items: _fpsList,
                  onChanged: (v) => setState(() => _selectedFps = v!),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          // Encoder
          _buildDropdownField(
            label: 'Codificador',
            icon: 'memory',
            value: _selectedEncoder,
            items: _encoders,
            onChanged: (v) => setState(() => _selectedEncoder = v!),
          ),
          SizedBox(height: 1.8.h),
          // Bitrate slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CustomIconWidget(
                    iconName: 'network_check',
                    color: AppTheme.warning,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Bitrate de video',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE6EDF3),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warning.withAlpha(60),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$_bitrateKbps kbps',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.warning,
              inactiveTrackColor: AppTheme.glassWhite8,
              thumbColor: AppTheme.warning,
              overlayColor: AppTheme.warning.withAlpha(30),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _bitrateKbps.toDouble(),
              min: 1000,
              max: 12000,
              divisions: 22,
              onChanged: (v) => setState(() => _bitrateKbps = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1000 kbps',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 10,
                  color: const Color(0xFF8B949E),
                ),
              ),
              Text(
                '12000 kbps',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 10,
                  color: const Color(0xFF8B949E),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          // Adaptive bitrate toggle
          _buildToggleRow(
            icon: 'auto_awesome',
            iconColor: AppTheme.info,
            label: 'Bitrate adaptativo',
            subtitle: 'Ajusta automáticamente según la conexión',
            value: _adaptiveBitrate,
            onChanged: (v) => setState(() => _adaptiveBitrate = v),
          ),
          SizedBox(height: 1.h),
          // Quality summary chip row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildQualityChip(
                '$_selectedResolution @ ${_selectedFps}fps',
                AppTheme.warning,
              ),
              _buildQualityChip(_selectedEncoder, AppTheme.info),
              _buildQualityChip(
                '${(_bitrateKbps / 1000).toStringAsFixed(1)} Mbps',
                AppTheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite8,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
      ),
      child: Row(
        children: [
          CustomIconWidget(iconName: icon, color: AppTheme.warning, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceDark,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE6EDF3),
                ),
                hint: Text(
                  label,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: const Color(0xFF8B949E),
                  ),
                ),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
                icon: const CustomIconWidget(
                  iconName: 'expand_more',
                  color: Color(0xFF8B949E),
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ─── SECTION: Notifications ───────────────────────────────────────────────

  Widget _buildNotificationsSection() {
    return _SectionCard(
      icon: 'notifications',
      iconColor: AppTheme.secondary,
      title: 'Notificaciones',
      child: Column(
        children: [
          _buildToggleRow(
            icon: 'person_add',
            iconColor: AppTheme.info,
            label: 'Nuevo seguidor',
            subtitle: 'Cuando alguien te sigue en YouTube',
            value: _notifNewFollower,
            onChanged: (v) => setState(() => _notifNewFollower = v),
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: 'subscriptions',
            iconColor: AppTheme.warning,
            label: 'Nuevo suscriptor',
            subtitle: 'Suscripciones de pago al canal',
            value: _notifNewSubscriber,
            onChanged: (v) => setState(() => _notifNewSubscriber = v),
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: 'attach_money',
            iconColor: AppTheme.secondary,
            label: 'Super Chat',
            subtitle: 'Mensajes destacados con donación',
            value: _notifSuperChat,
            onChanged: (v) => setState(() => _notifSuperChat = v),
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: 'health_and_safety',
            iconColor: AppTheme.primary,
            label: 'Salud del stream',
            subtitle: 'Alertas de bitrate, caídas o errores',
            value: _notifStreamHealth,
            onChanged: (v) => setState(() => _notifStreamHealth = v),
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: 'alternate_email',
            iconColor: AppTheme.info,
            label: 'Menciones en chat',
            subtitle: 'Cuando te mencionan en el chat en vivo',
            value: _notifChatMention,
            onChanged: (v) => setState(() => _notifChatMention = v),
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: 'smart_toy',
            iconColor: const Color(0xFF8B949E),
            label: 'Alertas del bot',
            subtitle: 'Actividad del bot de moderación',
            value: _notifBotAlert,
            onChanged: (v) => setState(() => _notifBotAlert = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(9),
            ),
            child: CustomIconWidget(iconName: icon, color: iconColor, size: 16),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE6EDF3),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11,
                    color: const Color(0xFF8B949E),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.secondary,
            activeTrackColor: AppTheme.secondary.withAlpha(60),
            inactiveThumbColor: const Color(0xFF8B949E),
            inactiveTrackColor: AppTheme.glassWhite8,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0x0DFFFFFF), height: 1, thickness: 1);
  }
}

// ─── Reusable Section Card ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: icon,
                    color: iconColor,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE6EDF3),
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: Color(0x1AFFFFFF), height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}
