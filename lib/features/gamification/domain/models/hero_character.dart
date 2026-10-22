enum HeroArchetype {
  knight, // Aero: Resilient, armor shines with savings
  dragon, // Fafnir: Treasure hoarder, breathes golden flames
  cyberCat, // Katsu: Neon agile hacker, purrs on zero-spend
}

enum HeroMood {
  ecstatic, // Spent < 50%
  healthy, // Spent < 80%
  cautious, // Spent 80-100%
  wounded, // Overspent
  critical, // HP <= 20
  fainted, // HP == 0
}

class HeroCharacter {
  final String name;
  final HeroArchetype archetype;
  final int level;
  final int currentXp;
  final int maxXp;
  final int currentHp;
  final int maxHp;
  final int coins;
  final int streakDays;
  final int previousStreakDays;
  final bool streakShieldAvailable;
  final String skin;
  final List<String> unlockedSkins;
  final String themeId;
  final List<String> unlockedThemes;

  const HeroCharacter({
    required this.name,
    this.archetype = HeroArchetype.knight,
    this.level = 1,
    this.currentXp = 0,
    this.maxXp = 100,
    this.currentHp = 100,
    this.maxHp = 100,
    this.coins = 50,
    this.streakDays = 1,
    this.previousStreakDays = 0,
    this.streakShieldAvailable = true,
    this.skin = 'default',
    this.unlockedSkins = const ['default'],
    this.themeId = 'mana_purple',
    this.unlockedThemes = const ['mana_purple'],
  });

  /// Hero faints when HP hits 0 due to disciplined budget depletion.
  bool get isFainted => currentHp <= 0;

  /// Whether the hero can afford a purchase in coins. Coins can never go negative.
  bool canAfford(int cost) => cost >= 0 && coins >= cost;

  /// Purchases a hero skin if affordable. Purchases are permanent.
  HeroCharacter purchaseSkin(String skinId, int cost) {
    if (!canAfford(cost) || unlockedSkins.contains(skinId)) {
      return this;
    }
    final updatedUnlocked = List<String>.from(unlockedSkins)..add(skinId);
    return copyWith(
      coins: coins - cost,
      skin: skinId,
      unlockedSkins: updatedUnlocked,
    );
  }

  /// Equips an already unlocked hero skin.
  HeroCharacter equipSkin(String skinId) {
    if (!unlockedSkins.contains(skinId)) return this;
    return copyWith(skin: skinId);
  }

  /// Purchases a UI theme if affordable. Purchases are permanent.
  HeroCharacter purchaseTheme(String newThemeId, int cost) {
    if (!canAfford(cost) || unlockedThemes.contains(newThemeId)) {
      return this;
    }
    final updatedUnlocked = List<String>.from(unlockedThemes)..add(newThemeId);
    return copyWith(
      coins: coins - cost,
      themeId: newThemeId,
      unlockedThemes: updatedUnlocked,
    );
  }

  /// Equips an already unlocked UI theme.
  HeroCharacter equipTheme(String newThemeId) {
    if (!unlockedThemes.contains(newThemeId)) return this;
    return copyWith(themeId: newThemeId);
  }

  /// Whether the user can repair a broken streak using coins / shield.
  bool get canRepairStreak =>
      streakDays == 0 &&
      previousStreakDays > 0 &&
      streakShieldAvailable &&
      coins >= 50;

  HeroMood get mood {
    if (isFainted) return HeroMood.fainted;
    if (currentHp <= 20) return HeroMood.critical;
    if (currentHp <= 50) return HeroMood.wounded;
    if (currentHp <= 75) return HeroMood.cautious;
    if (currentHp >= 95) return HeroMood.ecstatic;
    return HeroMood.healthy;
  }

  String get avatarEmoji {
    if (isFainted) return '💀💤';

    // Skin override if custom skin is active
    switch (skin) {
      case 'shadow_rogue':
        return '🥷⚔️';
      case 'cyber_mage':
        return '🧙‍♂️⚡';
      case 'solar_paladin':
        return '⚔️☀️';
    }

    switch (archetype) {
      case HeroArchetype.knight:
        if (currentHp <= 30) return '🛡️💥';
        if (currentHp >= 80) return '⚔️✨';
        return '🛡️';
      case HeroArchetype.dragon:
        if (currentHp <= 30) return '🦎💨';
        if (currentHp >= 80) return '🐲🔥';
        return '🐉';
      case HeroArchetype.cyberCat:
        if (currentHp <= 30) return '😿⚡';
        if (currentHp >= 80) return '😸✨';
        return '🐱';
    }
  }

  String get moodMessage {
    switch (mood) {
      case HeroMood.fainted:
        return 'Hero has fainted from severe overspending! Log under-budget days or zero-spend days to revive.';
      case HeroMood.ecstatic:
        return 'Treasury is overflowing! We are invincible today!';
      case HeroMood.healthy:
        return 'Pacing is steady, Commander. Keep marching!';
      case HeroMood.cautious:
        return 'Mana pool running low. Tread carefully before dusk.';
      case HeroMood.wounded:
        return 'Ouch! Overspending took a chunk of my armor!';
      case HeroMood.critical:
        return 'Critical damage! We need an urgent No-Spend day!';
    }
  }

  HeroCharacter copyWith({
    String? name,
    HeroArchetype? archetype,
    int? level,
    int? currentXp,
    int? maxXp,
    int? currentHp,
    int? maxHp,
    int? coins,
    int? streakDays,
    int? previousStreakDays,
    bool? streakShieldAvailable,
    String? skin,
    List<String>? unlockedSkins,
    String? themeId,
    List<String>? unlockedThemes,
  }) {
    return HeroCharacter(
      name: name ?? this.name,
      archetype: archetype ?? this.archetype,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      maxXp: maxXp ?? this.maxXp,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
      previousStreakDays: previousStreakDays ?? this.previousStreakDays,
      streakShieldAvailable:
          streakShieldAvailable ?? this.streakShieldAvailable,
      skin: skin ?? this.skin,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      themeId: themeId ?? this.themeId,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'archetype': archetype.name,
      'level': level,
      'currentXp': currentXp,
      'maxXp': maxXp,
      'currentHp': currentHp,
      'maxHp': maxHp,
      'coins': coins,
      'streakDays': streakDays,
      'previousStreakDays': previousStreakDays,
      'streakShieldAvailable': streakShieldAvailable,
      'skin': skin,
      'unlockedSkins': unlockedSkins,
      'themeId': themeId,
      'unlockedThemes': unlockedThemes,
    };
  }

  factory HeroCharacter.fromJson(Map<String, dynamic> json) {
    return HeroCharacter(
      name: json['name'] as String? ?? 'Aero',
      archetype: HeroArchetype.values.firstWhere(
        (a) => a.name == json['archetype'],
        orElse: () => HeroArchetype.knight,
      ),
      level: json['level'] as int? ?? 1,
      currentXp: json['currentXp'] as int? ?? 0,
      maxXp: json['maxXp'] as int? ?? 100,
      currentHp: json['currentHp'] as int? ?? 100,
      maxHp: json['maxHp'] as int? ?? 100,
      coins: json['coins'] as int? ?? 50,
      streakDays: json['streakDays'] as int? ?? 1,
      previousStreakDays: json['previousStreakDays'] as int? ?? 0,
      streakShieldAvailable: json['streakShieldAvailable'] as bool? ?? true,
      skin: json['skin'] as String? ?? 'default',
      unlockedSkins: (json['unlockedSkins'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['default'],
      themeId: json['themeId'] as String? ?? 'mana_purple',
      unlockedThemes: (json['unlockedThemes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['mana_purple'],
    );
  }
}
