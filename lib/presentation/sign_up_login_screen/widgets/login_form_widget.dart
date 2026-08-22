import 'dart:ui';

import '../../../core/app_export.dart';

class LoginFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController displayNameController;
  final bool isLogin;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;
  final VoidCallback onYouTubeAuth;

  const LoginFormWidget({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.displayNameController,
    required this.isLogin,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.onToggleMode,
    required this.onYouTubeAuth,
    super.key,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withAlpha(217),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          ),
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isLogin ? 'Sign In' : 'Create Account',
                  style: const TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isLogin
                      ? 'Access your stream dashboard'
                      : 'Start managing your live streams',
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                // Display name field (register only)
                if (!widget.isLogin) ...[
                  _GlassFormField(
                    controller: widget.displayNameController,
                    label: 'Display Name',
                    hint: 'Your streamer name',
                    iconName: 'person',
                    keyboardType: TextInputType.name,
                    validator: (v) => null, // optional
                  ),
                  const SizedBox(height: 12),
                ],
                // Email field
                _GlassFormField(
                  controller: widget.emailController,
                  label: 'Email',
                  hint: 'streamer@example.com',
                  iconName: 'email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Password field
                _GlassFormField(
                  controller: widget.passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  iconName: 'lock',
                  obscureText: _obscurePassword,
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: CustomIconWidget(
                      iconName: _obscurePassword
                          ? 'visibility'
                          : 'visibility_off',
                      color: const Color(0xFF8B949E),
                      size: 18,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                // Error message
                if (widget.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFF3B30).withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const CustomIconWidget(
                          iconName: 'error_outline',
                          color: Color(0xFFFF453A),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFFF453A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Submit button
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: widget.isLoading ? null : widget.onSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      disabledBackgroundColor: const Color(
                        0xFFFF3B30,
                      ).withAlpha(128),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Divider
                Row(
                  children: const [
                    Expanded(
                      child: Divider(color: Color(0x1AFFFFFF), height: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or continue with',
                        style: TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0x1AFFFFFF), height: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // YouTube OAuth button
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: widget.onYouTubeAuth,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0x2AFFFFFF),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0x0DFFFFFF),
                    ),
                    icon: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          'Y',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    label: const Text(
                      'Continue with YouTube',
                      style: TextStyle(
                        color: Color(0xFFE6EDF3),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Toggle mode
                GestureDetector(
                  onTap: widget.onToggleMode,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(
                          text: widget.isLogin
                              ? "Don't have an account? "
                              : 'Already have an account? ',
                        ),
                        TextSpan(
                          text: widget.isLogin ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                            color: Color(0xFF0A84FF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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

// ─── Reusable glass form field ────────────────────────────────────────────────

class _GlassFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String iconName;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _GlassFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.iconName,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF484F58), fontSize: 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CustomIconWidget(
            iconName: iconName,
            color: const Color(0xFF8B949E),
            size: 18,
          ),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: suffixIcon,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF0D1117).withAlpha(128),
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
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF453A), fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
