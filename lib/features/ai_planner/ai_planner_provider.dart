import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_planner_service.dart';
import 'plan_result.dart';

sealed class AiPlannerState {}

class AiPlannerIdle extends AiPlannerState {}

class AiPlannerLoading extends AiPlannerState {}

class AiPlannerResult extends AiPlannerState {
  final PlanResult result;
  AiPlannerResult(this.result);
}

class AiPlannerError extends AiPlannerState {
  final String message;
  AiPlannerError(this.message);
}

class AiPlannerNotifier extends Notifier<AiPlannerState> {
  final _service = AiPlannerService();

  @override
  AiPlannerState build() => AiPlannerIdle();

  Future<void> plan(String brainDump) async {
    state = AiPlannerLoading();
    try {
      final result = await _service.planDay(brainDump);
      state = AiPlannerResult(result);
    } on PlanningException catch (e) {
      state = AiPlannerError(e.message);
    } catch (_) {
      state = AiPlannerError("Couldn't reach the AI. Check your connection and try again.");
    }
  }

  void reset() => state = AiPlannerIdle();
}

final aiPlannerProvider =
    NotifierProvider<AiPlannerNotifier, AiPlannerState>(AiPlannerNotifier.new);
