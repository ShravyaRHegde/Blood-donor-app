import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/blood_drop.dart';
import 'donor_registration_screen.dart';

class DonorPreScreeningScreen extends StatefulWidget {
  const DonorPreScreeningScreen({super.key});

  @override
  State<DonorPreScreeningScreen> createState() =>
      _DonorPreScreeningScreenState();
}

class _DonorPreScreeningScreenState extends State<DonorPreScreeningScreen> {
  final PageController _controller = PageController();
  int _current = 0;
  String? _failReason;
  String? _lastDonationDate;

  // Questions: text, yesBlocks, noBlocks
  static const _questions = [
    (
      q: 'Are you 18 years or older?',
      yesBlocks: false,
      noBlocks: true,
      failMsg: 'You must be at least 18 years old to donate blood.',
    ),
    (
      q: 'Do you weigh at least 50 kg?',
      yesBlocks: false,
      noBlocks: true,
      failMsg: 'Donors must weigh at least 50 kg to donate safely.',
    ),
    (
      q: 'Are you currently feeling well — no fever, cold, or infection?',
      yesBlocks: false,
      noBlocks: true,
      failMsg:
          'You must be in good health on the day of donation. Please try again once you recover.',
    ),
    (
      q: 'Have you had major surgery in the last 6 months?',
      yesBlocks: true,
      noBlocks: false,
      failMsg:
          'You must wait at least 6 months after major surgery before donating.',
    ),
    (
      q: 'Are you currently on antibiotics or blood-thinning medication?',
      yesBlocks: true,
      noBlocks: false,
      failMsg:
          'You cannot donate while on antibiotics or blood-thinning medication. Please consult your doctor.',
    ),
  ];

  // Total pages = 5 questions + 1 date picker page
  int get _totalPages => _questions.length + 1;

  void _answer(bool yes) {
    final q = _questions[_current];
    final blocked = (yes && q.yesBlocks) || (!yes && q.noBlocks);
    if (blocked) {
      setState(() => _failReason = q.failMsg);
      return;
    }
    _nextPage();
  }

  void _nextPage() {
    if (_current < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _current++);
    }
  }

  void _submitDate() {
    if (_lastDonationDate == null) {
      // No previous donation — pass
      _proceed();
      return;
    }
    try {
      final last = DateFormat('dd/MM/yyyy').parseStrict(_lastDonationDate!);
      final diff = DateTime.now().difference(last).inDays;
      if (diff < 180) {
        setState(() => _failReason =
            'A minimum gap of 6 months (180 days) is required between donations. You last donated ${diff} days ago.');
        return;
      }
    } catch (_) {
      // Invalid date format — just proceed
    }
    _proceed();
  }

  void _proceed() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DonorRegistrationScreen(
          prefillLastDonation: _lastDonationDate ?? '',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failReason != null) {
      return _FailScreen(
        reason: _failReason!,
        onBack: () => Navigator.of(context).pop(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const AppHeader(
            eyebrow: 'Donor',
            title: 'Pre-Screening',
          ),
          // Progress bar
          Container(
            height: 3,
            color: AppColors.hairline,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_current + 1) / _totalPages,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: AppColors.maroon,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  'Question ${_current + 1} of $_totalPages',
                  style: AppText.caption(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // 5 yes/no question pages
                ..._questions.map((q) => _QuestionPage(
                      question: q.q,
                      onYes: () => _answer(true),
                      onNo: () => _answer(false),
                    )),
                // Last donation date page
                _DatePage(
                  onDateSelected: (date) =>
                      setState(() => _lastDonationDate = date),
                  onSubmit: _submitDate,
                  selectedDate: _lastDonationDate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  final String question;
  final VoidCallback onYes;
  final VoidCallback onNo;
  const _QuestionPage({
    required this.question,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BloodDrop(size: 28, color: AppColors.maroon),
          const SizedBox(height: 28),
          Text(question, style: AppText.headline(size: 24)),
          const Spacer(),
          AppButton(
            label: 'Yes',
            onPressed: onYes,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'No',
            kind: AppButtonKind.outline,
            onPressed: onNo,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DatePage extends StatelessWidget {
  final String? selectedDate;
  final ValueChanged<String?> onDateSelected;
  final VoidCallback onSubmit;
  const _DatePage({
    required this.selectedDate,
    required this.onDateSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BloodDrop(size: 28, color: AppColors.maroon),
          const SizedBox(height: 28),
          Text(
            'When did you last donate blood?',
            style: AppText.headline(size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'If this is your first time, tap "Never donated".',
            style: AppText.body(color: AppColors.inkMuted, size: 14),
          ),
          const SizedBox(height: 32),
          // Date picker button
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now.subtract(const Duration(days: 180)),
                firstDate: DateTime(now.year - 10),
                lastDate: now,
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: AppColors.maroon,
                          onPrimary: AppColors.onMaroon,
                        ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                onDateSelected(DateFormat('dd/MM/yyyy').format(picked));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedDate != null
                      ? AppColors.maroon
                      : AppColors.hairlineStrong,
                  width: selectedDate != null ? 1.5 : 1,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.maroon),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate ?? 'Select date',
                    style: AppText.body(
                      color: selectedDate != null
                          ? AppColors.ink
                          : AppColors.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          AppButton(
            label: selectedDate != null ? 'Continue' : 'Never donated',
            onPressed: onSubmit,
          ),
          if (selectedDate != null) ...[
            const SizedBox(height: 12),
            AppButton(
              label: 'Clear date',
              kind: AppButtonKind.ghost,
              onPressed: () => onDateSelected(null),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FailScreen extends StatelessWidget {
  final String reason;
  final VoidCallback onBack;
  const _FailScreen({required this.reason, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const AppHeader(
            eyebrow: 'Donor',
            title: 'Pre-Screening',
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius:
                              BorderRadius.all(Radius.circular(2)),
                        ),
                        child: const Icon(Icons.info_outline_rounded,
                            size: 28, color: AppColors.maroon),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Unable to proceed',
                        style: AppText.headline(size: 22),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        reason,
                        style:
                            AppText.body(color: AppColors.inkMuted, size: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        label: 'Go back',
                        kind: AppButtonKind.outline,
                        onPressed: onBack,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}