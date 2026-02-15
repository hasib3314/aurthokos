# অর্থকোষ (Arthokosh) - Personal Finance Manager

A premium personal finance management app built with Flutter featuring a stunning glassmorphism UI design.

---

## Architecture

**Pattern:** MVVM (Model-View-ViewModel) with Clean Architecture principles

```
lib/
├── main.dart                          # App entry point
├── core/                              # Core utilities & shared code
│   ├── constants/
│   │   ├── app_colors.dart            # Deep Emerald & Soft Gold palette
│   │   └── app_strings.dart           # All strings (English + Bengali)
│   ├── theme/
│   │   └── app_theme.dart             # Dark theme with Google Fonts
│   ├── utils/
│   │   ├── currency_converter.dart    # BDT/USD conversion & formatting
│   │   └── extensions.dart            # DateTime & BuildContext helpers
│   └── widgets/
│       └── glassmorphic_card.dart      # Reusable glassmorphism components
├── data/                              # Data layer
│   ├── database/
│   │   └── app_database.dart          # SQLite database (sqflite)
│   ├── models/
│   │   └── transaction_model.dart     # Unified transaction model
│   └── repositories/
│       └── finance_repository.dart    # Data access abstraction
├── presentation/                      # UI layer
│   ├── dashboard/
│   │   ├── dashboard_screen.dart      # Main dashboard with glassmorphism
│   │   └── dashboard_viewmodel.dart   # Dashboard state management
│   ├── add_transaction/
│   │   ├── add_transaction_screen.dart
│   │   └── add_transaction_viewmodel.dart
│   ├── common/
│   │   └── transaction_list_screen.dart  # Reusable list screen
│   ├── earn/
│   │   └── earn_screen.dart
│   ├── expense/
│   │   └── expense_screen.dart
│   ├── loan/
│   │   └── loan_screen.dart
│   ├── savings/
│   │   └── savings_screen.dart
│   └── settings/
│       └── settings_screen.dart       # Currency, threshold, notifications
└── services/
    ├── notification_service.dart      # Local push notifications
    └── balance_warning_service.dart   # Low balance detection & alerting
```

---

## Database Schema

### `transactions` table

| Column      | Type    | Description                              |
|-------------|---------|------------------------------------------|
| id          | TEXT PK | UUID primary key                         |
| title       | TEXT    | Transaction title                        |
| amount      | REAL    | Amount value                             |
| currency    | INTEGER | 0 = BDT, 1 = USD                        |
| type        | INTEGER | 0 = Earn, 1 = Expense, 2 = Loan, 3 = Savings |
| category    | TEXT    | User-defined category                    |
| date        | INTEGER | Timestamp (milliseconds since epoch)     |
| note        | TEXT    | Optional note                            |
| loanType    | INTEGER | 0 = Given, 1 = Taken (Loan only)        |
| personName  | TEXT    | Borrower/lender name (Loan only)         |
| dueDate     | INTEGER | Loan due date (Loan only)                |
| isPaid      | INTEGER | 0/1 boolean (Loan only)                  |
| goalAmount  | REAL    | Savings goal amount (Savings only)       |
| targetDate  | INTEGER | Savings target date (Savings only)       |

### `user_settings` table

| Column               | Type    | Default | Description                    |
|----------------------|---------|---------|--------------------------------|
| id                   | INTEGER | 1       | Always 1 (single row)          |
| defaultCurrency      | INTEGER | 0       | 0 = BDT, 1 = USD              |
| lowBalanceThreshold  | REAL    | 1000.0  | Warning threshold amount       |
| enableNotifications  | INTEGER | 1       | 0 = off, 1 = on               |

---

## Multi-Currency Handling

- **Supported currencies:** BDT (৳) and USD ($)
- **Conversion rates:** Configurable in `CurrencyConverter` class (default: 1 USD = 110 BDT)
- **Per-transaction currency:** Each transaction stores its own currency
- **Dashboard aggregation:** All amounts converted to selected display currency
- **Format support:** Full format (`৳1,234.56`) and compact (`৳1.2K`, `৳12.3L`, `৳1.5Cr`)

---

## Features

### Core
- **Earn tracking:** Income from salary, freelance, business, etc.
- **Expense tracking:** Daily expenses across categories
- **Loan management:** Track money given/taken with person name & due dates
- **Savings goals:** Set goal amounts and target dates

### Dashboard
- Total balance card with emerald gradient and glassmorphism
- 2x2 category grid (Earn, Expense, Loan, Savings)
- Recent transactions list with swipe-to-delete
- Currency toggle (BDT/USD) with live conversion
- Low balance warning indicator

### Low Balance Warning
- User-configurable threshold amount
- Automatic check after every expense/loan entry
- Local push notification when balance drops below threshold
- Visual warning on dashboard balance card

### UI/UX
- **Glassmorphism design:** Frosted glass cards with backdrop blur
- **Color palette:** Deep Emerald (#064E3B - #10B981) + Soft Gold (#D4AF37 - #FCD34D)
- **Typography:** Google Fonts (Poppins)
- **Animations:** Fade-in transitions, animated containers
- **Dark theme:** Full dark mode with emerald accents

---

## Dependencies

| Package                        | Purpose                          |
|-------------------------------|----------------------------------|
| provider                      | State management (MVVM)          |
| sqflite                       | SQLite database                  |
| path                          | Database file path resolution    |
| flutter_local_notifications   | Push notifications               |
| intl                          | Date/number formatting           |
| uuid                          | Unique ID generation             |
| google_fonts                  | Premium typography (Poppins)     |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on Android
flutter run

# Build APK
flutter build apk --release
```

---

## Balance Calculation

```
Balance = (Total Earn + Total Savings) - (Total Expense + Total Loan)
```

When displaying on dashboard, all amounts are converted to the user's selected display currency using the configured exchange rate.

---

## Future Enhancements (Planned)

1. **MFS Integration** - bKash/Nagad transaction import via SMS parsing
2. **Zakat Calculator** - Auto-calculate Zakat based on savings (2.5% of eligible wealth)
3. **Offline-First** - Already works offline with SQLite; sync layer can be added
4. **Export/Import** - CSV/PDF export of transaction history
5. **Charts & Analytics** - Monthly/yearly spending trends with pie/bar charts
