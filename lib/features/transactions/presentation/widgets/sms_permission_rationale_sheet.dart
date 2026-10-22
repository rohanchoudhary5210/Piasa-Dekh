import 'package:flutter/material.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/services/native_sms_service.dart';

/// Luxury Obsidian Modal Explaining Local, Private SMS Expense Tracking
class SmsPermissionRationaleSheet extends StatefulWidget {
  final NativeSmsService smsService;
  final VoidCallback? onGranted;
  final VoidCallback? onDenied;

  const SmsPermissionRationaleSheet({
    super.key,
    required this.smsService,
    this.onGranted,
    this.onDenied,
  });

  /// Displays the rationale sheet modally. Returns `true` if permission was granted.
  static Future<bool> show(
    BuildContext context, {
    required NativeSmsService smsService,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SmsPermissionRationaleSheet(
        smsService: smsService,
        onGranted: () => Navigator.pop(ctx, true),
        onDenied: () => Navigator.pop(ctx, false),
      ),
    );
    return result ?? false;
  }

  @override
  State<SmsPermissionRationaleSheet> createState() =>
      _SmsPermissionRationaleSheetState();
}

class _SmsPermissionRationaleSheetState
    extends State<SmsPermissionRationaleSheet> {
  bool _isRequesting = false;

  Future<void> _handleAllow() async {
    setState(() => _isRequesting = true);
    try {
      final granted = await widget.smsService.requestPermission();
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Shield / Sparkle Icon Badge
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.manaPurple.withValues(alpha: 0.2),
                      AppColors.safeGreen.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.manaPurple.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 34,
                  color: AppColors.manaPurple,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            const Text(
              'Automatic SMS Expense Tracking',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'SalaryQuest automatically captures bank debits and UPI AutoPay so your daily mana stays accurate without manual data entry.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),

            // 3 Privacy & Convenience Guarantees
            _buildGuaranteeTile(
              icon: Icons.phonelink_lock_rounded,
              iconColor: AppColors.safeGreen,
              title: '100% Offline & On-Device',
              description:
                  'Messages are parsed locally in phone memory. No SMS or financial numbers are ever uploaded.',
            ),
            const SizedBox(height: 10),
            _buildGuaranteeTile(
              icon: Icons.mark_email_read_outlined,
              iconColor: AppColors.xpBlue,
              title: 'Strict OTP & Personal Filter',
              description:
                  'Personal chats and sensitive login OTPs are immediately discarded and never stored.',
            ),
            const SizedBox(height: 10),
            _buildGuaranteeTile(
              icon: Icons.bolt_rounded,
              iconColor: AppColors.coinGold,
              title: 'Frictionless Ingestion',
              description:
                  'Transactions from Swiggy, Metro, UPI AutoPay, and Cards appear in seconds with +15 XP bonus.',
            ),
            const SizedBox(height: 26),

            // Primary Action CTA
            ElevatedButton(
              key: const Key('btn_enable_sms_tracking'),
              onPressed: _isRequesting ? null : _handleAllow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.manaPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
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
                      'Enable Auto-Tracking',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(height: 10),

            // Secondary Skip Action
            TextButton(
              key: const Key('btn_skip_sms_tracking'),
              onPressed: () {
                widget.onDenied?.call();
              },
              child: const Text(
                'I\'ll Enter Expenses Manually',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuaranteeTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.surfaceBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
