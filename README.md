# bank_dump

A Flutter mobile banking client built against the Veegil banking API.

## Prerequisites

- Flutter SDK (stable channel)
- A configured Android/iOS toolchain (Android Studio / Xcode) or a running emulator/simulator/device

## Flavors

The app ships three flavors, each with its own entrypoint:

| Flavor    | Entrypoint              |
|-----------|--------------------------|
| dev       | `lib/main_dev.dart`      |
| staging   | `lib/main_staging.dart`  |
| prod      | `lib/main_prod.dart`     |

`lib/main.dart` is the default entrypoint and forwards to `main_prod.dart`.

## Running the app

A `Makefile` at the repo root wraps the flavor-specific `flutter run`/`flutter build` invocations. From the project root:

```sh
make run-dev      # flutter run --flavor dev -t lib/main_dev.dart
make run-staging  # flutter run --flavor staging -t lib/main_staging.dart
make run-prod     # flutter run --flavor prod -t lib/main_prod.dart
```

iOS-specific targets (`run-ios-dev`, `run-ios-staging`, `run-ios-prod`) are also available and currently equivalent to their non-iOS counterparts.

## Testing & analysis

```sh
make analyze   # flutter analyze
make test      # flutter test
```

## Building release artifacts

```sh
make apk-dev      # flutter build apk --release --flavor dev -t lib/main_dev.dart
make apk-staging  # flutter build apk --release --flavor staging -t lib/main_staging.dart
make apk-prod     # flutter build apk --release --flavor prod -t lib/main_prod.dart

make bundle-dev      # flutter build appbundle --release --flavor dev -t lib/main_dev.dart
make bundle-staging  # flutter build appbundle --release --flavor staging -t lib/main_staging.dart
make bundle-prod     # flutter build appbundle --release --flavor prod -t lib/main_prod.dart

make ios-dev      # flutter build ios --release --flavor dev -t lib/main_dev.dart --no-codesign
make ios-staging  # flutter build ios --release --flavor staging -t lib/main_staging.dart --no-codesign
make ios-prod     # flutter build ios --release --flavor prod -t lib/main_prod.dart --no-codesign
```

Built APKs land under `build/app/outputs/flutter-apk/`.

## Architecture

Clean Architecture, feature-based, under `lib/features/<feature>/{domain,data,presentation}`, with shared plumbing (networking, DI, routing, storage, theming) under `lib/core/`. State management is Riverpod only.

## API

Consumes the hosted banking API at `https://bankapi.veegil.com/api/v1` (OpenAPI spec at `https://bankapi.veegil.com/openapi.json`). See `API_RULES.md` for the integration rules.
