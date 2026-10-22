// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'सैलरीक्वेस्ट';

  @override
  String get tagline => 'गेमिफाइड दैनिक बजट इंजन';

  @override
  String get onboardingWelcomeTitle => 'दैनिक बजट पर नियंत्रण पाएं';

  @override
  String get onboardingWelcomeSubtitle =>
      'अपनी मासिक सैलरी को सटीक, तनावमुक्त दैनिक खर्च सीमा में बदलें और महीने के अंत के बॉस को हराएं।';

  @override
  String get heroSelectionTitle => 'अपना हीरो चुनें';

  @override
  String get heroSelectionSubtitle =>
      'अपने वित्तीय साथी का चयन करें जो आपके पैसे बचाने पर XP अर्जित करता है और स्तर बढ़ाता है।';

  @override
  String get heroNameLabel => 'हीरो का नाम';

  @override
  String get heroKnightName => 'एरो द नाइट';

  @override
  String get heroKnightDesc =>
      'बचत का संतुलित रक्षक। अप्रत्याशित खर्चों के खिलाफ उच्च HP सहनशीलता।';

  @override
  String get heroMageName => 'लाइरा द मेज';

  @override
  String get heroMageDesc =>
      'बुद्धि-संचालित रणनीतिकार। लगातार बचत की स्ट्रीक पर बोनस सिक्के अर्जित करता है।';

  @override
  String get heroRogueName => 'केल द रोग';

  @override
  String get heroRogueDesc =>
      'फुर्तीला ट्रैकर। स्ट्रीक शील्ड के साथ सटीक बजटिंग का मास्टर।';

  @override
  String get salarySetupTitle => 'मासिक सैलरी और पे-डे';

  @override
  String get salarySetupSubtitle =>
      'आपकी सैलरी कब आती है, और योजना बनाने के लिए कितनी राशि उपलब्ध है?';

  @override
  String get inHandSalaryLabel => 'मासिक इन-हैंड सैलरी (₹)';

  @override
  String get inHandSalaryHint => 'उदा. 60000';

  @override
  String get paydayDayLabel => 'महीने का पे-डे';

  @override
  String get paydayDayHint => 'तारीख (1 - 31)';

  @override
  String get fixedExpensesAndGoalTitle => 'निश्चित खर्चे और बचत लक्ष्य';

  @override
  String get fixedExpensesAndGoalSubtitle =>
      'दैनिक खर्च सीमा की गणना के लिए अपने अनिवार्य खर्चों और लक्ष्य बचत को घटाएं।';

  @override
  String get fixedExpensesLabel => 'कुल निश्चित खर्चे (₹)';

  @override
  String get fixedExpensesHint => 'किराया, ईएमआई, बिजली-पानी बिल (उदा. 25000)';

  @override
  String get savingsTargetLabel => 'मासिक बचत लक्ष्य (₹)';

  @override
  String get savingsTargetHint => 'इमरजेंसी फंड / निवेश (उदा. 15000)';

  @override
  String get seriousModeTitle => 'सीरियस मोड';

  @override
  String get seriousModeSubtitle =>
      'क्या आपको बिना गेमिंग तत्वों का सरल वित्तीय डैशबोर्ड पसंद है? आरपीजी स्प्राइट्स और साउंड छिपाने के लिए सीरियस मोड चालू करें।';

  @override
  String get seriousModeEnableLabel => 'अभी सीरियस मोड चालू करें';

  @override
  String get continueButton => 'आगे बढ़ें';

  @override
  String get completeSetupButton => 'सेटअप पूरा करें और प्रवेश करें';

  @override
  String get errorSalaryZero => 'सैलरी ₹0 से अधिक होनी चाहिए';

  @override
  String get errorExpensesExceedSalary =>
      'निश्चित खर्चे और बचत लक्ष्य सैलरी से अधिक नहीं हो सकते';

  @override
  String get errorInvalidPayday => 'पे-डे 1 और 31 के बीच होना चाहिए';

  @override
  String get errorHeroNameEmpty => 'हीरो का नाम खाली नहीं हो सकता';

  @override
  String get dailyBudgetLabel => 'आज खर्च करने के लिए सुरक्षित';

  @override
  String get spentTodayLabel => 'आज का खर्च';

  @override
  String get remainingInPoolLabel => 'साइकिल में शेष राशि';

  @override
  String get daysRemainingLabel => 'शेष दिन';

  @override
  String get seeAllTransactions => 'सभी देखें';

  @override
  String get addTransaction => 'खर्च जोड़ें';

  @override
  String get editTransaction => 'लेन-देन संपादित करें';

  @override
  String get saveAndRecompute => 'सहेजें और बजट पुनः गणना करें';

  @override
  String get deleteTransaction => 'लेन-देन हटाएं';

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String get transactionDeleted => 'लेन-देन हटाया गया और XP वापस लिया गया';

  @override
  String get transactionRestored =>
      'लेन-देन बहाल किया गया और बजट अपडेट किया गया';

  @override
  String get searchPlaceholder => 'दुकानदार या विवरण खोजें...';

  @override
  String get filterAll => 'सभी';

  @override
  String get filterToday => 'आज';

  @override
  String get filterWeek => '7 दिन';

  @override
  String get filterCycle => 'वर्तमान साइकिल';

  @override
  String get noTransactionsFound => 'कोई लेन-देन नहीं मिला';

  @override
  String get resetFilters => 'फ़िल्टर रीसेट करें';

  @override
  String get categoryFood => 'भोजन और खानपान';

  @override
  String get categoryCommute => 'आवागमन / सफर';

  @override
  String get categoryGroceries => 'किराना';

  @override
  String get categoryEntertainment => 'मनोरंजन और गेमिंग';

  @override
  String get categoryBills => 'बिल और उपयोगिताएं';

  @override
  String get categoryShopping => 'खरीदारी';

  @override
  String get categoryHealth => 'स्वास्थ्य और फिटनेस';

  @override
  String get categoryMisc => 'अन्य';

  @override
  String get backupTitle => 'एन्क्रिप्टेड डेटा बैकअप';

  @override
  String get backupSubtitle =>
      'अपने पूरे वित्तीय डेटा को एक सुरक्षित AES-एन्क्रिप्टेड फ़ाइल में निर्यात करें या नए फोन पर पुनर्स्थापित करें।';

  @override
  String get exportBackupButton => 'एन्क्रिप्टेड बैकअप निर्यात करें';

  @override
  String get importBackupButton => 'बैकअप फ़ाइल से पुनर्स्थापित करें';

  @override
  String get backupExportSuccess => 'एन्क्रिप्टेड बैकअप सफलतापूर्वक तैयार हुआ!';

  @override
  String get backupImportSuccess =>
      'डेटा बिना किसी डुप्लिकेट के सफलतापूर्वक पुनर्स्थापित हुआ!';

  @override
  String get backupDecryptionFailed =>
      'डिक्रिप्शन विफल: दूषित फ़ाइल या अमान्य सुरक्षा कुंजी';

  @override
  String get settingsLanguage => 'भाषा / Language';

  @override
  String get languageEnglish => 'English (अंग्रेज़ी)';

  @override
  String get languageHindi => 'हिंदी (Hindi)';
}
