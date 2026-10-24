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

## 🔄 Day & Payday Rollover (automatic)

Runs on app start, on resume, and just after midnight while the app is open (`runDailyMaintenance`):
1. **Each finished day** is evaluated once: streak (+1 if within budget, otherwise broken), hero HP (zero-spend +25, under 80% +15, within budget +5, overspend −15/−30), and that day's quests are auto-claimed if completed. A one-line summary is shown on the home screen.
2. **On payday** the finished cycle is closed and archived (visible in Insights → history), the boss result is paid out, the streak shield is refilled and a new cycle starts with the same salary setup.
3. **Auto-flow** (if enabled): money left over when the cycle ends moves into the primary savings goal.
4. Fresh daily quests every day.

## 📲 SMS Rules
- Debits → expense. Refund / cashback / reversal credits → refund (reduces spending).
- Salary credits and money received from people are **not** counted as spending.

## 🔔 Notifications
Two daily reminders are scheduled with the OS (work even when the app is closed): 8:30 PM "log today's spends" and 9:15 PM "any cash spends?". Both follow the Notification Settings screen and quiet hours.

## 💾 Backups
Backups are protected with a password you choose and can be restored on any phone (Settings → Export / Restore). Copy the backup text somewhere safe.

## 📦 Release Build (Play Store)
1. Create a keystore once:
   ```bash
   keytool -genkey -v -keystore %USERPROFILE%\salaryquest-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias salaryquest
   ```
2. Create `android/key.properties` (already git-ignored):
   ```
   storePassword=<your store password>
   keyPassword=<your key password>
   keyAlias=salaryquest
   storeFile=C:\\Users\\<you>\\salaryquest-release.jks
   ```
3. `flutter build appbundle --release`

Without `key.properties`, release builds fall back to the debug key (OK for testing, not for the Play Store).

**Play Store note:** the app uses `READ_SMS` / `RECEIVE_SMS`. Google Play only allows these after you submit the *Permissions Declaration Form* in Play Console and explain the SMS-based expense tracking use case.

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
