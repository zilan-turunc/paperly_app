import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';

const _onboardedKey = 'onboarded';

Future<bool> checkOnboarded() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardedKey) ?? false;
}

Future<void> markOnboarded() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_onboardedKey, true);
}

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingFlow({super.key, required this.onDone});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = PageController();
  int _page = 0;
  static const _total = 4;

  void _next() {
    if (_page < _total - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut);
    }
  }

  Future<void> _finish() async {
    await markOnboarded();
    widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _WelcomePage(),
                  _TodoPage(),
                  _TimeBlockPage(),
                  _AiPage(),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        _total, (i) => _Dot(active: i == _page)),
                  ),
                  const SizedBox(height: 20),
                  if (_page < _total - 1)
                    ElevatedButton(
                        onPressed: _next, child: const Text('Next'))
                  else ...[
                    ElevatedButton(
                      onPressed: _finish,
                      child: const Text('Get started'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Continue without account',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.accent : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ── Page 1: Welcome ────────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.article_outlined,
                size: 36, color: AppColors.accent),
          ),
          const SizedBox(height: 28),
          const Text('Paperly',
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5)),
          const SizedBox(height: 10),
          const Text('Your day, on paper.',
              style: TextStyle(fontSize: 20, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          const _FeatureRow(
              icon: Icons.check_box_outline_blank,
              text: 'Capture todos as they come'),
          const SizedBox(height: 14),
          const _FeatureRow(
              icon: Icons.schedule_outlined,
              text: 'Block out your time'),
          const SizedBox(height: 14),
          const _FeatureRow(
              icon: Icons.auto_fix_high_outlined,
              text: 'Let AI plan your day'),
          const SizedBox(height: 14),
          const _FeatureRow(
              icon: Icons.offline_bolt_outlined,
              text: 'Works fully offline'),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accent),
        const SizedBox(width: 12),
        Text(text,
            style: const TextStyle(
                fontSize: 15, color: AppColors.textPrimary)),
      ],
    );
  }
}

// ── Page 2: To-do list ─────────────────────────────────────────────────────────

class _TodoPage extends StatelessWidget {
  const _TodoPage();

  static const _items = [
    (done: true, text: 'Morning run'),
    (done: true, text: 'Review design doc'),
    (done: false, text: 'Call with Sarah'),
    (done: false, text: 'Finish proposal'),
    (done: false, text: 'Book dentist'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('One day at a time.',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3)),
          const SizedBox(height: 10),
          const Text(
              'Each day gets its own page. Capture todos as they come — check them off as you go.',
              style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5)),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _items.length; i++) ...[
                  _MockTodoItem(
                      done: _items[i].done, text: _items[i].text),
                  if (i < _items.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MockTodoItem extends StatelessWidget {
  final bool done;
  final String text;
  const _MockTodoItem({required this.done, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: done ? AppColors.accent : Colors.transparent,
              border: Border.all(
                  color: AppColors.accent, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: done
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: done
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              decoration:
                  done ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Time blocks ────────────────────────────────────────────────────────

class _TimeBlockPage extends StatelessWidget {
  const _TimeBlockPage();

  static const _blocks = [
    (color: AppColors.blockSlate, name: 'Deep work', time: '9:00 – 11:00 AM'),
    (color: AppColors.blockSage, name: 'Team standup', time: '11:00 – 11:30 AM'),
    (color: AppColors.blockSand, name: 'Lunch break', time: '12:30 – 1:30 PM'),
    (color: AppColors.blockTerracotta, name: 'Client call', time: '2:00 – 3:00 PM'),
    (color: AppColors.blockLavender, name: 'Personal time', time: '6:00 – 8:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Block out your time.',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3)),
          const SizedBox(height: 10),
          const Text(
              'Schedule your day with color-coded time blocks. See exactly when things happen and how much room you have.',
              style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5)),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final b in _blocks) ...[
                  _MockBlockItem(color: b.color, name: b.name, time: b.time),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final c in [
                AppColors.blockSlate,
                AppColors.blockSage,
                AppColors.blockTerracotta,
                AppColors.blockLavender,
                AppColors.blockSand,
              ])
                Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                        color: c, borderRadius: BorderRadius.circular(3)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('5 color labels to keep things clear',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MockBlockItem extends StatelessWidget {
  final Color color;
  final String name;
  final String time;
  const _MockBlockItem(
      {required this.color, required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            Text(time,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

// ── Page 4: AI planner ─────────────────────────────────────────────────────────

class _AiPage extends StatelessWidget {
  const _AiPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Let AI plan your day.',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3)),
          const SizedBox(height: 10),
          const Text(
              'Overwhelmed? Tap the wand icon, brain-dump everything on your mind, and get back a clean time-blocked plan.',
              style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5)),
          const SizedBox(height: 28),
          // Brain dump input mock
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'need to write the proposal, have a 2pm call, want to go for a run, follow up with Jake about the invoice...',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.auto_fix_high_outlined,
                  size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              const Text('AI plan ready',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 10),
          // AI result mock
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha:0.06),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha:0.2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in [
                  '9:00 – 10:30 · Write proposal',
                  '11:00 – 11:15 · Follow up with Jake',
                  '12:00 – 12:30 · Run',
                  '2:00 – 3:00 · Client call',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(item,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('One tap to apply the plan to your day',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
