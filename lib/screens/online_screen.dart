import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';
import '../widgets/agent_node_graphic.dart';
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
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatBubble> _messages = [
    const _ChatBubble(
      text: "Hello, I'm Dua. Ask me anything.",
      isUser: false,
    ),
  ];

  static const _quickActions = [
    ('Schedule a meeting', Icons.event_outlined),
    ('Translate text', Icons.translate),
    ('Summarize email', Icons.mail_outline),
    ('Write something', Icons.edit_outlined),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatBubble(text: text, isUser: true));
      _messages.add(
        _ChatBubble(
          text: _agentMode
              ? 'Theek. Main abhi stub mode mein hoon — LLM wiring Phase 2 mein aayega.\n\n"$text" samajh liya.'
              : 'Work mode stub. Task list / persona later.',
          isUser: false,
        ),
      );
      _controller.clear();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Online'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ModeToggle(
              agentSelected: _agentMode,
              onChanged: (agent) => setState(() => _agentMode = agent),
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
              itemCount: _messages.length,
              itemBuilder: (context, i) {
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
              itemCount: _quickActions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final (label, icon) = _quickActions[i];
                return ActionChip(
                  avatar: Icon(icon, size: 16, color: DuaColors.cyanSoft),
                  label: Text(label),
                  labelStyle: const TextStyle(
                    color: DuaColors.textPrimary,
                    fontSize: 12,
                  ),
                  backgroundColor: DuaColors.card,
                  side: const BorderSide(color: DuaColors.borderNeon),
                  onPressed: () => _send(label),
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
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Ask Agent…',
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
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded, color: DuaColors.cyan),
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
