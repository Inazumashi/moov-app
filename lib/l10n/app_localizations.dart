import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Moov'**
  String get appName;

  /// No description provided for @btnDiscoverPremium.
  ///
  /// In en, this message translates to:
  /// **'Discover Premium'**
  String get btnDiscoverPremium;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnSendReview.
  ///
  /// In en, this message translates to:
  /// **'Send Review'**
  String get btnSendReview;

  /// No description provided for @btnConnect.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get btnConnect;

  /// No description provided for @btnStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get btnStart;

  /// No description provided for @btnRegister.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get btnRegister;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @btnSaveModifications.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get btnSaveModifications;

  /// No description provided for @btnLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get btnLogout;

  /// No description provided for @btnAddNewNumber.
  ///
  /// In en, this message translates to:
  /// **'Add a Number'**
  String get btnAddNewNumber;

  /// No description provided for @btnReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Receive Verification Code'**
  String get btnReceiveCode;

  /// No description provided for @btnVerifyLater.
  ///
  /// In en, this message translates to:
  /// **'Verify Later'**
  String get btnVerifyLater;

  /// No description provided for @pageTitleHome.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get pageTitleHome;

  /// No description provided for @pageTitleProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get pageTitleProfile;

  /// No description provided for @pageTitleSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get pageTitleSettings;

  /// No description provided for @pageTitleSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get pageTitleSecurity;

  /// No description provided for @pageTitleNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get pageTitleNotifications;

  /// No description provided for @pageTitlePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get pageTitlePremium;

  /// No description provided for @pageTitleFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ (Frequently Asked Questions)'**
  String get pageTitleFaq;

  /// No description provided for @pageTitleContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get pageTitleContact;

  /// No description provided for @pageTitleTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get pageTitleTerms;

  /// No description provided for @pageTitlePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get pageTitlePrivacy;

  /// No description provided for @pageTitleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get pageTitleLanguage;

  /// No description provided for @pageTitlePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get pageTitlePaymentMethods;

  /// No description provided for @titleOnboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Ridesharing between students and university staff'**
  String get titleOnboardingWelcome;

  /// No description provided for @subtitleOnboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Share your trips safely within your university community'**
  String get subtitleOnboardingWelcome;

  /// No description provided for @titleOnboardingRoutes.
  ///
  /// In en, this message translates to:
  /// **'Configure your usual routes'**
  String get titleOnboardingRoutes;

  /// No description provided for @subtitleOnboardingRoutes.
  ///
  /// In en, this message translates to:
  /// **'Step 1/4 - We will suggest matching trips...'**
  String get subtitleOnboardingRoutes;

  /// No description provided for @titleOnboardingUniversity.
  ///
  /// In en, this message translates to:
  /// **'Select your university'**
  String get titleOnboardingUniversity;

  /// No description provided for @subtitleOnboardingUniversity.
  ///
  /// In en, this message translates to:
  /// **'Join your university community'**
  String get subtitleOnboardingUniversity;

  /// No description provided for @titleOnboardingProfileType.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get titleOnboardingProfileType;

  /// No description provided for @subtitleOnboardingProfileType.
  ///
  /// In en, this message translates to:
  /// **'Select your profile type'**
  String get subtitleOnboardingProfileType;

  /// No description provided for @titleOnboardingCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get titleOnboardingCreateAccount;

  /// No description provided for @subtitleOnboardingCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Join Moov'**
  String get subtitleOnboardingCreateAccount;

  /// No description provided for @titleOnboardingVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get titleOnboardingVerifyPhone;

  /// No description provided for @subtitleOnboardingVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Step 4/4 - Secure your account'**
  String get subtitleOnboardingVerifyPhone;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get sectionNotifications;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get sectionSecurity;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get sectionLegal;

  /// No description provided for @menuEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get menuEditProfile;

  /// No description provided for @menuPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get menuPaymentMethods;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get menuDarkMode;

  /// No description provided for @menuChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get menuChangePassword;

  /// No description provided for @menuTwoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get menuTwoFactorAuth;

  /// No description provided for @menuIDVerification.
  ///
  /// In en, this message translates to:
  /// **'ID Verification'**
  String get menuIDVerification;

  /// No description provided for @menuEmailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get menuEmailNotifications;

  /// No description provided for @menuPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get menuPushNotifications;

  /// No description provided for @menuFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ (Frequently Asked Questions)'**
  String get menuFaq;

  /// No description provided for @menuContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get menuContactUs;

  /// No description provided for @menuTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get menuTermsOfService;

  /// No description provided for @menuPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get menuPrivacyPolicy;

  /// No description provided for @hintFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get hintFullName;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'University Email'**
  String get hintEmail;

  /// No description provided for @hintPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get hintPassword;

  /// No description provided for @hintConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get hintConfirmPassword;

  /// No description provided for @hintCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get hintCurrentPassword;

  /// No description provided for @hintNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get hintNewPassword;

  /// No description provided for @hintPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get hintPhone;

  /// No description provided for @placeholderFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get placeholderFrench;

  /// No description provided for @placeholderEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get placeholderEnglish;

  /// No description provided for @placeholderArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get placeholderArabic;

  /// No description provided for @msgPrivacyInfo.
  ///
  /// In en, this message translates to:
  /// **'This information allows us to create secure sub-communities.'**
  String get msgPrivacyInfo;

  /// No description provided for @msgAuthSecureInfo.
  ///
  /// In en, this message translates to:
  /// **'Secure login with your verified university email.'**
  String get msgAuthSecureInfo;

  /// No description provided for @msgPhoneInfo.
  ///
  /// In en, this message translates to:
  /// **'Use an SMS code for added security.'**
  String get msgPhoneInfo;

  /// No description provided for @msgEmailVerificationInfo.
  ///
  /// In en, this message translates to:
  /// **'A verification email will be sent to your university address.'**
  String get msgEmailVerificationInfo;

  /// No description provided for @msgRidesToRate.
  ///
  /// In en, this message translates to:
  /// **'Trips to Rate'**
  String get msgRidesToRate;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
