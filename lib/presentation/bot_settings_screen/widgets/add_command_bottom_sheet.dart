import 'dart:ui';

import '../../../core/app_export.dart';
import '../bot_settings_screen.dart';

class AddCommandBottomSheet extends StatefulWidget {
  final void Function(BotCommand cmd) onAdd;
  const AddCommandBottomSheet({required this.onAdd, super.key});

  @override
  State<AddCommandBottomSheet> createState() => _AddCommandBottomSheetState();
}

class _AddCommandBottomSheetState extends State<AddCommandBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _triggerController = TextEditingController();
  final _responseController = TextEditingController();
  String _selectedCategory = 'info';
  double _cooldown = 30;

  @override
  void dispose() {
    _triggerController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cmd = BotCommand(
      id: 'cmd_${DateTime.now().millisecondsSinceEpoch}',
      trigger: _triggerController.text.trim().startsWith('!')
          ? _triggerController.text.trim()
          : '!${_triggerController.text.trim()}',
      response: _responseController.text.trim(),
      cooldownSec: _cooldown.toInt(),
      usageCount: 0,
      isActive: true,
      category: _selectedCategory,
    );
    widget.onAdd(cmd);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0x1AFFFFFF), width: 1)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF30363D),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'New Bot Command',
                  style: TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Commands are triggered when viewers type in chat',
                  style: TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                ),
                const SizedBox(height: 20),
                // Trigger field
                _SheetField(
                  controller: _triggerController,
                  label: 'Trigger keyword',
                  hint: '!mycommand',
                  iconName: 'bolt',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Trigger is required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Response field
                _SheetField(
                  controller: _responseController,
                  label: 'Bot response',
                  hint:
                      'What the bot will say when this command is triggered...',
                  iconName: 'smart_toy',
                  maxLines: 3,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Response is required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Category selector
                const Text(
                  'Category',
                  style: TextStyle(
                    color: Color(0xFFB8C4CE),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['info', 'moderation', 'engagement']
                      .map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedCategory == cat
                                    ? const Color(0xFF0A84FF).withAlpha(38)
                                    : const Color(0xFF21262D),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedCategory == cat
                                      ? const Color(0xFF0A84FF).withAlpha(128)
                                      : const Color(0x1AFFFFFF),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: _selectedCategory == cat
                                      ? const Color(0xFF0A84FF)
                                      : const Color(0xFF8B949E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                // Cooldown slider
                Row(
                  children: [
                    const Text(
                      'Cooldown',
                      style: TextStyle(
                        color: Color(0xFFB8C4CE),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_cooldown.toInt()}s',
                      style: const TextStyle(
                        color: Color(0xFF0A84FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF0A84FF),
                    inactiveTrackColor: const Color(0xFF30363D),
                    thumbColor: const Color(0xFF0A84FF),
                    overlayColor: const Color(0xFF0A84FF).withAlpha(26),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _cooldown,
                    min: 5,
                    max: 300,
                    divisions: 59,
                    onChanged: (v) => setState(() => _cooldown = v),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Add Command',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String iconName;
  final int maxLines;
  final String? Function(String?)? validator;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.iconName,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB8C4CE),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
            filled: true,
            fillColor: const Color(0x14FFFFFF),
            prefixIcon: maxLines == 1
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: const Color(0xFF8B949E),
                      size: 16,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3B30),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1),
            ),
            errorStyle: const TextStyle(color: Color(0xFFFF453A), fontSize: 11),
          ),
        ),
      ],
    );
  }
}
