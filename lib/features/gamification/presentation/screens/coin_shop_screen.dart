import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';

class CoinShopScreen extends ConsumerWidget {
  const CoinShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salaryQuestProvider);
    final hero = state.hero;

    final skins = [
      {
        'id': 'default',
        'name': 'Knight Aero',
        'icon': '🛡️',
        'cost': 0,
        'desc': 'Default stalwart knight with disciplined armor.',
      },
      {
        'id': 'shadow_rogue',
        'name': 'Shadow Rogue',
        'icon': '🥷',
        'cost': 150,
        'desc': 'Swift shadow assassin who sneaks past frivolous expenses.',
      },
      {
        'id': 'cyber_mage',
        'name': 'Cyber Mage',
        'icon': '🧙‍♂️',
        'cost': 250,
        'desc': 'Harnesses neon mana spells to freeze impulse spending.',
      },
      {
        'id': 'solar_paladin',
        'name': 'Solar Paladin',
        'icon': '☀️',
        'cost': 400,
        'desc': 'Radiant champion armored with golden compounding wealth.',
      },
    ];

    final themes = [
      {
        'id': 'mana_purple',
        'name': 'Mana Purple',
        'icon': '🔮',
        'cost': 0,
        'desc': 'Classic SalaryQuest mystic deep purple theme.',
      },
      {
        'id': 'emerald_grove',
        'name': 'Emerald Grove',
        'icon': '🌲',
        'cost': 200,
        'desc': 'Lush neon green & deep forest nature palette.',
      },
      {
        'id': 'cyberpunk_neon',
        'name': 'Cyberpunk Neon',
        'icon': '⚡',
        'cost': 300,
        'desc': 'High-contrast electric cyan and magenta cyberpunk aesthetic.',
      },
      {
        'id': 'obsidian_gold',
        'name': 'Obsidian Gold',
        'icon': '👑',
        'cost': 500,
        'desc': 'Ultra-luxury deep obsidian black and shimmering 24k gold.',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          '🪙 Coin Shop & Hero Vault',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF332712), Color(0xFF1F1A12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.coinGold.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.coinGold.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🪙', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR COIN TREASURE',
                          style: TextStyle(
                            color: AppColors.coinGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${hero.coins} Coins',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Earn coins by staying under daily budget and defeating bosses.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hero Skins Section
            const Text(
              'Hero Skins',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Transform your budget hero avatar. Purchases are permanent.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),

            ...skins.map((skin) {
              final id = skin['id'] as String;
              final isUnlocked = hero.unlockedSkins.contains(id);
              final isEquipped = hero.skin == id;
              final cost = skin['cost'] as int;
              final canAfford = hero.canAfford(cost);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isEquipped
                        ? AppColors.manaPurple
                        : isUnlocked
                            ? AppColors.surfaceBorder
                            : AppColors.surfaceBorder.withValues(alpha: 0.6),
                    width: isEquipped ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        skin['icon'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                skin['name'] as String,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (isEquipped) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.manaPurple
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'EQUIPPED',
                                    style: TextStyle(
                                      color: AppColors.manaPurple,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            skin['desc'] as String,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isEquipped)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.safeGreen, size: 24)
                    else if (isUnlocked)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(salaryQuestProvider.notifier)
                              .equipHeroSkin(id);
                        },
                        child: const Text('Equip'),
                      )
                    else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford
                              ? AppColors.coinGold
                              : AppColors.surfaceElevated,
                          foregroundColor: canAfford
                              ? Colors.black
                              : AppColors.textMuted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: canAfford
                            ? () async {
                                final success = await ref
                                    .read(salaryQuestProvider.notifier)
                                    .purchaseHeroSkin(id, cost);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '🎉 Unlocked ${skin["name"]} skin!'),
                                      backgroundColor: AppColors.safeGreen,
                                    ),
                                  );
                                }
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Need ${cost - hero.coins} more coins to unlock ${skin["name"]}!'),
                                    backgroundColor: AppColors.dangerRed,
                                  ),
                                );
                              },
                        icon: const Text('🪙', style: TextStyle(fontSize: 12)),
                        label: Text('$cost'),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // UI Themes Section
            const Text(
              'App Themes',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Customize the look and feel of SalaryQuest dashboard.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),

            ...themes.map((theme) {
              final id = theme['id'] as String;
              final isUnlocked = hero.unlockedThemes.contains(id);
              final isEquipped = hero.themeId == id;
              final cost = theme['cost'] as int;
              final canAfford = hero.canAfford(cost);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isEquipped
                        ? AppColors.manaPurple
                        : AppColors.surfaceBorder,
                    width: isEquipped ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        theme['icon'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                theme['name'] as String,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (isEquipped) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.manaPurple
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: AppColors.manaPurple,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            theme['desc'] as String,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isEquipped)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.safeGreen, size: 24)
                    else if (isUnlocked)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(salaryQuestProvider.notifier)
                              .equipTheme(id);
                        },
                        child: const Text('Apply'),
                      )
                    else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford
                              ? AppColors.coinGold
                              : AppColors.surfaceElevated,
                          foregroundColor: canAfford
                              ? Colors.black
                              : AppColors.textMuted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: canAfford
                            ? () async {
                                final success = await ref
                                    .read(salaryQuestProvider.notifier)
                                    .purchaseTheme(id, cost);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '🎉 Unlocked ${theme["name"]} theme!'),
                                      backgroundColor: AppColors.safeGreen,
                                    ),
                                  );
                                }
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Need ${cost - hero.coins} more coins to unlock ${theme["name"]}!'),
                                    backgroundColor: AppColors.dangerRed,
                                  ),
                                );
                              },
                        icon: const Text('🪙', style: TextStyle(fontSize: 12)),
                        label: Text('$cost'),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
