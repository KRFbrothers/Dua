import 'package:flutter/material.dart';

import '../agent/agent_settings.dart';
import '../privacy/data_paths.dart';
import '../theme/dua_colors.dart';
import 'privacy_screen.dart';

class AgentSettingsScreen extends StatefulWidget {
  const AgentSettingsScreen({super.key});

  @override
  State<AgentSettingsScreen> createState() => _AgentSettingsScreenState();
}

class _AgentSettingsScreenState extends State<AgentSettingsScreen> {
  final _apiKeyCtrl = TextEditingController();
  final _baseUrlCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _obscureKey = true;
  bool _preferOnDeviceStt = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await AgentSettings.load();
    if (!mounted) return;
    setState(() {
      _apiKeyCtrl.text = s.apiKey;
      _baseUrlCtrl.text = s.baseUrl;
      _modelCtrl.text = s.model;
      _preferOnDeviceStt = s.preferOnDeviceStt;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final settings = AgentSettings(
      apiKey: _apiKeyCtrl.text,
      baseUrl: _baseUrlCtrl.text.trim().isEmpty
          ? AgentSettings.defaultBaseUrl
          : _baseUrlCtrl.text,
      model: _modelCtrl.text.trim().isEmpty
          ? AgentSettings.defaultModel
          : _modelCtrl.text,
      preferOnDeviceStt: _preferOnDeviceStt,
    );
    await settings.save();
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _clearKey() async {
    final s = await AgentSettings.load();
    await s.clearApiKey();
    if (!mounted) return;
    setState(() => _apiKeyCtrl.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API key cleared'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _baseUrlCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _sectionTitle('Privacy'),
                const SizedBox(height: 8),
                _privacyCard(context),
                const SizedBox(height: 20),
                _sectionTitle('Voice'),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Prefer on-device speech recognition',
                    style: TextStyle(color: DuaColors.textPrimary),
                  ),
                  subtitle: Text(
                    DataPathLabels.voiceOnDevicePrefer,
                    style: TextStyle(
                      color: DuaColors.textSecondary.withValues(alpha: 0.95),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  value: _preferOnDeviceStt,
                  activeThumbColor: DuaColors.cyan,
                  onChanged: (v) => setState(() => _preferOnDeviceStt = v),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Online agent (API)'),
                const SizedBox(height: 8),
                Text(
                  'API key is stored in secure storage on this device. '
                  'Used only for Online / agent replies — never by Offline.',
                  style: TextStyle(
                    color: DuaColors.textSecondary.withValues(alpha: 0.95),
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiKeyCtrl,
                  obscureText: _obscureKey,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'API key',
                    hintText: 'sk-… or provider token',
                    suffixIcon: IconButton(
                      tooltip: _obscureKey ? 'Show' : 'Hide',
                      onPressed: () =>
                          setState(() => _obscureKey = !_obscureKey),
                      icon: Icon(
                        _obscureKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: DuaColors.cyanSoft,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _clearKey,
                    child: const Text('Clear API key'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _baseUrlCtrl,
                  autocorrect: false,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: AgentSettings.defaultBaseUrl,
                    helperText:
                        'OpenAI-compatible. Change for Groq / OpenRouter.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _modelCtrl,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    hintText: AgentSettings.defaultModel,
                    helperText: 'e.g. gpt-4o-mini, llama-3.3-70b-versatile',
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Supported providers',
                  style: TextStyle(
                    color: DuaColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                _providerTip(
                  'OpenAI',
                  AgentSettings.defaultBaseUrl,
                  'gpt-4o-mini',
                ),
                _providerTip(
                  'Groq',
                  'https://api.groq.com/openai/v1',
                  'llama-3.3-70b-versatile',
                ),
                _providerTip(
                  'OpenRouter',
                  'https://openrouter.ai/api/v1',
                  'openai/gpt-4o-mini',
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Save settings'),
                ),
              ],
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: DuaColors.cyanSoft,
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _privacyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DuaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DuaColors.borderNeon),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Offline stays local. Online needs network + your API key. '
            'Voice can prefer on-device STT.',
            style: TextStyle(
              color: DuaColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            },
            icon: const Icon(Icons.privacy_tip_outlined, size: 18),
            label: const Text('Privacy details'),
          ),
        ],
      ),
    );
  }

  Widget _providerTip(String name, String url, String model) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DuaColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DuaColors.borderNeon),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: DuaColors.cyanSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Base URL: $url\nModel: $model',
              style: const TextStyle(
                color: DuaColors.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
