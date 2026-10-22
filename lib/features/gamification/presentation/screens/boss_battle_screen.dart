import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';

class BossBattleScreen extends ConsumerStatefulWidget {
  const BossBattleScreen({super.key});

  @override
  ConsumerState<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends ConsumerState<BossBattleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleClaimRewards() async {
    setState(() => _isClaiming = true);
    try {
      final success = await ref
          .read(salaryQuestProvider.notifier)
          .claimBossBattleResult();
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Boss Defeated! +500 XP, +200 Coins & Titan Slayer badge claimed!',
            ),
            backgroundColor: AppColors.safeGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to claim rewards: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salaryQuestProvider);
    final isSeriousMode = state.isSeriousMode;

    if (isSeriousMode) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Monthly Savings Target'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.savings_outlined, size: 64, color: AppColors.manaPurple),
                const SizedBox(height: 16),
                const Text(
                  'Serious Mode Active',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'RPG Boss Battles are hidden in Serious Mode to provide a streamlined, professional financial overview.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.manaPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Return to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final maxHp = max(1, state.bossMaxHp);
    final currentHp = state.bossCurrentHp.clamp(0, maxHp);
    final hpRatio = (currentHp / maxHp).clamp(0.0, 1.0);
    final isDefeated = currentHp <= 0;
    final damageDealt = max(0, maxHp - currentHp);
    final daysRemaining = max(0, state.cycle.totalDays - state.currentDayIndex + 1);

    // Has user already unlocked the boss_defeated badge?
    final hasClaimedBadge = state.achievements.any(
      (a) => a.id == 'boss_defeated' && a.isUnlocked,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'Monthly Boss Raid',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Boss Avatar & Status Card
            _buildBossHeroCard(
              currentHp: currentHp,
              maxHp: maxHp,
              hpRatio: hpRatio,
              isDefeated: isDefeated,
            ),
            const SizedBox(height: 16),

            // Victory / Defeat Panel
            if (isDefeated)
              _buildVictoryBanner(hasClaimedBadge)
            else
              _buildBattleActiveBanner(daysRemaining, damageDealt, maxHp),
            const SizedBox(height: 16),

            // Battle Stats Grid
            _buildBattleMetrics(
              targetAmount: Money.fromRupees(maxHp),
              damageDealt: Money.fromRupees(damageDealt),
              daysRemaining: daysRemaining,
              currentHp: currentHp,
            ),
            const SizedBox(height: 20),

            // How the Raid Works Explainer
            _buildCombatRulesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBossHeroCard({
    required int currentHp,
    required int maxHp,
    required double hpRatio,
    required bool isDefeated,
  }) {
    Color hpBarColor = AppColors.dangerRed;
    if (hpRatio < 0.25) {
      hpBarColor = AppColors.safeGreen;
    } else if (hpRatio < 0.6) {
      hpBarColor = AppColors.warningAmber;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDefeated
              ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
              : [const Color(0xFF450A0A), const Color(0xFF1E1435)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDefeated
              ? AppColors.safeGreen.withValues(alpha: 0.5)
              : AppColors.dangerRed.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDefeated ? AppColors.safeGreen : AppColors.dangerRed)
                .withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Boss Sprite with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isDefeated ? 1.0 : _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDefeated
                        ? AppColors.safeGreen.withValues(alpha: 0.2)
                        : AppColors.dangerRed.withValues(alpha: 0.2),
                    border: Border.all(
                      color: isDefeated
                          ? AppColors.safeGreen
                          : AppColors.dangerRed,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isDefeated ? '💀' : '👹',
                      style: const TextStyle(fontSize: 54),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Boss Title
          Text(
            isDefeated ? 'INFLATION TITAN (DEFEATED)' : 'THE INFLATION TITAN',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Feeds on impulse purchases & lifestyle creep',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Boss HP Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BOSS HP: ₹$currentHp / ₹$maxHp',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(hpRatio * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: hpBarColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: hpRatio,
              minHeight: 14,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(hpBarColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryBanner(bool hasClaimedBadge) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.safeGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.safeGreen, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Text('🏆', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VICTORY ACHIEVED!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.safeGreen,
                      ),
                    ),
                    Text(
                      'You successfully saved your monthly target and felled the Titan!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD1FAE5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF047857)),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Text('⚡ ', style: TextStyle(fontSize: 16)),
                  Text(
                    '+500 XP',
                    style: TextStyle(
                      color: AppColors.xpBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('🪙 ', style: TextStyle(fontSize: 16)),
                  Text(
                    '+200 Coins',
                    style: TextStyle(
                      color: AppColors.coinGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('🎖️ ', style: TextStyle(fontSize: 16)),
                  Text(
                    'Titan Slayer',
                    style: TextStyle(
                      color: AppColors.manaPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasClaimedBadge)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isClaiming ? null : _handleClaimRewards,
                icon: _isClaiming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.card_giftcard),
                label: Text(
                  _isClaiming ? 'Claiming Loot...' : 'Claim Victory Rewards',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.safeGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          else
            const Text(
              '✓ Rewards already claimed for this battle!',
              style: TextStyle(
                color: AppColors.safeGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBattleActiveBanner(int daysRemaining, int damageDealt, int maxHp) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BATTLE IN PROGRESS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You have dealt ₹$damageDealt damage. Save ₹${max(0, maxHp - damageDealt)} more over the next $daysRemaining days to slay the Boss!',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleMetrics({
    required Money targetAmount,
    required Money damageDealt,
    required int daysRemaining,
    required int currentHp,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildMetricTile(
          icon: '🎯',
          label: 'Savings Target',
          value: CurrencyFormatter.formatMoney(targetAmount),
          color: AppColors.xpBlue,
        ),
        _buildMetricTile(
          icon: '💥',
          label: 'Damage Dealt',
          value: CurrencyFormatter.formatMoney(damageDealt),
          color: AppColors.safeGreen,
        ),
        _buildMetricTile(
          icon: '⏳',
          label: 'Days Remaining',
          value: '$daysRemaining days',
          color: AppColors.coinGold,
        ),
        _buildMetricTile(
          icon: '❤️',
          label: 'Boss HP Left',
          value: '₹$currentHp',
          color: AppColors.dangerRed,
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCombatRulesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.textMuted, size: 18),
              SizedBox(width: 8),
              Text(
                'RAID RULES & MECHANICS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRuleRow(
            icon: '🛡️',
            title: 'Boss HP is your Savings Target',
            subtitle: 'The Titan starts with HP equal to your monthly savings goal in rupees.',
          ),
          const SizedBox(height: 10),
          _buildRuleRow(
            icon: '⚔️',
            title: 'Underspending Deals Damage',
            subtitle: 'Every rupee you save below your daily budget directly strikes down Boss HP.',
          ),
          const SizedBox(height: 10),
          _buildRuleRow(
            icon: '🩸',
            title: 'Overspending Heals the Boss',
            subtitle: 'Exceeding your daily budget allows the Titan to feed and regenerate health.',
          ),
          const SizedBox(height: 10),
          _buildRuleRow(
            icon: '🎁',
            title: 'Victory Rewards at Cycle End',
            subtitle: 'Reach 0 HP by payday to claim +500 XP, +200 Coins, and the Titan Slayer badge!',
          ),
        ],
      ),
    );
  }

  Widget _buildRuleRow({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
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
