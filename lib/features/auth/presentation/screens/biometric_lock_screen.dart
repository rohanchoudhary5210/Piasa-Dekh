import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/local_security_service.dart';

class BiometricLockScreen extends StatefulWidget {
  final BiometricAuthService authService;
  final LocalSecurityService? securityService;
  final VoidCallback onUnlocked;
  final bool autoTrigger;

  const BiometricLockScreen({
    super.key,
    required this.authService,
    this.securityService,
    required this.onUnlocked,
    this.autoTrigger = true,
  });

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-prompt biometric prompt on initial presentation if enabled
    if (widget.autoTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerAuth();
      });
    }
  }

  Future<void> _triggerAuth() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final success = await widget.authService.authenticate();

    if (mounted) {
      setState(() => _isAuthenticating = false);
      if (success) {
        widget.onUnlocked();
      } else {
        setState(() {
          _errorMessage =
              'Authentication cancelled or failed. Tap below to unlock with Biometrics or PIN.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.manaPurple, AppColors.manaPurpleDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.manaPurple.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fingerprint_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'SalaryQuest Vault Locked',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Your financial data and budgets are protected by biometric encryption.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.dangerRed,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : _triggerAuth,
                    icon: _isAuthenticating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock_open_rounded, size: 20),
                    label: Text(
                      _isAuthenticating
                          ? 'Verifying...'
                          : 'Unlock with Biometrics',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.manaPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _showPinFallbackDialog,
                  icon: const Icon(Icons.pin_outlined, size: 18, color: AppColors.xpBlue),
                  label: const Text(
                    'Use Backup PIN',
                    style: TextStyle(
                      color: AppColors.xpBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPinFallbackDialog() {
    final pinController = TextEditingController();
    String? pinError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.manaPurple),
                SizedBox(width: 8),
                Text('Vault PIN Fallback',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your 4-digit backup vault PIN to unlock your financial data:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('input_backup_pin'),
                  controller: pinController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    errorText: pinError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                key: const Key('btn_submit_pin'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.manaPurple),
                onPressed: () async {
                  final entered = pinController.text.trim();
                  final sec = widget.securityService ?? LocalSecurityService();
                  final hasPin = await sec.hasCustomBackupPin();
                  final validPin = await sec.getBackupPin();
                  if (!mounted) return;
                  if (!hasPin) {
                    setDialogState(() {
                      pinError =
                          'No backup PIN set yet. Unlock with fingerprint or your phone lock, then set a PIN in Settings.';
                    });
                    return;
                  }
                  if (entered.length == 4 && entered == validPin) {
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    widget.onUnlocked();
                  } else {
                    setDialogState(() {
                      pinError = 'Incorrect PIN. Please try again.';
                    });
                  }
                },
                child: const Text('Unlock'),
              ),
            ],
          );
        },
      ),
    );
  }
}
