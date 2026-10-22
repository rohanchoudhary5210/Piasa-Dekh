import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/notifications/domain/models/notification_alert.dart';
import 'package:salary_quest/features/notifications/domain/models/notification_preferences.dart';
import 'package:salary_quest/features/notifications/presentation/widgets/notification_permission_sheet.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  late NotificationPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = ref.read(salaryQuestProvider).notificationPreferences;
  }

  void _updatePreferences(NotificationPreferences newPrefs) {
    setState(() => _preferences = newPrefs);
    ref
        .read(salaryQuestProvider.notifier)
        .updateNotificationPreferences(newPrefs);
  }

  Future<void> _sendTestNotification() async {
    final now = DateTime.now();
    final testAlert = NotificationAlert(
      id: 9999,
      type: NotificationAlertType.budget80Used,
      title: '⚠️ Daily Budget Warning (Test)',
      bodyWithAmounts:
          'You have spent ₹800 of your ₹1,000 daily budget (80%+ consumed).',
      bodyMasked:
          'You have used over 80% of today\'s daily budget. Review discretionary spending.',
      timestamp: now,
    );

    final decision = await ref
        .read(salaryQuestProvider.notifier)
        .dispatchNotificationAlert(testAlert);

    if (!mounted) return;
    if (decision.shouldSend) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Notification sent: "${decision.body}"',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.safeGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification suppressed: ${decision.reason}'),
          backgroundColor: AppColors.warningAmber,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Smart Alerts & Quiet Hours',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Master switch tile
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: SwitchListTile(
              value: _preferences.enabled,
              activeTrackColor: AppColors.manaPurple,
              title: const Text(
                'Enable Smart Notifications',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: const Text(
                'Master switch for all budget, streak and milestone alerts',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              onChanged: (val) {
                if (val) {
                  NotificationPermissionSheet.show(
                    context,
                    notificationManager: ref
                        .read(salaryQuestProvider.notifier)
                        .notificationManager,
                  ).then((_) {
                    _updatePreferences(_preferences.copyWith(enabled: true));
                  });
                } else {
                  _updatePreferences(_preferences.copyWith(enabled: false));
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          if (_preferences.enabled) ...[
            // Rate Limit & Quiet Hours Card
            _buildSectionHeader('FREQUENCY & PRIVACY'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  // Max per day slider
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Max Alerts Per Day',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.manaPurple.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_preferences.maxPerDay} / day',
                                style: const TextStyle(
                                  color: AppColors.manaPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Slider(
                          value: _preferences.maxPerDay.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          activeColor: AppColors.manaPurple,
                          inactiveColor: AppColors.surfaceElevated,
                          label: '${_preferences.maxPerDay}',
                          onChanged: (val) {
                            _updatePreferences(
                              _preferences.copyWith(maxPerDay: val.toInt()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),

                  // Quiet hours selector
                  ListTile(
                    title: const Text(
                      'Quiet Hours',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${_formatHour(_preferences.quietHoursStartHour)} to ${_formatHour(_preferences.quietHoursEndHour)} (All alerts suppressed)',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.nightlight_round,
                        color: AppColors.textSecondary),
                    onTap: () => _pickQuietHours(context),
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),

                  // Lockscreen privacy toggle
                  SwitchListTile(
                    value: !_preferences.showAmountsOnLockScreen,
                    activeTrackColor: AppColors.safeGreen,
                    title: const Text(
                      'Lockscreen Financial Privacy',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Hides exact ₹ amounts on notification text when device is locked.',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    onChanged: (hideAmounts) {
                      _updatePreferences(
                        _preferences.copyWith(
                          showAmountsOnLockScreen: !hideAmounts,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Alert Toggles
            _buildSectionHeader('ALERT CATEGORIES'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _preferences.budget80AlertEnabled,
                    activeTrackColor: AppColors.manaPurple,
                    title: const Text(
                      '80% Daily Budget Warning',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Alerts you before exceeding your allocated daily pool.',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    onChanged: (val) {
                      _updatePreferences(
                        _preferences.copyWith(budget80AlertEnabled: val),
                      );
                    },
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  SwitchListTile(
                    value: _preferences.streakAtRiskAlertEnabled,
                    activeTrackColor: AppColors.manaPurple,
                    title: const Text(
                      'Streak Protection (Evening)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Reminds you at 7 PM if no spending has been logged today.',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    onChanged: (val) {
                      _updatePreferences(
                        _preferences.copyWith(streakAtRiskAlertEnabled: val),
                      );
                    },
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  SwitchListTile(
                    value: _preferences.cashReminderEnabled,
                    activeTrackColor: AppColors.manaPurple,
                    title: const Text(
                      'End-of-Day Cash Reminder',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Prompt to add offline cash purchases before midnight rollover.',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    onChanged: (val) {
                      _updatePreferences(
                        _preferences.copyWith(cashReminderEnabled: val),
                      );
                    },
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  SwitchListTile(
                    value: _preferences.goalMilestonesEnabled,
                    activeTrackColor: AppColors.manaPurple,
                    title: const Text(
                      'Savings Goal Milestones',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Celebratory alert upon reaching 50% and 100% of a goal.',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    onChanged: (val) {
                      _updatePreferences(
                        _preferences.copyWith(goalMilestonesEnabled: val),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Test Alert Button
            OutlinedButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.send_rounded,
                  size: 18, color: AppColors.xpBlue),
              label: const Text(
                'Send Test Notification Now',
                style: TextStyle(
                  color: AppColors.xpBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.xpBlue),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:00 $period';
  }

  Future<void> _pickQuietHours(BuildContext context) async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _preferences.quietHoursStartHour, minute: 0),
      helpText: 'Select Quiet Hours Start Time',
    );
    if (start == null || !mounted || !context.mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _preferences.quietHoursEndHour, minute: 0),
      helpText: 'Select Quiet Hours End Time',
    );
    if (end == null || !mounted) return;

    _updatePreferences(
      _preferences.copyWith(
        quietHoursStartHour: start.hour,
        quietHoursEndHour: end.hour,
      ),
    );
  }
}
