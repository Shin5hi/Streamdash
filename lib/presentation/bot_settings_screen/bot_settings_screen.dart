import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import './widgets/add_command_bottom_sheet.dart';
import './widgets/bot_command_list_widget.dart';
import './widgets/bot_header_widget.dart';
import './widgets/spam_filter_widget.dart';

// MODEL — BotCommand
class BotCommand {
  final String id;
  final String trigger;
  final String response;
  final int cooldownSec;
  final int usageCount;
  final bool isActive;
  final String category;
  final double successRate;
  final int viewerImpact;

  const BotCommand({
    required this.id,
    required this.trigger,
    required this.response,
    required this.cooldownSec,
    required this.usageCount,
    required this.isActive,
    required this.category,
    this.successRate = 0.0,
    this.viewerImpact = 0,
  });

  factory BotCommand.fromMap(Map<String, dynamic> map) {
    return BotCommand(
      id: map['id'] as String,
      trigger: map['trigger'] as String,
      response: map['response'] as String,
      cooldownSec: map['cooldownSec'] as int,
      usageCount: map['usageCount'] as int,
      isActive: map['isActive'] as bool,
      category: map['category'] as String,
      successRate: (map['successRate'] as num?)?.toDouble() ?? 0.0,
      viewerImpact: map['viewerImpact'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'trigger': trigger,
    'response': response,
    'cooldownSec': cooldownSec,
    'usageCount': usageCount,
    'isActive': isActive,
    'category': category,
    'successRate': successRate,
    'viewerImpact': viewerImpact,
  };
}

class BotSettingsScreen extends StatefulWidget {
  const BotSettingsScreen({super.key});

  @override
  State<BotSettingsScreen> createState() => _BotSettingsScreenState();
}

class _BotSettingsScreenState extends State<BotSettingsScreen> {
  bool _botEnabled = true;
  final int _commandsFired = 47;
  final int _spamBlocked = 12;

  final List<BotCommand> _commands = [
    const BotCommand(
      id: '1',
      trigger: '!bienvenida',
      response: '¡Bienvenido al stream! 🎉 No olvides seguir el canal.',
      cooldownSec: 30,
      usageCount: 142,
      isActive: true,
      category: 'info',
      successRate: 97.2,
      viewerImpact: 38,
    ),
    const BotCommand(
      id: '2',
      trigger: '!reglas',
      response: 'Reglas: 1) Respeto 2) No spam 3) Diviértete 🎮',
      cooldownSec: 60,
      usageCount: 87,
      isActive: true,
      category: 'moderation',
      successRate: 100.0,
      viewerImpact: 12,
    ),
    const BotCommand(
      id: '3',
      trigger: '!discord',
      response: 'Únete a nuestro Discord: discord.gg/tucanal 💬',
      cooldownSec: 45,
      usageCount: 203,
      isActive: true,
      category: 'engagement',
      successRate: 94.6,
      viewerImpact: 61,
    ),
    const BotCommand(
      id: '4',
      trigger: '!redes',
      response: 'Twitter: @TuCanal_ES | Instagram: @TuCanal_ES 📱',
      cooldownSec: 60,
      usageCount: 56,
      isActive: false,
      category: 'info',
      successRate: 89.3,
      viewerImpact: 9,
    ),
    const BotCommand(
      id: '5',
      trigger: '!comandos',
      response: 'Comandos disponibles: !bienvenida !reglas !discord !redes',
      cooldownSec: 20,
      usageCount: 319,
      isActive: true,
      category: 'info',
      successRate: 98.7,
      viewerImpact: 74,
    ),
  ];

  void _toggleCommand(String id) {
    setState(() {
      final idx = _commands.indexWhere((c) => c.id == id);
      if (idx != -1) {
        final cmd = _commands[idx];
        _commands[idx] = BotCommand(
          id: cmd.id,
          trigger: cmd.trigger,
          response: cmd.response,
          cooldownSec: cmd.cooldownSec,
          usageCount: cmd.usageCount,
          isActive: !cmd.isActive,
          category: cmd.category,
          successRate: cmd.successRate,
          viewerImpact: cmd.viewerImpact,
        );
      }
    });
  }

  void _deleteCommand(String id) {
    setState(() {
      _commands.removeWhere((c) => c.id == id);
    });
  }

  void _showAddCommand() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCommandBottomSheet(
        onAdd: (cmd) {
          setState(() => _commands.add(cmd));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'Configuración del Bot',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BotHeaderWidget(
              botEnabled: _botEnabled,
              commandsFired: _commandsFired,
              spamBlocked: _spamBlocked,
              onToggle: () => setState(() => _botEnabled = !_botEnabled),
            ),
            SizedBox(height: 2.h),
            SpamFilterWidget(botEnabled: _botEnabled),
            SizedBox(height: 2.h),
            BotCommandListWidget(
              commands: _commands,
              botEnabled: _botEnabled,
              onToggle: _toggleCommand,
              onDelete: _deleteCommand,
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAddCommand,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF30363D)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: Color(0xFF0A84FF)),
                  label: Text(
                    'Añadir Comando',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0A84FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
