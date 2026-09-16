import 'package:dua/agent/prompts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentPrompts Work vs Agent', () {
    test('system prompts differ', () {
      expect(
        AgentPrompts.systemFor(agentMode: true),
        contains('private mobile assistant'),
      );
      expect(
        AgentPrompts.systemFor(agentMode: false),
        contains('Work mode'),
      );
      expect(
        AgentPrompts.systemFor(agentMode: true),
        isNot(equals(AgentPrompts.systemFor(agentMode: false))),
      );
    });

    test('quick action chips differ by mode', () {
      final agent = AgentPrompts.quickActionsFor(agentMode: true);
      final work = AgentPrompts.quickActionsFor(agentMode: false);
      expect(agent.map((e) => e.$1), contains('Translate text'));
      expect(work.map((e) => e.$1), contains('Action items'));
      expect(agent.map((e) => e.$1).toSet()
          .intersection(work.map((e) => e.$1).toSet()), isEmpty);
    });

    test('greetings and empty hints differ', () {
      expect(AgentPrompts.greetingFor(agentMode: true), contains('Ask me'));
      expect(AgentPrompts.greetingFor(agentMode: false), contains('Work mode'));
      expect(AgentPrompts.emptyHintFor(agentMode: false), contains('Work'));
    });
  });
}
