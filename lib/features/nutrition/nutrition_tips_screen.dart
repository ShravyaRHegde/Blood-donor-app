import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';

class NutritionTipsScreen extends StatelessWidget {
  const NutritionTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            const AppHeader(eyebrow: 'Health', title: 'Nutrition Tips'),
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.hairline)),
              ),
              child: TabBar(
                indicatorColor: AppColors.maroon,
                indicatorWeight: 2,
                labelColor: AppColors.maroon,
                unselectedLabelColor: AppColors.inkMuted,
                dividerColor: Colors.transparent,
                labelStyle: AppText.bodyStrong(size: 13),
                unselectedLabelStyle: AppText.body(size: 13),
                tabs: const [
                  Tab(text: 'Pre-Donation'),
                  Tab(text: 'Post-Donation'),
                  Tab(text: 'General'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _TipsList(tips: _preDonationTips),
                  _TipsList(tips: _postDonationTips),
                  _TipsList(tips: _generalTips),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipsList extends StatelessWidget {
  final List<_Tip> tips;
  const _TipsList({required this.tips});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      itemCount: tips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _TipCard(tip: tips[i]),
    );
  }
}

class _TipCard extends StatelessWidget {
  final _Tip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hairline, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            child: Icon(tip.icon, color: AppColors.maroon, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title, style: AppText.bodyStrong(size: 14)),
                const SizedBox(height: 4),
                Text(
                  tip.body,
                  style: AppText.body(color: AppColors.inkMuted, size: 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip {
  final IconData icon;
  final String title;
  final String body;
  const _Tip(this.icon, this.title, this.body);
}

const _preDonationTips = [
  _Tip(
    Icons.water_drop_outlined,
    'Stay well hydrated',
    'Drink at least 500 ml of water in the 2 hours before donating. Good hydration makes the process faster and reduces dizziness.',
  ),
  _Tip(
    Icons.restaurant_outlined,
    'Eat a light meal',
    'Have a low-fat meal 2–3 hours before your donation. Avoid fatty foods — they can affect blood tests and donation eligibility.',
  ),
  _Tip(
    Icons.nightlight_outlined,
    'Get enough sleep',
    'Aim for at least 7–8 hours the night before. Fatigue can lower your blood pressure and make you feel faint during donation.',
  ),
  _Tip(
    Icons.sports_bar_outlined,
    'Avoid alcohol',
    'Do not drink alcohol for at least 24 hours before donating. Alcohol dehydrates you and affects blood quality.',
  ),
  _Tip(
    Icons.iron_outlined,
    'Eat iron-rich foods',
    'Include spinach, lentils, beans, or lean red meat in your meals the day before. Iron-rich blood is healthier for the recipient.',
  ),
  _Tip(
    Icons.smoke_free_outlined,
    'No smoking',
    'Avoid smoking for at least 2 hours before donation. Nicotine affects blood circulation and oxygen levels.',
  ),
];

const _postDonationTips = [
  _Tip(
    Icons.water_outlined,
    'Rehydrate immediately',
    'Drink an extra 4 glasses of water or juice over the next few hours. This helps your body replace the fluid lost during donation.',
  ),
  _Tip(
    Icons.cookie_outlined,
    'Have a snack',
    'Eat the snack provided at the donation centre. It helps stabilise your blood sugar and prevents dizziness.',
  ),
  _Tip(
    Icons.chair_outlined,
    'Rest for 10–15 minutes',
    'Sit or lie down after donating. Do not rush to stand up — sudden movement can cause lightheadedness.',
  ),
  _Tip(
    Icons.fitness_center_outlined,
    'Avoid heavy exercise',
    'Skip intense workouts, heavy lifting, or strenuous activity for the rest of the day. Your body needs time to recover.',
  ),
  _Tip(
    Icons.local_dining_outlined,
    'Eat iron-rich foods',
    'Red meat, fish, beans, and leafy greens help replenish the iron your blood lost. Most donors recover their iron levels within 4–8 weeks.',
  ),
  _Tip(
    Icons.medical_services_outlined,
    'Watch for dizziness',
    'If you feel faint, lie down with your legs raised. If symptoms persist beyond a few hours, contact a healthcare provider.',
  ),
];

const _generalTips = [
  _Tip(
    Icons.calendar_today_outlined,
    'Donation frequency',
    'Whole blood can be donated every 90 days (3 months). Platelets can be donated more frequently — up to 24 times a year.',
  ),
  _Tip(
    Icons.bloodtype_outlined,
    'Know your blood group',
    'O− donors are universal donors and their blood can be given to anyone in an emergency. AB+ donors are universal recipients.',
  ),
  _Tip(
    Icons.favorite_outline,
    'One donation saves up to 3 lives',
    'A single whole blood donation is split into red cells, platelets, and plasma — each used to help a different patient.',
  ),
  _Tip(
    Icons.monitor_weight_outlined,
    'Eligibility basics',
    'Most donors need to be 18–65 years old, weigh at least 50 kg, and be in good general health on the day of donation.',
  ),
  _Tip(
    Icons.medication_outlined,
    'Medications matter',
    'Some medications may temporarily disqualify you. Always tell the donation staff about any medicines you are taking.',
  ),
  _Tip(
    Icons.volunteer_activism_outlined,
    'Regular donors matter most',
    'Regular donors provide the most reliable supply of safe blood. Consider setting a reminder every 90 days.',
  ),
];