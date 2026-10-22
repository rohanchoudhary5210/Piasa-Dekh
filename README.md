# ⚔️ SalaryQuest (Piasa Dekh)
*Gamified Personal Finance & Daily Budget Engine in Flutter*

SalaryQuest breaks down your monthly in-hand salary into **daily budgets (Daily Mana)** based on your actual cycle length (28 to 31 days). Every payment reduces that day's budget. Overspending borrows gently from future days via dynamic smoothing; underspending feeds your savings vault and powers up your companion hero to defeat the monthly Boss.

---

## 🚀 Quick Start

### 1. Prerequisites
- Flutter SDK (>= 3.0.0)
- Android Studio / VS Code with Dart & Flutter extensions

### 2. Run the App
```bash
# Get dependencies
flutter pub get

# Run on emulator or connected device
flutter run

# Run unit and integration tests verifying budget rollover and gamification formulas
flutter test
```

---

## 📌 Mid-Cycle Edit Policy (Documented Rule)

When a user edits their **Salary**, **Fixed Expenses**, or **Savings Goal** mid-cycle:
1. **Historical Immutability**: All past days ($1 \dots t-1$) are permanently frozen. Their historical allocated budgets and recorded expenditures remain unchanged as financial facts.
2. **Dynamic Remaining Pool**: The new discretionary pool $D_{\text{new}} = \text{Salary}_{\text{new}} - \text{Fixed}_{\text{new}} - \text{Savings}_{\text{new}}$ is calculated.
3. **Smooth Future Reallocation**: The remaining funds after subtracting past spending:
   $$R_{\text{future}} = D_{\text{new}} - \sum_{k=1}^{t-1} \text{Spent}_k$$
   are distributed evenly across all remaining days ($t \dots N$) using exact integer paise distribution (`Money.distribute`).
4. **Deficit Protection**: If the new obligations exceed the remaining funds ($R_{\text{future}} \le 0$), future days receive ₹0 and the uncovered deficit is tracked as `cycleDebt`, never producing a silent negative budget.

---

## 🕒 Midnight & Clock Integrity

1. **Midnight Handling**: A payment at `23:59:59` lands on today's calendar budget; a payment at `00:00:01` lands on tomorrow's calendar budget, strictly calculated in the device's local timezone.
2. **Anti-Clock Manipulation**: If the device clock is shifted backwards relative to the last recorded timestamp, the system flags a time distortion and suppresses XP and Coin rewards to prevent backdated gaming.

---

## 📁 Project Architecture

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # RPG Cyberpunk/FinTech color palette
│   │   └── app_theme.dart             # Dark theme configuration
│   ├── database/
│   │   ├── app_database.dart          # Drift SQLite schema & migrations
│   │   └── salary_quest_repository.dart # Transactional atomic persistence
│   ├── models/
│   │   └── money.dart                 # Integer paise value class & zero-drift distribution
│   ├── services/
│   │   └── clock_integrity_service.dart # Device clock rollback anti-cheat
│   └── utils/
│       └── currency_formatter.dart    # Indian Rupee (₹) formatting & compact notation
├── features/
│   ├── budget/
│   │   └── domain/
│   │       ├── models/
│   │       │   ├── budget_cycle.dart  # Dynamic payday anchoring & validations
│   │       │   └── daily_budget.dart  # Daily allocation, actual spent, surplus/deficit
│   │       └── services/
│   │           ├── budget_calculator.dart
│   │           ├── cycle_date_calculator.dart # Custom payday anchoring & late salary
│   │           ├── cycle_manager_service.dart # Mid-cycle edits, extra income, catch-up
│   │           └── rollover_strategy.dart     # Dynamic smoothing with last-day guard
│   ├── settings/
│   │   └── presentation/screens/
│   │       └── settings_screen.dart   # Treasury setup, payday, bonus income, late salary
│   └── home/
│       └── presentation/
│           ├── providers/
│           │   └── salary_quest_provider.dart # Reactive Riverpod state orchestrator
│           └── screens/
│               └── home_screen.dart          # Unified dashboard with monthly boss battle
└── main.dart
```

---

## 🛡️ Security, Privacy & Reliability

1. **Local Encryption at Rest**: Sensitive data is encrypted with AES-256 CBC using master keys held in `FlutterSecureStorage`.
2. **Biometric Vault Lock**: Supports Fingerprint / Face ID authentication with device PIN/passcode fallback (`biometricOnly: false`) so users can never be permanently locked out.
3. **Data Hygiene & Privacy**:
   - `Wipe All Data` performs an atomic cascade delete across all tables, returning the device to a clean initial state.
   - Raw SMS text is parsed on-device only and never uploaded or stored permanently.
4. **OEM Background Killer Resilience**: Detects background silence > 72 hours and provides manufacturer-tailored whitelisting instructions for Xiaomi (MIUI), Samsung (OneUI), Oppo/OnePlus (ColorOS), and Vivo (Funtouch).
5. **Data Conflict Resolution**: When restoring from backups or syncing devices, `DataConflictResolver` applies identity-based Latest-Edit-Wins merge with zero duplicates.

---

## 🧮 Mathematical Budget Formulas

### Discretionary Spending Pool
$$D_{\text{pool}} = S_{\text{salary}} - F_{\text{fixed}} - G_{\text{savings}}$$

### Dynamic Smoothing Formula (Overspent / Underspent Days)
When an expense is logged on day $t \in [1..N]$:
$$R_t = D_{\text{pool}} - \sum_{k=1}^{t} E_k$$
$$B_{t+1 \dots N} = \max\left(0, \frac{R_t}{N - t}\right)$$
*(Strictly guarded against $N - t = 0$ on day $N$)*.
