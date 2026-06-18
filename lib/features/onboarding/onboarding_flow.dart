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

  void _next() {
    if (_page < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _OnboardingPage1(),
                  _OnboardingPage2(),
                  _OnboardingPage3(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => _Dot(active: i == _page)),
                  ),
                  const SizedBox(height: 24),
                  if (_page < 2)
                    ElevatedButton(onPressed: _next, child: const Text('Next'))
                  else ...[
                    ElevatedButton(
                      onPressed: _finish,
                      child: const Text('Get started'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Continue without account', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
    return Container(
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

class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Paperly', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 12),
          Text(
            'Your day, on paper.',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('One day at a time.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          const Text(
            'Each day gets its own page — a to-do list and a time-blocked schedule. No clutter, no overwhelm.',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 32),
          _FeatureRow(icon: Icons.check_box_outline_blank, text: 'Capture todos as they come'),
          const SizedBox(height: 12),
          _FeatureRow(icon: Icons.schedule, text: 'Block out your time'),
          const SizedBox(height: 12),
          _FeatureRow(icon: Icons.offline_bolt_outlined, text: 'Works fully offline'),
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
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_sync_outlined, size: 64, color: AppColors.accent),
          SizedBox(height: 24),
          Text('Sync across devices', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          SizedBox(height: 16),
          Text(
            'Sign in to keep your data backed up and accessible everywhere. Or start without an account — you can always add one later.',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
