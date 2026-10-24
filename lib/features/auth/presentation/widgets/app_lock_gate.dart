import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_quest/core/services/biometric_auth_service.dart';
import 'package:salary_quest/features/auth/presentation/screens/biometric_lock_screen.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';

/// Wraps the whole app (every route) and covers it with the biometric lock
/// screen whenever the vault is locked. Because it sits above the Navigator,
/// no pushed screen (Settings, Shop, Insights...) can be seen while locked.
///
/// The vault locks only when the app really goes to the background
/// (hidden / paused) — not when the notification shade is pulled down.
class AppLockGate extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onHide: _lockIfEnabled,
    );
  }

  void _lockIfEnabled() {
    final state = ref.read(salaryQuestProvider);
    if (state.isBiometricLockEnabled && state.isAuthenticated) {
      ref.read(salaryQuestProvider.notifier).setAuthenticated(false);
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(salaryQuestProvider.select(
      (s) => s.isOnboarded && s.isBiometricLockEnabled && !s.isAuthenticated,
    ));

    return Stack(
      children: [
        // Keep the app mounted underneath so navigation state survives unlocking,
        // but hide it from view and from accessibility while locked.
        Offstage(offstage: locked, child: widget.child),
        if (locked)
          Positioned.fill(
            // Own Navigator so the lock screen can open its PIN dialog.
            child: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => BiometricLockScreen(
                  authService: BiometricAuthService(),
                  onUnlocked: () {
                    ref.read(salaryQuestProvider.notifier).setAuthenticated(true);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
