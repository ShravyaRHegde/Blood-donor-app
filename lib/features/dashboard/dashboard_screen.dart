import '../../data/repositories/stats_repository.dart';
import '../nutrition/nutrition_tips_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/request_model.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/blood_drop.dart';
import '../../shared/widgets/card_shell.dart';
import '../../state/auth_provider.dart';
import '../../state/donor_provider.dart';
import '../../state/notification_provider.dart';
import '../../state/request_provider.dart';
import '../donor/donor_registration_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../receiver/receiver_registration_screen.dart';
import 'location_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().current;
    if (user == null) return const SizedBox.shrink();

    final isOffline = context.watch<AuthProvider>().databaseReachable == false;
    final donorsMine = context.watch<DonorProvider>().byOwner(user.email);
    final sentRequests = context.watch<RequestProvider>().bySender(user.email);
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    // Start notification stream for logged-in user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().init(user.uid);
    });

    final activeDonorTokens = donorsMine.where((d) => !d.closed).length;
    final activeSentRequests =
        sentRequests.where((r) => r.status.isActive).length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (isOffline)
                Container(
                  width: double.infinity,
                  color: AppColors.warning,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 15, color: AppColors.onMaroon),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No connection to server.',
                          style: AppText.caption(color: AppColors.onMaroon, size: 12)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.read<AuthProvider>().recheckConnection(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.onMaroon.withOpacity(0.2),
                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                          ),
                          child: Text(
                            'Retry',
                            style: AppText.caption(color: AppColors.onMaroon, size: 12)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.maroon,
                  onRefresh: () => context.read<AuthProvider>().recheckConnection(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _TopBar(
                              name: user.name,
                              unreadCount: unreadCount,
                              onBellTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _LocationBar(
                              location: user.location,
                              onTap: () async {
                                await showLocationSheet(context, initial: user.location);
                              },
                            ),
                            const SizedBox(height: 32),
                            Text('How can you help today?', style: AppText.headline(size: 28)),
                            const SizedBox(height: 4),
                            Text(
                              'Pick a role for this session — you can switch anytime.',
                              style: AppText.body(color: AppColors.inkMuted, size: 14),
                            ),
                            const SizedBox(height: 22),
                            _RoleCard(
                              title: 'Donate blood',
                              body: 'Register yourself (or a friend) as a donor. '
                                  'We\'ll show your token to receivers nearby.',
                              icon: Icons.volunteer_activism_outlined,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const DonorRegistrationScreen()),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _RoleCard(
                              title: 'Receive blood',
                              body: 'Register the patient and we\'ll show compatible '
                                  'donors nearby with a way to reach them.',
                              icon: Icons.bloodtype_outlined,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ReceiverRegistrationScreen()),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _RoleCard(
                              title: 'Nutrition Tips',
                              body: 'What to eat before and after donation, and general health tips for donors.',
                              icon: Icons.restaurant_menu_outlined,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const NutritionTipsScreen()),
                              ),
                            ),
                            const SizedBox(height: 34),
Text('Global impact', style: AppText.title(size: 15)),
const SizedBox(height: 12),
StreamBuilder<Map<String, int>>(
  stream: StatsRepository.stream(),
  builder: (context, snap) {
    final data = snap.data ?? {'donors': 0, 'requests': 0, 'donations': 0};
    return Row(
      children: [
        Expanded(child: _StatTile(number: data['donations']!, label: 'Donations completed')),
        const SizedBox(width: 10),
        Expanded(child: _StatTile(number: data['donors']!,    label: 'Donors registered')),
        const SizedBox(width: 10),
        Expanded(child: _StatTile(number: data['requests']!,  label: 'Requests sent')),
      ],
    );
  },
),
if (activeDonorTokens > 0 || activeSentRequests > 0) ...[
  const SizedBox(height: 20),
  Text('Your activity', style: AppText.title(size: 15)),
  const SizedBox(height: 12),
  Row(
    children: [
      Expanded(child: _StatTile(number: activeDonorTokens,  label: 'Active donor tokens')),
      const SizedBox(width: 10),
      Expanded(child: _StatTile(number: activeSentRequests, label: 'Open requests sent')),
    ],
  ),
],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AppBottomNav(
                onTap: (a) {
                  switch (a) {
                    case BottomNavAction.donate:
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const DonorRegistrationScreen(),
                      ));
                      break;
                    case BottomNavAction.receive:
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ReceiverRegistrationScreen(),
                      ));
                      break;
                    case BottomNavAction.profile:
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ));
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String name;
  final int unreadCount;
  final VoidCallback onBellTap;

  const _TopBar({
    required this.name,
    required this.unreadCount,
    required this.onBellTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = name.split(' ').first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Hello, $firstName.',
            style: AppText.headline(size: 26),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: onBellTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, size: 24, color: AppColors.ink),
              if (unreadCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.maroon,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: AppText.caption(color: AppColors.onMaroon, size: 9)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const BloodDrop(size: 22, color: AppColors.red),
      ],
    );
  }
}

class _LocationBar extends StatelessWidget {
  final String location;
  final VoidCallback onTap;
  const _LocationBar({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CardShell(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.place_outlined, size: 18, color: AppColors.maroon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You're in",
                    style: AppText.caption(color: AppColors.inkMuted, size: 11.5)),
                const SizedBox(height: 2),
                Text(
                  location.isEmpty ? 'Set your location' : location,
                  style: AppText.bodyStrong(size: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text('Change', style: AppText.bodyStrong(color: AppColors.maroon, size: 13)),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardShell(
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
                child: Icon(icon, color: AppColors.maroon, size: 22),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.headline(size: 22).copyWith(height: 1.1),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: AppText.body(color: AppColors.inkMuted, size: 13.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14, left: 6),
            child: Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int number;
  final String label;
  const _StatTile({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number',
            style: AppText.display(size: 38, color: AppColors.maroon).copyWith(height: 1.0),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppText.caption(color: AppColors.ink).copyWith(height: 1.3),
          ),
        ],
      ),
    );
  }
}