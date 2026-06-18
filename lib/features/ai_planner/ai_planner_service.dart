import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/env.dart';
import 'plan_result.dart';

const _systemPrompt = '''
You are a planning assistant for an ADHD daily planner app. The user will give you a brain dump of everything on their mind for the day. Your job is to extract clear, actionable todos and realistic time blocks from it.

Return ONLY valid JSON — no explanation, no markdown, no backticks. The JSON must match this exact structure:

{
  "todos": [
    { "title": "string" }
  ],
  "time_blocks": [
    {
      "label": "string",
      "start_time": "HH:MM",
      "end_time": "HH:MM",
      "note": "string or null",
      "color": "slate | sage | terracotta | lavender | sand"
    }
  ]
}

Rules:
- Todos are short, specific, verb-first (e.g. "Call mom", "Buy groceries", "Finish report intro")
- Time blocks only appear when the user mentions a specific time or a clearly time-sensitive task
- If no time is implied, skip time blocks — don't invent times
- Keep todos under 60 characters
- Maximum 8 todos, maximum 5 time blocks
- Pick the color that best fits the block's nature (e.g. terracotta for urgent, sage for personal, slate for work)
- If the brain dump is too vague or empty, return { "todos": [], "time_blocks": [] }
''';

class PlanningException implements Exception {
  final String message;
  const PlanningException(this.message);
}

class AiPlannerService {
  Future<PlanResult> planDay(String brainDump) async {
    if (!Env.hasOpenAi) {
      throw const PlanningException("AI planning isn't set up yet.");
    }

    final http.Response response;
    try {
      response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${Env.openAiApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': brainDump},
          ],
          'response_format': {'type': 'json_object'},
          'max_tokens': 1000,
        }),
      ).timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const PlanningException("Couldn't reach the AI. Check your connection and try again.");
    }

    if (response.statusCode == 401) {
      throw const PlanningException("AI planning isn't set up yet.");
    }
    if (response.statusCode != 200) {
      throw const PlanningException("Couldn't reach the AI. Check your connection and try again.");
    }

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content = body['choices'][0]['message']['content'] as String;
      final data = jsonDecode(content) as Map<String, dynamic>;

      final todos = (data['todos'] as List? ?? [])
          .map((t) => PlannedTodo(title: t['title'] as String))
          .toList();

      final blocks = (data['time_blocks'] as List? ?? []).map((b) {
        return PlannedBlock(
          label: b['label'] as String,
          startTime: b['start_time'] as String,
          endTime: b['end_time'] as String,
          note: b['note'] as String?,
          color: b['color'] as String? ?? 'slate',
        );
      }).toList();

      return PlanResult(todos: todos, timeBlocks: blocks);
    } catch (_) {
      throw const PlanningException("Something went wrong with the response. Try rephrasing your dump.");
    }
  }
}
