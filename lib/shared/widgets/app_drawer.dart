import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/blood_drop.dart';
import '../../state/auth_provider.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/auth/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().current;

    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Header ──────────────────────────────────
            Container(
              color: AppColors.maroon,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BloodDrop(size: 28, color: AppColors.onMaroon),
                  const SizedBox(height: 14),
                  Text(
                    'Blood Donor\n& Receiver',
                    style: AppText.headline(color: AppColors.onMaroon, size: 22),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: AppText.caption(
                          color: AppColors.onMaroonMuted, size: 12),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Profile ──────────────────────────────────
            _DrawerItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

            const Divider(height: 1, color: AppColors.hairline,
                indent: 20, endIndent: 20),

            // ── About ────────────────────────────────────
            _DrawerItem(
              icon: Icons.info_outline_rounded,
              label: 'About',
              onTap: () {
                Navigator.of(context).pop();
                _showAbout(context);
              },
            ),

            const Spacer(),

            const Divider(height: 1, color: AppColors.hairline),

            // ── Logout ───────────────────────────────────
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Log out',
              color: AppColors.danger,
              onTap: () async {
                Navigator.of(context).pop();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                    title: Text('Log out?', style: AppText.title(size: 17)),
                    content: Text(
                      'You can log back in with your email and password.',
                      style: AppText.body(
                          color: AppColors.inkMuted, size: 13.5),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Stay',
                            style: AppText.button(
                                color: AppColors.ink, size: 13)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Log out',
                            style: AppText.button(
                                color: AppColors.danger, size: 13)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AuthProvider>().logOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.maroon,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                    child: const Center(
                      child: BloodDrop(
                          size: 20, color: AppColors.onMaroon),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Blood Donor & Receiver',
                        style: AppText.title(size: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Version 1.0.0',
                  style:
                      AppText.caption(color: AppColors.inkMuted, size: 12)),
              const SizedBox(height: 12),
              Text(
                'Blood Donor & Receiver connects people who need blood '
                'with willing donors — fast. Register as a donor in under '
                'a minute, or find compatible donors nearby when someone '
                'you love needs blood urgently.',
                style: AppText.body(color: AppColors.ink, size: 13.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No paperwork. No phone trees. Just people helping people.',
                style: AppText.body(color: AppColors.inkMuted, size: 13),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: AppColors.surfaceMuted,
                child: Text(
                  'Built as an Android development mini project.\n'
                  'Powered by Flutter & Firebase.',
                  style: AppText.caption(
                      color: AppColors.inkMuted, size: 12),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  child: Text('Close',
                      style: AppText.button(
                          color: AppColors.onMaroon, size: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 16),
              Text(label,
                  style: AppText.body(color: color, size: 15)
                      .copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
}