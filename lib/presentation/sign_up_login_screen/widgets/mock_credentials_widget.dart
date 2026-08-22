import 'dart:ui';

import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class MockCredentialsWidget extends StatelessWidget {
  final void Function(String email, String password) onAutofill;

  const MockCredentialsWidget({required this.onAutofill, super.key});

  static const String _email = 'streamer@streamdash.app';
  static const String _password = 'Stream@2026';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withAlpha(179),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFFFD60A).withAlpha(51),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: const Color(0xFFFFD60A),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Demo Credentials',
                    style: TextStyle(
                      color: Color(0xFFFFD60A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _CredentialRow(
                label: 'Email',
                value: _email,
                onCopy: () {
                  Clipboard.setData(const ClipboardData(text: _email));
                },
              ),
              const SizedBox(height: 6),
              _CredentialRow(
                label: 'Password',
                value: _password,
                onCopy: () {
                  Clipboard.setData(const ClipboardData(text: _password));
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => onAutofill(_email, _password),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFD60A), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Use Demo Account',
                    style: TextStyle(
                      color: Color(0xFFFFD60A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _CredentialRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFFE6EDF3),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: onCopy,
          child: const CustomIconWidget(
            iconName: 'copy',
            color: Color(0xFF8B949E),
            size: 15,
          ),
        ),
      ],
    );
  }
}
