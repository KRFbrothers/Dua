import 'package:flutter/material.dart';

import '../agent/agent_settings.dart';
import '../agent/llm_client.dart';
import '../agent/prompts.dart';
import '../theme/dua_colors.dart';
import '../widgets/agent_node_graphic.dart';
import 'agent_settings_screen.dart';
import 'voice_screen.dart';

class OnlineScreen extends StatefulWidget {
  const OnlineScreen({super.key});

  @override
  State<OnlineScreen> createState() => _OnlineScreenState();
}

class _ChatBubble {
  const _ChatBubble({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

class _OnlineScreenState extends State<OnlineScreen> {
  bool _agentMode = true;
  bool _busy = false;
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _llm = LlmClient();
  final List<_ChatBubble> _messages = [
    const _ChatBubble(
      text: "Hello, I'm Dua. Ask me anything.",
      isUser: false,
    ),
  ];
  final List<ChatMessage> _history = [];

  static const _quickIcons = <String, IconData>{
    'Schedule a meeting': Icons.event_outlined,
    'Translate text': Icons.translate,
    'Summarize email': Icons.mail_outline,
    'Write something': Icons.edit_outlined,
  };

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _llm.close();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AgentSettingsScreen()),
    );
  }

  Future<void> _send({String? displayText, String? apiText}) async {
    if (_busy) return;
    final shown = (displayText ?? _controller.text).trim();
    final forModel = (apiText ?? shown).trim();
    if (shown.isEmpty || forModel.isEmpty) return;

    setState(() {
      _messages.add(_ChatBubble(text: shown, isUser: true));
      _controller.clear();
      _busy = true;
    });
    _history.add(ChatMessage(role: 'user', content: forModel));
    _scrollToEnd();

    final settings = await AgentSettings.load();
    if (!settings.hasApiKey) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _messages.add(
          const _ChatBubble(
            text:
                'API key missing. Open Settings (gear icon) to paste your key.',
            isUser: false,
          ),
        );
      });
      _scrollToEnd();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('API key required'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'Settings', onPressed: _openSettings),
        ),
      );
      return;
    }

    final apiMessages = <ChatMessage>[
      ChatMessage(
        role: 'system',
        content: AgentPrompts.systemFor(agentMode: _agentMode),
      ),
      ..._history,
    ];

    final result = await _llm.chat(settings: settings, messages: apiMessages);
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result is LlmSuccess) {
        _messages.add(_ChatBubble(text: result.content, isUser: false));
        _history.add(ChatMessage(role: 'assistant', content: result.content));
      } else if (result is LlmFailure) {
        _messages.add(_ChatBubble(text: result.message, isUser: false));
        // Drop the last user turn from history so retries stay clean.
        if (_history.isNotEmpty && _history.last.role == 'user') {
          _history.removeLast();
        }
        if (result.needsSettings) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: _openSettings,
                ),
              ),
            );
          });
        }
      }
    });
    _scrollToEnd();
  }

  void _onQuickAction(String label, String prompt) {
    _send(displayText: label, apiText: prompt);
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _messages.length + (_busy ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Online'),
        actions: [
          IconButton(
            tooltip: 'Agent settings',
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ModeToggle(
              agentSelected: _agentMode,
              onChanged: (agent) {
                if (_busy) return;
                setState(() {
                  _agentMode = agent;
                  // Fresh context when switching persona.
                  _history.clear();
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          const AgentNodeGraphic(size: 140),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: itemCount,
              itemBuilder: (context, i) {
                if (_busy && i == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: DuaColors.surfaceElevated,
                        border: Border.all(color: DuaColors.borderNeon),
                      ),
                      child: const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                final m = _messages[i];
                return Align(
                  alignment:
                      m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: m.isUser
                          ? DuaColors.blue.withValues(alpha: 0.35)
                          : DuaColors.surfaceElevated,
                      border: Border.all(
                        color: m.isUser
                            ? DuaColors.cyan.withValues(alpha: 0.4)
                            : DuaColors.borderNeon,
                      ),
                    ),
                    child: Text(
                      m.text,
                      style: const TextStyle(
                        color: DuaColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AgentPrompts.quickActions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final (label, prompt) = AgentPrompts.quickActions[i];
                final icon =
                    _quickIcons[label] ?? Icons.auto_awesome_outlined;
                return ActionChip(
                  avatar: Icon(icon, size: 16, color: DuaColors.cyanSoft),
                  label: Text(label),
                  labelStyle: const TextStyle(
                    color: DuaColors.textPrimary,
                    fontSize: 12,
                  ),
                  backgroundColor: DuaColors.card,
                  side: const BorderSide(color: DuaColors.borderNeon),
                  onPressed: _busy ? null : () => _onQuickAction(label, prompt),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Attach (stub)',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Attach stub'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline,
                      color: DuaColors.cyanSoft),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_busy,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: _agentMode ? 'Ask Agent…' : 'Ask Work…',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Voice',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VoiceScreen()),
                  ),
                  icon: const Icon(Icons.mic_none, color: DuaColors.cyanSoft),
                ),
                IconButton(
                  tooltip: 'Send',
                  onPressed: _busy ? null : () => _send(),
                  icon: Icon(
                    Icons.send_rounded,
                    color: _busy ? DuaColors.textMuted : DuaColors.cyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.agentSelected,
    required this.onChanged,
  });

  final bool agentSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: DuaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DuaColors.borderNeon),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg('Agent', agentSelected, () => onChanged(true)),
          _seg('Work', !agentSelected, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _seg(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: selected ? DuaColors.neonGradient : null,
          color: selected ? null : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : DuaColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
