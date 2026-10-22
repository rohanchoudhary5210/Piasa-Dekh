import 'package:flutter/material.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/features/notifications/domain/services/notification_manager.dart';

class NotificationPermissionSheet extends StatefulWidget {
  final NotificationManager notificationManager;
  final VoidCallback? onGranted;
  final VoidCallback? onDenied;

  const NotificationPermissionSheet({
    super.key,
    required this.notificationManager,
    this.onGranted,
    this.onDenied,
  });

  static Future<bool> show(
    BuildContext context, {
    required NotificationManager notificationManager,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => NotificationPermissionSheet(
        notificationManager: notificationManager,
        onGranted: () => Navigator.pop(ctx, true),
        onDenied: () => Navigator.pop(ctx, false),
      ),
    );
    return result ?? false;
  }

  @override
  State<NotificationPermissionSheet> createState() =>
      _NotificationPermissionSheetState();
}

class _NotificationPermissionSheetState
    extends State<NotificationPermissionSheet> {
  bool _isRequesting = false;

  Future<void> _handleRequest() async {
    setState(() => _isRequesting = true);
    try {
      final granted = await widget.notificationManager.requestPermission();
      if (!mounted) return;
      if (granted) {
        widget.onGranted?.call();
      } else {
        widget.onDenied?.call();
      }
    } catch (_) {
      if (mounted) widget.onDenied?.call();
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon Header
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.manaPurple.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.manaPurple.withValues(alpha: 0.4),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.manaPurple,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Stay on Track with Smart Alerts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'SalaryQuest uses timely, gentle reminders to protect your streak and prevent surprise budget overruns.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Benefits list
            _buildBenefitRow(
              icon: Icons.shield_outlined,
              title: 'Streak Protection',
              subtitle: 'Evening alerts when your active streak is at risk of breaking.',
            ),
            const SizedBox(height: 12),
            _buildBenefitRow(
              icon: Icons.warning_amber_rounded,
              title: '80% Daily Budget Warning',
              subtitle: 'Get notified before you overspend today\'s allocated pool.',
            ),
            const SizedBox(height: 12),
            _buildBenefitRow(
              icon: Icons.bedtime_outlined,
              title: 'Respectful & Private',
              subtitle: 'Capped at 2/day, quiet hours (10 PM - 7 AM), and lockscreen privacy.',
            ),
            const SizedBox(height: 24),

            // Action Buttons
            ElevatedButton(
              onPressed: _isRequesting ? null : _handleRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.manaPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isRequesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Allow Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => widget.onDenied?.call(),
              child: const Text(
                'Not Now (Continue without Alerts)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.xpBlue, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
