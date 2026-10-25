# Spendly – Personal Expense Tracker

Spendly is a Flutter application that helps users track expenses, manage budgets, and understand their spending through charts.

## Features

- Dashboard with monthly expenses, remaining budget, and recent transactions.
- Add, edit, and delete expenses.
- Search, filter, and sort transactions.
- View spending by category using charts.
- Manage monthly and category-wise budgets.
- Sample data for the initial app experience.
- Local data storage using Hive CE.
- Light and dark themes.

## Tech Stack

- Flutter and Dart
- Riverpod for state management
- Clean Architecture
- Hive CE for local storage
- `json_serializable` for serialization
- `go_router` for navigation
- `fl_chart` for charts
- `intl` for date formatting
- `flutter_screenutil` for responsive UI

## Architecture

The project follows Clean Architecture with three main layers:

- **Presentation:** Screens, widgets, and Riverpod providers.
- **Domain:** Entities, repository interfaces, and use cases.
- **Data:** Models, data sources, and repository implementations.

Shared services, routing, themes, and widgets are organized under `core/`.

## Getting Started

### Prerequisites

Install Flutter SDK, Android Studio or VS Code, and the Android SDK.

Check your Flutter setup:

```bash
flutter doctor
```

### Run the App

```bash
git clone <https://github.com/jincykp/Spendly.git>
cd spendly
flutter pub get
flutter run
```

If code generation is required:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Build APK

Generate a release APK:

```bash
flutter build apk --release
```

The APK will be available at:

`build/app/outputs/flutter-apk/app-release.apk`

## Testing

Run tests using:

```bash
flutter test
```

Check expense management, budget tracking, charts, mock data, and data persistence after restarting the app.

## Author

**Jincy K P**
Flutter Developer

---

Built with Flutter and Dart.
