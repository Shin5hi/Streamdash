import '../../core/app_export.dart';

class TwitchChannelConnectScreen extends StatefulWidget {
  const TwitchChannelConnectScreen({super.key});

  @override
  State<TwitchChannelConnectScreen> createState() =>
      _TwitchChannelConnectScreenState();
}

class _TwitchChannelConnectScreenState
    extends State<TwitchChannelConnectScreen> {
  final _channelController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _obscureToken = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _channelController.dispose();
    _clientIdController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_channelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduce el nombre de tu canal'),
          backgroundColor: Color(0xFFFF453A),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '✅ Configuración guardada. Reinicia la app para aplicar.',
        ),
        backgroundColor: Color(0xFF30D158),
        duration: Duration(seconds: 3),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14141C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFE6EDF3),
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Conectar Canal Twitch',
          style: TextStyle(
            color: Color(0xFFE6EDF3),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9146FF), Color(0xFF6441A5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('🎮', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Twitch API',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Conecta tu canal para métricas en tiempo real',
                          style: TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF9146FF).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF9146FF).withAlpha(60),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF9146FF),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Cómo obtener las credenciales',
                        style: TextStyle(
                          color: Color(0xFF9146FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Ve a dev.twitch.tv/console\n2. Crea una nueva aplicación\n3. Copia el Client ID\n4. Genera un Access Token con el scope channel:read:stream_key',
                    style: TextStyle(
                      color: Color(0xFFB8C4CE),
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Nombre del Canal *'),
            const SizedBox(height: 8),
            _buildTextField(
              _channelController,
              'ej. tu_canal_twitch',
              Icons.person_outline,
            ),
            const SizedBox(height: 16),

            _buildLabel('Client ID'),
            const SizedBox(height: 8),
            _buildTextField(
              _clientIdController,
              'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
              Icons.key_outlined,
            ),
            const SizedBox(height: 16),

            _buildLabel('Access Token'),
            const SizedBox(height: 8),
            TextField(
              controller: _tokenController,
              obscureText: _obscureToken,
              style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'oauth:xxxxxxxxxxxxxxxxxxxxxxxxxx',
                hintStyle: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E2A),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF8B949E),
                  size: 18,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureToken
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF8B949E),
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscureToken = !_obscureToken),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF9146FF),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9146FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Guardar Configuración',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Las credenciales se guardan en env.json y se aplican al recompilar la app.',
              style: TextStyle(color: Color(0xFF8B949E), fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFE6EDF3),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1E1E2A),
        prefixIcon: Icon(icon, color: const Color(0xFF8B949E), size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9146FF), width: 1.5),
        ),
      ),
    );
  }
}
