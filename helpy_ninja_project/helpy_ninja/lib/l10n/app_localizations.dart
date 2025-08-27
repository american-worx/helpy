import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('en'),
    Locale('vi')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Helpy Ninja'**
  String get appTitle;

  /// Welcome message for users
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Heading text for introducing the AI tutor
  ///
  /// In en, this message translates to:
  /// **'Meet Your Helpy'**
  String get meetYourHelpy;

  /// Description of what Helpy is
  ///
  /// In en, this message translates to:
  /// **'Your personal AI tutor that learns with you, grows with you'**
  String get personalAITutor;

  /// Button text to begin onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Text asking if user has existing account
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Placeholder text for chat input
  ///
  /// In en, this message translates to:
  /// **'Ask Helpy anything...'**
  String get askHelpyAnything;

  /// Message shown when AI is processing
  ///
  /// In en, this message translates to:
  /// **'Helpy is thinking'**
  String get helpyIsThinking;

  /// Chat tab label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Learn tab label
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Dark mode setting label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Offline status indicator
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Online status indicator
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Heading text for empty chat state
  ///
  /// In en, this message translates to:
  /// **'Start Your Learning Journey!'**
  String get startYourLearningJourney;

  /// Description text for selecting a Helpy personality to chat with
  ///
  /// In en, this message translates to:
  /// **'Choose a Helpy personality to begin chatting and get personalized help with your studies.'**
  String get chooseHelpyPersonality;

  /// Section title for personality selection
  ///
  /// In en, this message translates to:
  /// **'Choose Your Helpy'**
  String get chooseYourHelpy;

  /// Button text to view all available Helpy personalities
  ///
  /// In en, this message translates to:
  /// **'See All Personalities'**
  String get seeAllPersonalities;

  /// Button text to begin first conversation
  ///
  /// In en, this message translates to:
  /// **'Start First Chat'**
  String get startFirstChat;

  /// Error state heading message
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWentWrong;

  /// Button text to retry failed action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Error message when conversation cannot be found
  ///
  /// In en, this message translates to:
  /// **'Conversation not found'**
  String get conversationNotFound;

  /// Error message when messages fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get failedToLoadMessages;

  /// Button text to retry loading
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Button text to start new chat
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// Modal title for personality selection
  ///
  /// In en, this message translates to:
  /// **'Choose Your Helpy Personality'**
  String get chooseYourHelpyPersonality;

  /// Text for unread message count
  ///
  /// In en, this message translates to:
  /// **'unread messages'**
  String get unreadMessages;

  /// Menu option to mark conversation as read
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get markAsRead;

  /// Menu option to archive conversation
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Menu option to delete conversation
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Message shown when archive feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'Archive feature coming soon!'**
  String get archiveFeatureComingSoon;

  /// Dialog title for conversation deletion
  ///
  /// In en, this message translates to:
  /// **'Delete Conversation'**
  String get deleteConversation;

  /// Confirmation message for deleting conversation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This action cannot be undone.'**
  String deleteConversationConfirm(String title);

  /// Button text to cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Success message when conversation is deleted
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversationDeleted;

  /// Error message when conversation deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete conversation: {error}'**
  String failedToDeleteConversation(String error);

  /// Error message when starting new chat fails
  ///
  /// In en, this message translates to:
  /// **'Failed to start chat: {error}'**
  String failedToStartChat(String error);

  /// Title for subject selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Your Subjects'**
  String get chooseYourSubjects;

  /// Progress indicator text
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepXOfY(int step, int total);

  /// Count of selected subjects
  ///
  /// In en, this message translates to:
  /// **'{count} subjects selected'**
  String subjectsSelected(int count);

  /// Validation message for subject selection
  ///
  /// In en, this message translates to:
  /// **'Please select at least one subject'**
  String get pleaseSelectAtLeastOneSubject;

  /// Button text to proceed to Helpy customization
  ///
  /// In en, this message translates to:
  /// **'Continue to Helpy Setup'**
  String get continueToHelpySetup;

  /// Error message when saving subjects fails
  ///
  /// In en, this message translates to:
  /// **'Error saving subjects: {error}'**
  String errorSavingSubjects(String error);

  /// Mathematics subject name
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get mathematics;

  /// Physics subject name
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get physics;

  /// Chemistry subject name
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get chemistry;

  /// Biology subject name
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get biology;

  /// Computer Science subject name
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get computerScience;

  /// English subject name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Vietnamese subject name
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// French subject name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Spanish subject name
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// History subject name
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Geography subject name
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get geography;

  /// Economics subject name
  ///
  /// In en, this message translates to:
  /// **'Economics'**
  String get economics;

  /// Visual Arts subject name
  ///
  /// In en, this message translates to:
  /// **'Visual Arts'**
  String get visualArts;

  /// Music subject name
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// STEM category name
  ///
  /// In en, this message translates to:
  /// **'STEM'**
  String get stem;

  /// Languages category name
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// Social Studies category name
  ///
  /// In en, this message translates to:
  /// **'Social Studies'**
  String get socialStudies;

  /// Arts category name
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get arts;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// Welcome message asking if user is ready to learn
  ///
  /// In en, this message translates to:
  /// **'Ready to continue learning?'**
  String get readyToContinueLearning;

  /// Singular form of day
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get daysSingular;

  /// Plural form of days
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysPlural;

  /// Streak indicator text
  ///
  /// In en, this message translates to:
  /// **'streak!'**
  String get streak;

  /// Progress section title
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// Progress section subtitle
  ///
  /// In en, this message translates to:
  /// **'Track your learning journey'**
  String get trackYourLearningJourney;

  /// Loading message for progress data
  ///
  /// In en, this message translates to:
  /// **'Loading progress data...'**
  String get loadingProgressData;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// Email format validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Error message when saving profile fails
  ///
  /// In en, this message translates to:
  /// **'Error saving profile: {error}'**
  String errorSavingProfile(String error);

  /// Encouragement message for progress
  ///
  /// In en, this message translates to:
  /// **'Keep up the great work!'**
  String get keepUpTheGreatWork;

  /// Label for completed lessons count
  ///
  /// In en, this message translates to:
  /// **'Lessons Completed'**
  String get lessonsCompleted;

  /// Label for achievements section
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Label for total study time
  ///
  /// In en, this message translates to:
  /// **'Study Time'**
  String get studyTime;

  /// Label for weekly learning goal
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get weeklyGoal;

  /// Status indicating user is meeting their goal
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// Status indicating user is behind their goal
  ///
  /// In en, this message translates to:
  /// **'Behind Goal'**
  String get behindGoal;

  /// Message shown when continue learning feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'Continue learning functionality coming soon!'**
  String get continueLearningComingSoon;

  /// Message shown when practice quiz feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'Practice quiz functionality coming soon!'**
  String get practiceQuizComingSoon;

  /// Message shown when study groups feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'Study groups functionality coming soon!'**
  String get studyGroupsComingSoon;

  /// Message shown when full activity history feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'Full activity history coming soon!'**
  String get fullActivityHistoryComingSoon;

  /// Message shown when view all activities feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'View all activities coming soon!'**
  String get viewAllActivitiesComingSoon;

  /// Text for very recent timestamp
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Text for minutes ago timestamp
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// Text for hours ago timestamp
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// Text for days ago timestamp
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// Text for progress percentage
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String percentComplete(int percent);

  /// Title for quick actions section
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Subtitle for quick actions section
  ///
  /// In en, this message translates to:
  /// **'Get started with these actions'**
  String get getStartedWithTheseActions;

  /// Button text to start a new chat
  ///
  /// In en, this message translates to:
  /// **'Start New Chat'**
  String get startNewChat;

  /// Button text to browse subjects
  ///
  /// In en, this message translates to:
  /// **'Browse Subjects'**
  String get browseSubjects;

  /// Button text to continue learning
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// Button text for practice quiz
  ///
  /// In en, this message translates to:
  /// **'Practice Quiz'**
  String get practiceQuiz;

  /// Button text for progress tracking
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get myProgress;

  /// Button text for study groups
  ///
  /// In en, this message translates to:
  /// **'Study Groups'**
  String get studyGroups;

  /// Title for recent activity section
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Message shown when there is no recent activity
  ///
  /// In en, this message translates to:
  /// **'No recent activity yet'**
  String get noRecentActivityYet;

  /// Encouragement message when no activity is present
  ///
  /// In en, this message translates to:
  /// **'Start learning to see your progress here'**
  String get startLearningToSeeProgress;

  /// Subtitle for recent activity section
  ///
  /// In en, this message translates to:
  /// **'Your learning timeline'**
  String get yourLearningTimeline;

  /// Button text to view all items
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Button text to view items
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// Text for additional activities count
  ///
  /// In en, this message translates to:
  /// **'more activities'**
  String get moreActivities;

  /// Title for subject progress section
  ///
  /// In en, this message translates to:
  /// **'Subject Progress'**
  String get subjectProgress;

  /// Subtitle for subject progress section
  ///
  /// In en, this message translates to:
  /// **'Your progress in different subjects'**
  String get yourProgressInDifferentSubjects;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
