import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/widgets/app_lock_gate.dart';
import 'features/home/presentation/providers/salary_quest_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SalaryQuestApp(),
    ),
  );
}

class SalaryQuestApp extends ConsumerWidget {
  const SalaryQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salaryQuestProvider);

    Widget home;
    if (state.isLoading) {
      home = const _StartupSplash();
    } else if (state.loadError != null) {
      home = _StartupError(message: state.loadError!);
    } else if (state.isOnboarded) {
      home = const HomeScreen();
    } else {
      home = const OnboardingScreen();
    }

    return MaterialApp(
      title: 'SalaryQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.forTheme(state.hero.themeId),
      locale: Locale(state.languageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          AppLockGate(child: child ?? const SizedBox.shrink()),
      home: home,
    );
  }
}

/// Shown for the fraction of a second while saved data loads,
/// so the user never sees placeholder numbers.
class _StartupSplash extends StatelessWidget {
  const _StartupSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚔️', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              'SALARYQUEST',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when saved data cannot be read. Never falls back to demo data.
class _StartupError extends ConsumerWidget {
  final String message;

  const _StartupError({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.dangerRed, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Could not load your data',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(salaryQuestProvider.notifier).retryLoad(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
