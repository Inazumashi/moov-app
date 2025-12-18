# Implementation Plan - Finalizing Moov App Features

This plan outlines the frontend steps to implement the final requested features for the Moov application.

## 1. Reservation Management (Driver Side)
- **Goal**: Allow drivers to manage passenger requests (confirm/chat).
- **Files**: 
    - `lib/core/service/reservation_service.dart`: Add `getReservationsForRide`, `confirmReservation`, `rejectReservation`.
    - `lib/core/providers/reservation_provider.dart`: Add logic to fetch and manage `ReservationModel` list.
    - `lib/features/ride/screens/driver_reservations_screen.dart` (NEW): Screen to list passengers.
    - `lib/features/ride/screens/ride_details_screen.dart`: Add button to open `DriverReservationsScreen`.

## 2. Notifications & Real-Time UI
- **Goal**: Display notifications for ride reservation updates.
- **Files**:
    - `lib/core/models/notification_model.dart` (NEW): Model for notifications.
    - `lib/core/service/notification_service.dart` (Update): Fetch notifications from backend.
    - `lib/features/notifications/screens/notifications_screen.dart` (NEW): UI with tabs "Activity" / "Messages".
    - `lib/features/home/screens/home_screen.dart`: Link notification icon to `NotificationsScreen`.

## 3. Premium Mode & Payment
- **Goal**: Integrate PayPal and restrict Eco Stats to Premium users.
- **Files**:
    - `lib/features/premium/screens/premium_screen.dart` (NEW): "Go Premium" landing page with PayPal button.
    - `lib/features/stats/screens/stats_dashboard_screen.dart`: Check `user.isPremium`. If false, show blur/lock and button to `PremiumScreen`.
    - `lib/core/providers/auth_provider.dart`: Ensure `isPremium` is updated after payment.

## 4. Internationalization (i18n)
- **Goal**: Support FR, EN, AR (RTL).
- **Files**:
    - `pubspec.yaml`: Add dependencies (already present).
    - `lib/l10n/app_fr.arb`, `app_en.arb`, `app_ar.arb` (NEW): Translation files.
    - `lib/main.dart`: Configure `localizationsDelegates` and `supportedLocales`.
    - `lib/features/settings/screens/settings_screen.dart`: Add language switcher.

## 5. Security & Auth
- **Goal**: Improve Auth flow.
- **Files**:
    - `lib/features/auth/screens/login_screen.dart`: Remove "Test API" banner. Add "Forgot Password" navigation.
    - `lib/features/auth/screens/forgot_password_screen.dart` (NEW): Email input -> OTP -> Reset.
    - `lib/features/auth/screens/signup_screen.dart`: Make phone number optional.

## 6. Suggestions
- **Goal**: Show personalized suggestions.
- **Files**:
    - `lib/features/home/widgets/suggestions_section.dart`: Update UI to show header "Suggérés pour vous".

---
**Execution Order**:
1. Reservation Management (Core feature).
2. Notifications UI.
3. Premium & Stats Lock.
4. Auth Corrections (Login/Signup/Forgot Password).
5. Suggestions.
6. i18n (Time permitting, or setup basic structure).
