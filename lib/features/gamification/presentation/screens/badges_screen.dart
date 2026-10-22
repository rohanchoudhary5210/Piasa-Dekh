import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/features/gamification/domain/models/achievement.dart';
import 'package:salary_quest/features/gamification/domain/services/achievement_engine.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  void _showBadgeDetails(BuildContext context, Achievement badge, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppColors.coinGold.withValues(alpha: 0.2)
                    : AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? AppColors.coinGold : AppColors.surfaceBorder,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                isUnlocked ? badge.icon : '🔒',
                style: const TextStyle(fontSize: 34),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isUnlocked ? AppColors.safeGreen : AppColors.textMuted)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isUnlocked && badge.unlockedAt != null
                    ? '🏆 Unlocked on ${DateFormat('dd MMM yyyy').format(badge.unlockedAt!)}'
                    : '🔒 Locked • Complete the quest to claim',
                style: TextStyle(
                  color: isUnlocked ? AppColors.safeGreen : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salaryQuestProvider);
    const catalog = AchievementEngine.allCatalogBadges;

    // Map unlocked badges
    final Map<String, Achievement> unlockedMap = {};
    for (final a in state.achievements) {
      if (a.isUnlocked) {
        unlockedMap[a.id] = a;
      }
    }

    final unlockedCount = catalog.where((b) => unlockedMap.containsKey(b.id)).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          '🏅 Badges & Trophies',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hall of Fame Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C1E3C), Color(0xFF1E1430)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.manaPurple.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.coinGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🏆', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HALL OF VALOR',
                          style: TextStyle(
                            color: AppColors.coinGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$unlockedCount of ${catalog.length} Badges Earned',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Badges are permanently preserved once unlocked.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Achievement Showcase',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: catalog.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final badge = catalog[index];
                final isUnlocked = unlockedMap.containsKey(badge.id);
                final actualBadge = isUnlocked ? unlockedMap[badge.id]! : badge;

                return InkWell(
                  onTap: () => _showBadgeDetails(context, actualBadge, isUnlocked),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppColors.surface : AppColors.surfaceElevated.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isUnlocked
                            ? AppColors.coinGold.withValues(alpha: 0.6)
                            : AppColors.surfaceBorder,
                        width: isUnlocked ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? AppColors.coinGold.withValues(alpha: 0.15)
                                : AppColors.surfaceBorder.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isUnlocked ? badge.icon : '🔒',
                            style: TextStyle(
                              fontSize: 24,
                              color: isUnlocked ? null : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          badge.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isUnlocked
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge.description,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isUnlocked
                                ? AppColors.textSecondary
                                : AppColors.textMuted.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
