// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Moov';

  @override
  String get btnDiscoverPremium => 'Discover Premium';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnSendReview => 'Send Review';

  @override
  String get btnConnect => 'Log in';

  @override
  String get btnStart => 'Get Started';

  @override
  String get btnRegister => 'Create an Account';

  @override
  String get btnContinue => 'Continue';

  @override
  String get btnSaveModifications => 'Save Changes';

  @override
  String get btnLogout => 'Log Out';

  @override
  String get btnAddNewNumber => 'Add a Number';

  @override
  String get btnReceiveCode => 'Receive Verification Code';

  @override
  String get btnVerifyLater => 'Verify Later';

  @override
  String get pageTitleHome => 'Hello';

  @override
  String get pageTitleProfile => 'My Profile';

  @override
  String get pageTitleSettings => 'Settings';

  @override
  String get pageTitleSecurity => 'Security';

  @override
  String get pageTitleNotifications => 'Notifications';

  @override
  String get pageTitlePremium => 'Premium';

  @override
  String get pageTitleFaq => 'FAQ (Frequently Asked Questions)';

  @override
  String get pageTitleContact => 'Contact Us';

  @override
  String get pageTitleTerms => 'Terms of Use';

  @override
  String get pageTitlePrivacy => 'Privacy Policy';

  @override
  String get pageTitleLanguage => 'Language';

  @override
  String get pageTitlePaymentMethods => 'Payment Methods';

  @override
  String get titleOnboardingWelcome => 'Ridesharing between students and university staff';

  @override
  String get subtitleOnboardingWelcome => 'Share your trips safely within your university community';

  @override
  String get titleOnboardingRoutes => 'Configure your usual routes';

  @override
  String get subtitleOnboardingRoutes => 'Step 1/4 - We will suggest matching trips...';

  @override
  String get titleOnboardingUniversity => 'Select your university';

  @override
  String get subtitleOnboardingUniversity => 'Join your university community';

  @override
  String get titleOnboardingProfileType => 'Your profile';

  @override
  String get subtitleOnboardingProfileType => 'Select your profile type';

  @override
  String get titleOnboardingCreateAccount => 'Create an Account';

  @override
  String get subtitleOnboardingCreateAccount => 'Join Moov';

  @override
  String get titleOnboardingVerifyPhone => 'Phone Verification';

  @override
  String get subtitleOnboardingVerifyPhone => 'Step 4/4 - Secure your account';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionSecurity => 'Security';

  @override
  String get passwordManagement => 'Password Management';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionLegal => 'Legal';

  @override
  String get menuEditProfile => 'Edit Profile';

  @override
  String get menuPaymentMethods => 'Payment Methods';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuDarkMode => 'Dark Mode';

  @override
  String get menuChangePassword => 'Change Password';

  @override
  String get menuTwoFactorAuth => 'Two-Factor Authentication';

  @override
  String get menuIDVerification => 'ID Verification';

  @override
  String get menuEmailNotifications => 'Email Notifications';

  @override
  String get menuPushNotifications => 'Push Notifications';

  @override
  String get menuFaq => 'FAQ (Frequently Asked Questions)';

  @override
  String get menuContactUs => 'Contact Us';

  @override
  String get menuTermsOfService => 'Terms of Use';

  @override
  String get menuPrivacyPolicy => 'Privacy Policy';

  @override
  String get hintFullName => 'Full Name';

  @override
  String get hintEmail => 'University Email';

  @override
  String get hintPassword => 'Password';

  @override
  String get hintConfirmPassword => 'Confirm Password';

  @override
  String get hintCurrentPassword => 'Current Password';

  @override
  String get hintNewPassword => 'New Password';

  @override
  String get hintPhone => 'Phone';

  @override
  String get placeholderFrench => 'French';

  @override
  String get placeholderEnglish => 'English';

  @override
  String get placeholderArabic => 'Arabic';

  @override
  String get msgPrivacyInfo => 'This information allows us to create secure sub-communities.';

  @override
  String get msgAuthSecureInfo => 'Secure login with your verified university email.';

  @override
  String get msgPhoneInfo => 'Use an SMS code for added security.';

  @override
  String get msgEmailVerificationInfo => 'A verification email will be sent to your university address.';

  @override
  String get msgRidesToRate => 'Trips to Rate';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get changePassword => 'Change Password';

  @override
  String get help => 'Help';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Logout';

  @override
  String get communities => 'Communities';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get phoneAdditionOptional => 'Phone addition is optional';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String greetingWithName(Object name) {
    return 'Hello, $name 👋';
  }

  @override
  String get greeting => 'Hello 👋';

  @override
  String get student => 'Student';

  @override
  String get availableRidesMap => 'Map of available rides';

  @override
  String get rides => 'Rides';

  @override
  String get rating => 'Rating';

  @override
  String get madSaved => 'MAD Saved';

  @override
  String get myReservations => 'My reservations';

  @override
  String get myPublishedRides => 'My published rides';

  @override
  String get noPublishedRides => 'No rides published yet.';

  @override
  String get publish => 'Publish';

  @override
  String availableSeats(Object seats) {
    return '$seats seats';
  }

  @override
  String pricePerSeat(Object price) {
    return '$price DH';
  }

  @override
  String get markAsCompleted => 'Mark as completed';

  @override
  String get thankYouForReview => 'Thank you for your review!';

  @override
  String get alreadyRated => 'You have already rated this ride';

  @override
  String get rateDriver => 'Rate the driver';

  @override
  String get cancelReservation => 'Cancel reservation?';

  @override
  String get noKeep => 'No, keep';

  @override
  String get yesCancel => 'Yes, cancel';

  @override
  String get markAsCompletedQuestion => 'Mark as completed?';

  @override
  String get confirmRideCompleted => 'Do you confirm that the ride is completed?';

  @override
  String get no => 'No';

  @override
  String get yesComplete => 'Yes, complete';

  @override
  String get rideMarkedCompleted => 'Ride marked as completed';

  @override
  String get cannotMarkRide => 'Cannot mark the ride';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get addPaymentMethod => 'Please add a payment method in settings';

  @override
  String get paymentSuccessful => 'Payment successful! Welcome to Premium!';

  @override
  String paymentError(Object error) {
    return 'Payment error: $error';
  }

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String premiumExpiresIn(Object time) {
    return 'Your subscription expires in $time';
  }

  @override
  String get premium => 'Premium';

  @override
  String get fullExperience => 'Enjoy a full experience without interruption';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get freePrice => '0 MAD';

  @override
  String get pageTitleAddCreditCard => 'Add Credit Card';

  @override
  String get sectionCardInformation => 'Card Information';

  @override
  String get labelCardNumber => 'Card Number';

  @override
  String get hintCardNumber => '1234 5678 9012 3456';

  @override
  String get labelExpiry => 'Expiry Date';

  @override
  String get hintExpiry => 'MM/YY';

  @override
  String get labelCvv => 'CVV';

  @override
  String get hintCvv => '123';

  @override
  String get labelCardName => 'Name on Card';

  @override
  String get hintCardName => 'JOHN DOE';

  @override
  String get validationCardNumberRequired => 'Card number required';

  @override
  String get validationCardNumberInvalid => 'Invalid card number';

  @override
  String get validationExpiryRequired => 'Expiry date required';

  @override
  String get validationExpiryFormat => 'MM/YY format required';

  @override
  String get validationCvvRequired => 'CVV required';

  @override
  String get validationCvvInvalid => 'Invalid CVV';

  @override
  String get validationNameRequired => 'Name required';

  @override
  String get msgCardAddedSuccess => 'Card added successfully';

  @override
  String get msgSecurePayment => 'Your payment information is secure and encrypted according to PCI DSS standards.';

  @override
  String get btnAddCard => 'Add Card';
}
