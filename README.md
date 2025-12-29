# CINE.PROTOCOL

A production-ready Flutter movie picker application demonstrating modern architecture best practices.

## Features

- **Clean Architecture**: Data → Domain → UI layers with repository pattern
- **State Management**: Riverpod 3.0 with code generation
- **Immutability**: Freezed for type-safe models
- **Persistence**: SharedPreferences with robust error handling
- **Analytics**: Firebase Analytics integration
- **Haptics**: Full haptic feedback system
- **Testing**: Unit & widget tests included
- **Material 3**: Modern theming with neon aesthetic

## Quick Start

```bash
# 1. Clone and enter directory
cd movie_picker

# 2. Install dependencies
flutter pub get

# 3. Run code generation
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run

# 5. Run tests
flutter test

# 6. Build release
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## Architecture

```
lib/
├── core/           # Cross-cutting concerns
│   ├── di/         # Dependency injection
│   ├── logging/    # App logging
│   ├── services/   # External services
│   └── theme/      # App theming
├── domain/         # Business logic
│   └── models/     # Data models
├── data/           # Data layer
│   └── repositories/ # Data repositories
└── ui/             # Presentation layer
    ├── screens/    # UI screens
    ├── view_models/ # State management
    └── widgets/    # Reusable widgets
```

## Performance

- Weighted random selection algorithm
- Efficient rebuilds with Riverpod
- Optimized animations with flutter_animate
- Memory management with AutoDispose
