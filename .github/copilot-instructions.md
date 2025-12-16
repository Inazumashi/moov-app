# AI Coding Agent Instructions for Moov App

**Project**: Flutter university carpooling application (Moov)  
**Architecture**: Provider pattern + Clean Architecture + REST API integration

---

## Core Architecture

### Provider-Based State Management
All data flows through Provider pattern (6 main providers):
- **AuthProvider** (`lib/core/providers/auth_provider.dart`): User auth state, login/register
- **RideProvider** (`lib/core/providers/ride_provider.dart`): Ride search/publish with Station IDs
- **StationProvider** (`lib/core/providers/station_provider.dart`): Autocomplete, favorites, nearby
- **ReservationProvider**: Booking state
- **LanguageProvider**: i18n (French/English/Arabic support via `l10n/app_*.arb`)
- **ThemeProvider**: Dark/light theme

**Important**: Always use `Provider.of<T>(context)` or `ref.watch()` - never bypass for direct API calls.

### API Service Layer
Single `ApiService` class (`lib/core/api/api_service.dart`):
- **Platform-aware base URLs**: Android uses `10.0.2.2:3000/api`, iOS/Web use `localhost:3000/api`
- **JWT token management**: Stored in `FlutterSecureStorage`, auto-added to `Authorization: Bearer` headers
- **Error handling**: 401 deletes token, 400 parses error messages, others rethrow
- **Protected endpoints**: Pass `isProtected: true` to include auth token

### Service Layer (Separation of Concerns)
- `lib/core/service/auth_service.dart`: Login/register/email verification
- `lib/core/service/ride_service.dart`: Ride search by station IDs, publish rides
- `lib/core/service/station_service.dart`: Autocomplete, nearby, popular, city-based queries
- **Pattern**: Service → ApiService → Backend, Provider wraps Service with state management

---

## Station Display Rules (CRITICAL)

**Stations must come ONLY from database, no manual additions**:
1. **Autocomplete** uses `stations/autocomplete?q={query}&limit=10` endpoint
2. **Do NOT add "URI(ensemble)" or merged station labels** - show `label` field from DB response
3. **Station model** (`lib/core/models/station_model.dart`):
   ```dart
   final String label;  // Exact display text from DB
   final int id;        // Database ID required for ride search
   final String type;   // 'university' | 'train_station' | 'bus_station' | 'landmark'
   final String city;
   ```
4. **In widgets**: Display `station.label` directly, never construct labels manually
5. **Prevent duplicates**: Backend returns unique stations; if seeing duplicates, check for ID mismatches in ride search

---

## Ride Search Workflow

**Critical fix applied**: Use Station IDs, not names
```dart
// ✅ CORRECT (RideProvider)
await _rideService.searchRides(
  departureId: selectedDeparture.id,     // Station DB ID
  arrivalId: selectedArrival.id,          // Station DB ID
  date: searchDate,
);

// ❌ WRONG: passing station names
```
- Endpoint: `GET /api/rides/search?departure_station_id={id}&arrival_station_id={id}&departure_date=YYYY-MM-DD`
- Response format: `{ "rides": [...] }` - map using `RideModel.fromJson()`
- **Parsing**: `departure_date` field as DateTime; handle missing dates gracefully with try-catch

---

## Key Development Patterns

### Routing
- Static routes in `AppRouter` class (`lib/core/navigateur/app_router.dart`)
- Add route names as constants: `static const String myRoute = '/path'`
- Routes auto-swap based on `AuthProvider.isAuthenticated` state in main widget

### Localization
- Edit `.arb` files in `lib/l10n/app_*.arb` (French/English/Arabic)
- Generated files auto-created; access via `AppLocalizations.of(context)?.keyName`
- **Build command**: `flutter pub run intl_utils:generate` (handled by `generate: true` in pubspec)

### Error Handling
- Catch exceptions in Provider methods, set `_error` string, notify listeners
- UI screens check `provider.isLoading` and `provider.error` to show spinners/snackbars
- **Never silently fail** - always expose errors to user via providers

### Safe Listener Notifications
```dart
// When Provider might be disposed:
void _safeNotifyListeners() {
  if (!_isDisposed) {
    notifyListeners();
  }
}

// For callbacks during build:
Future.microtask(() => notifyListeners());  // Defer to next frame
```

---

## Build & Run Commands

```bash
# Get dependencies
flutter pub get

# Code generation (localization, localizations delegates)
flutter pub run build_runner build

# Run debug
flutter run

# Format/analyze
dart format lib/
dart analyze lib/

# Test
flutter test

# Build release
flutter build apk    # Android
flutter build ios    # iOS
```

---

## Feature Structure

Each feature in `lib/features/{feature}/`:
- `screens/`: UI pages (e.g., `LoginScreen`)
- `widgets/`: Reusable components specific to feature
- Models defined in `lib/core/models/`
- Services in `lib/core/service/`, accessed via Providers

**Example**: Search feature uses `StationProvider` (autocomplete) → `RideProvider` (search) → displays results

---

## Integration Points & Dependencies

- **External APIs**: Backend at `http://localhost:3000/api` (dev) or production URL
- **Secure Storage**: JWT tokens stored via `flutter_secure_storage` plugin
- **HTTP Client**: `package:http` for all API calls
- **State**: `package:provider` v6.1.2 - use `MultiProvider` in main.dart
- **Localization**: `package:intl` v0.20.2

**Backend repo**: https://github.com/Inazumashi/moov-backend (separate)

---

## Common Gotchas

1. **Datetime parsing**: Backend sends `"2025-12-17 19:00"` format; always use `DateTime.parse()` with error handling
2. **Station merging**: If duplicates appear, check for multiple IDs with same name in autocomplete response
3. **Protected endpoints**: Add `isProtected: true` for auth routes; missing JWT = 401 error
4. **Theme/Language changes**: Access via `Provider.of<ThemeProvider>` with `listen: true` to rebuild widgets
5. **Android emulator**: Uses `10.0.2.2:3000` not `localhost` for backend access

---

## When Adding Features

1. Define model in `lib/core/models/`
2. Create Service in `lib/core/service/` → call ApiService
3. Create Provider wrapping Service → handle state + errors
4. Create feature screens/widgets in `lib/features/{name}/`
5. Add routes to `AppRouter`
6. Add translations to `.arb` files if needed

Always prioritize **database sources** (stations, rides) over local additions. Validate IDs exist before API calls.
