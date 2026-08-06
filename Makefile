.PHONY: run-dev run-staging run-prod run-ios-dev run-ios-staging run-ios-prod analyze test apk-dev apk-staging apk-prod bundle-dev bundle-staging bundle-prod ios-dev ios-staging ios-prod

run-dev:
	flutter run --flavor dev -t lib/main_dev.dart

run-staging:
	flutter run --flavor staging -t lib/main_staging.dart

run-prod:
	flutter run --flavor prod -t lib/main_prod.dart

run-ios-dev:
	flutter run --flavor dev -t lib/main_dev.dart

run-ios-staging:
	flutter run --flavor staging -t lib/main_staging.dart

run-ios-prod:
	flutter run --flavor prod -t lib/main_prod.dart

analyze:
	flutter analyze

test:
	flutter test

apk-dev:
	flutter build apk --release --flavor dev -t lib/main_dev.dart

apk-staging:
	flutter build apk --release --flavor staging -t lib/main_staging.dart

apk-prod:
	flutter build apk --release --flavor prod -t lib/main_prod.dart

bundle-dev:
	flutter build appbundle --release --flavor dev -t lib/main_dev.dart

bundle-staging:
	flutter build appbundle --release --flavor staging -t lib/main_staging.dart

bundle-prod:
	flutter build appbundle --release --flavor prod -t lib/main_prod.dart

ios-dev:
	flutter build ios --release --flavor dev -t lib/main_dev.dart --no-codesign

ios-staging:
	flutter build ios --release --flavor staging -t lib/main_staging.dart --no-codesign

ios-prod:
	flutter build ios --release --flavor prod -t lib/main_prod.dart --no-codesign
