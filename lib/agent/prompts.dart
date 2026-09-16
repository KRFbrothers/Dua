/// System prompts and quick-action templates for Online Agent / Work modes.
abstract final class AgentPrompts {
  static const String agentSystem = '''
You are Dua, a private mobile assistant. Be warm, concise, and helpful.
Reply in Hindi, English, or Hinglish to match the user. Prefer short, clear answers.
You help with everyday questions, writing, translation, summaries, and light planning.
Do not claim to control the phone or access local files unless the user pastes content.
''';

  static const String workSystem = '''
You are Dua Work mode — a task-focused productivity assistant on the user's phone.
Be structured, action-oriented, and concise. Prefer checklists, drafts, and next steps.
Reply in Hindi, English, or Hinglish to match the user.
Help with scheduling language, emails, summaries, translations, and writing for work.
Do not invent calendar events as if they were booked unless the user confirms.
Lead with the deliverable (draft / checklist / agenda), then brief follow-ups if needed.
''';

  static String systemFor({required bool agentMode}) =>
      agentMode ? agentSystem : workSystem;

  /// Agent-mode quick actions (everyday assistant).
  static const List<(String label, String prompt)> agentQuickActions = [
    (
      'Schedule a meeting',
      'Help me schedule a meeting. Ask for title, date/time, duration, and attendees if missing, then draft a clear invite message and a short agenda.',
    ),
    (
      'Translate text',
      'I need a translation. Ask what text to translate and the target language if missing, then provide an accurate translation plus a brief natural alternative if useful.',
    ),
    (
      'Summarize email',
      'I want an email summarized. Ask me to paste the email if I have not, then give: (1) one-line summary, (2) key points as bullets, (3) suggested reply if action is needed.',
    ),
    (
      'Write something',
      'Help me write something. Ask what I need (message, email, note, caption) and the tone if unclear, then draft a polished version I can copy.',
    ),
  ];

  /// Work-mode quick actions (productivity-focused chips).
  static const List<(String label, String prompt)> workQuickActions = [
    (
      'New task',
      'Help me capture a new task. Ask for title and deadline if missing, then give a clear task statement, checklist of next steps, and a one-line success criteria.',
    ),
    (
      'Outline',
      'Draft a crisp outline. Ask for topic and audience if missing, then give a structured outline with sections and bullet points I can expand.',
    ),
    (
      'Email draft',
      'Help me draft a professional email. Ask for recipient/context if missing, then give a polished email plus a shorter alternative.',
    ),
    (
      'Prioritize today',
      'Help me prioritize today. Ask for my task list if missing, then rank Must / Should / Later with one-line reasons.',
    ),
  ];

  /// Back-compat alias used by older call sites.
  static const List<(String label, String prompt)> quickActions =
      agentQuickActions;

  static List<(String label, String prompt)> quickActionsFor({
    required bool agentMode,
  }) =>
      agentMode ? agentQuickActions : workQuickActions;

  static String greetingFor({required bool agentMode}) => agentMode
      ? "Hello, I'm Dua. Ask me anything."
      : "Work mode on. Let's ship tasks — agendas, replies, priorities.";

  static String emptyHintFor({required bool agentMode}) => agentMode
      ? 'Try a quick action or type a question.'
      : 'Pick a Work chip, open the Work board, or describe a deliverable.';
}
