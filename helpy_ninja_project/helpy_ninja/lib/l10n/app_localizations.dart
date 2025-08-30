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

  /// Title for group chat screen
  ///
  /// In en, this message translates to:
  /// **'Group Chat'**
  String get groupChatTitle;

  /// Title for participant list
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participantListTitle;

  /// Status text for active session
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get sessionStatusActive;

  /// Status text for paused session
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get sessionStatusPaused;

  /// Status text for completed session
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sessionStatusCompleted;

  /// Status text for cancelled session
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get sessionStatusCancelled;

  /// Status text for online Helpy
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get helpyStatusOnline;

  /// Status text for thinking Helpy
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get helpyStatusThinking;

  /// Status text for responding Helpy
  ///
  /// In en, this message translates to:
  /// **'Responding'**
  String get helpyStatusResponding;

  /// Status text for offline Helpy
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get helpyStatusOffline;

  /// Status text for active participant
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get participantStatusActive;

  /// Status text for inactive participant
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get participantStatusInactive;

  /// Status text for participant who left
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get participantStatusLeft;

  /// Status text for disconnected participant
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get participantStatusDisconnected;

  /// Button text to add participants to group chat
  ///
  /// In en, this message translates to:
  /// **'Add Participants'**
  String get addParticipants;

  /// Button text to add a single participant
  ///
  /// In en, this message translates to:
  /// **'Add Participant'**
  String get addParticipant;

  /// Button text to invite participants to group chat
  ///
  /// In en, this message translates to:
  /// **'Invite Participants'**
  String get inviteParticipants;

  /// Success message when participant is added
  ///
  /// In en, this message translates to:
  /// **'Participant added successfully'**
  String get participantAdded;

  /// Error message when adding participant fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add participant: {error}'**
  String failedToAddParticipant(String error);

  /// Title for participant selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Participants'**
  String get selectParticipants;

  /// Message shown when there are no participants to add
  ///
  /// In en, this message translates to:
  /// **'No participants to add'**
  String get noParticipantsToAdd;

  /// Error message when conversations fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load conversations: {error}'**
  String failedToLoadConversations(String error);

  /// Message shown when user has no conversations
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// Encouragement message to start first conversation
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your Helpy to begin learning!'**
  String get startAConversation;

  /// Button text to send message
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// Placeholder text for message input
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// Error message when message fails to send
  ///
  /// In en, this message translates to:
  /// **'Failed to send message: {error}'**
  String failedToSendMessage(String error);

  /// Success message when message is sent
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get messageSent;

  /// Error message when message fails
  ///
  /// In en, this message translates to:
  /// **'Message failed'**
  String get messageFailed;

  /// Status message when message is delivered
  ///
  /// In en, this message translates to:
  /// **'Message delivered'**
  String get messageDelivered;

  /// Status message when message is read
  ///
  /// In en, this message translates to:
  /// **'Message read'**
  String get messageRead;

  /// Indicator text when someone is typing
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get typing;

  /// Status text for online users
  ///
  /// In en, this message translates to:
  /// **'Online now'**
  String get onlineNow;

  /// Status text showing when user was last seen
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String lastSeen(String time);

  /// Indicator text when Helpy is processing
  ///
  /// In en, this message translates to:
  /// **'Helpy is thinking...'**
  String get helpyThinking;

  /// Indicator text when Helpy is typing
  ///
  /// In en, this message translates to:
  /// **'Helpy is typing...'**
  String get helpyTyping;

  /// Status text for online Helpy
  ///
  /// In en, this message translates to:
  /// **'Helpy is online'**
  String get helpyOnline;

  /// Status text for offline Helpy
  ///
  /// In en, this message translates to:
  /// **'Helpy is offline'**
  String get helpyOffline;

  /// Error message when Helpy fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load Helpy: {error}'**
  String failedToLoadHelpy(String error);

  /// Error message when Helpy cannot be found
  ///
  /// In en, this message translates to:
  /// **'Helpy not found'**
  String get helpyNotFound;

  /// Button text to select Helpy
  ///
  /// In en, this message translates to:
  /// **'Select Helpy'**
  String get selectHelpy;

  /// Button text to change Helpy
  ///
  /// In en, this message translates to:
  /// **'Change Helpy'**
  String get changeHelpy;

  /// Success message when Helpy is changed
  ///
  /// In en, this message translates to:
  /// **'Helpy changed successfully'**
  String get helpyChanged;

  /// Error message when changing Helpy fails
  ///
  /// In en, this message translates to:
  /// **'Failed to change Helpy: {error}'**
  String failedToChangeHelpy(String error);

  /// Title for Helpy personality selection
  ///
  /// In en, this message translates to:
  /// **'Helpy Personality'**
  String get helpyPersonality;

  /// Friendly Helpy personality
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get friendly;

  /// Professional Helpy personality
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professional;

  /// Playful Helpy personality
  ///
  /// In en, this message translates to:
  /// **'Playful'**
  String get playful;

  /// Wise Helpy personality
  ///
  /// In en, this message translates to:
  /// **'Wise'**
  String get wise;

  /// Encouraging Helpy personality
  ///
  /// In en, this message translates to:
  /// **'Encouraging'**
  String get encouraging;

  /// Patient Helpy personality
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// Title for lesson viewer screen
  ///
  /// In en, this message translates to:
  /// **'Lesson Viewer'**
  String get lessonViewer;

  /// Button text to go to next lesson section
  ///
  /// In en, this message translates to:
  /// **'Next Section'**
  String get nextSection;

  /// Button text to go to previous lesson section
  ///
  /// In en, this message translates to:
  /// **'Previous Section'**
  String get previousSection;

  /// Label for lesson section
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get section;

  /// Preposition for section numbering
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get oF;

  /// Button text to complete lesson
  ///
  /// In en, this message translates to:
  /// **'Complete Lesson'**
  String get completeLesson;

  /// Button text to start quiz
  ///
  /// In en, this message translates to:
  /// **'Take Quiz'**
  String get takeQuiz;

  /// Message shown when lesson is completed
  ///
  /// In en, this message translates to:
  /// **'Lesson Completed'**
  String get lessonCompleted;

  /// Title for quiz results screen
  ///
  /// In en, this message translates to:
  /// **'Quiz Results'**
  String get quizResults;

  /// Button text to review quiz answers
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get reviewAnswers;

  /// Button text to retake quiz
  ///
  /// In en, this message translates to:
  /// **'Retake Quiz'**
  String get retakeQuiz;

  /// Message shown when quiz is completed
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed'**
  String get quizCompleted;

  /// Label for correct answer
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// Label for incorrect answer
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// Label for user's answer
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswer;

  /// Label for correct answer
  ///
  /// In en, this message translates to:
  /// **'Correct Answer'**
  String get correctAnswer;

  /// Title for quiz score section
  ///
  /// In en, this message translates to:
  /// **'Quiz Score'**
  String get quizScore;

  /// Label for total number of questions
  ///
  /// In en, this message translates to:
  /// **'Total Questions'**
  String get totalQuestions;

  /// Label for number of correct answers
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get correctAnswers;

  /// Label for number of incorrect answers
  ///
  /// In en, this message translates to:
  /// **'Incorrect Answers'**
  String get incorrectAnswers;

  /// Label for unanswered questions
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get unanswered;

  /// Label for time taken to complete quiz
  ///
  /// In en, this message translates to:
  /// **'Time Taken'**
  String get timeTaken;

  /// Title for quiz feedback section
  ///
  /// In en, this message translates to:
  /// **'Quiz Feedback'**
  String get quizFeedback;

  /// Encouragement message for good quiz performance
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get greatJob;

  /// Encouragement message for improvement needed
  ///
  /// In en, this message translates to:
  /// **'Keep Practicing!'**
  String get keepPracticing;

  /// Encouragement message for significant improvement needed
  ///
  /// In en, this message translates to:
  /// **'Need More Study!'**
  String get needMoreStudy;

  /// Message for perfect quiz score
  ///
  /// In en, this message translates to:
  /// **'Perfect Score!'**
  String get perfectScore;

  /// Message shown when lesson report is submitted
  ///
  /// In en, this message translates to:
  /// **'Lesson report submitted successfully'**
  String get lessonReportSubmitted;

  /// Title for lesson completion dialog
  ///
  /// In en, this message translates to:
  /// **'Lesson Complete!'**
  String get lessonComplete;

  /// Message shown when lesson is completed
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have successfully completed this lesson.'**
  String get lessonCompleteMessage;

  /// Button text to continue learning after completing a lesson
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// Error message when lesson is not found
  ///
  /// In en, this message translates to:
  /// **'Lesson not found'**
  String get lessonNotFound;

  /// Error message when quiz fails to start
  ///
  /// In en, this message translates to:
  /// **'Failed to start quiz: {error}'**
  String quizStartFailed(String error);

  /// Message shown when no quiz questions are available
  ///
  /// In en, this message translates to:
  /// **'No questions available for this lesson'**
  String get noQuestionsAvailable;

  /// Title for quiz practice screen
  ///
  /// In en, this message translates to:
  /// **'Quiz Practice'**
  String get quizPractice;

  /// Label for question number
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionNumber(int number);

  /// Label for quiz score
  ///
  /// In en, this message translates to:
  /// **'Score: {correct}/{total}'**
  String scoreLabel(int correct, int total);

  /// Label for question explanation
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// Section title for unlocked achievements
  ///
  /// In en, this message translates to:
  /// **'Unlocked Achievements'**
  String get unlockedAchievements;

  /// Section title for locked achievements
  ///
  /// In en, this message translates to:
  /// **'Locked Achievements'**
  String get lockedAchievements;

  /// Title for progress analytics screen
  ///
  /// In en, this message translates to:
  /// **'Progress Analytics'**
  String get progressAnalytics;

  /// Title for weekly progress section
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// Label for weekly goal
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get weeklyGoal;

  /// Label for daily average
  ///
  /// In en, this message translates to:
  /// **'Average Per Day'**
  String get averagePerDay;

  /// Title for subject progress section
  ///
  /// In en, this message translates to:
  /// **'Subject Progress'**
  String get subjectProgress;

  /// Label for lesson count
  ///
  /// In en, this message translates to:
  /// **'{count} Lessons'**
  String lessonsCount(String count);

  /// Label for progress section
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// Label for completion section
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get completionLabel;

  /// Label for lessons
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// Title for study time analytics section
  ///
  /// In en, this message translates to:
  /// **'Study Time Analytics'**
  String get studyTimeAnalytics;

  /// Label for total study time
  ///
  /// In en, this message translates to:
  /// **'Total Study Time'**
  String get totalStudyTime;

  /// Label for average time per session
  ///
  /// In en, this message translates to:
  /// **'Average Per Session'**
  String get averagePerSession;

  /// Label for most active time period
  ///
  /// In en, this message translates to:
  /// **'Most Active'**
  String get mostActive;

  /// Title for streak analytics section
  ///
  /// In en, this message translates to:
  /// **'Streak Analytics'**
  String get streakAnalytics;

  /// Label for current streak
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Label for longest streak
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// Encouragement message for active streak
  ///
  /// In en, this message translates to:
  /// **'Keep going, you\'re on fire! 🚒'**
  String get keepGoingOnFire;

  /// Encouragement message to start studying for streak
  ///
  /// In en, this message translates to:
  /// **'Start studying to build your streak'**
  String get startStudyingToBuildStreak;

  /// Abbreviation for Monday
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Abbreviation for Tuesday
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Abbreviation for Wednesday
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Abbreviation for Thursday
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Abbreviation for Friday
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Abbreviation for Saturday
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Abbreviation for Sunday
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// Time period: morning
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// Time period: afternoon
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// Time period: evening
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// Time period: night
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// Plural form of day
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// Title for group sessions screen
  ///
  /// In en, this message translates to:
  /// **'Group Sessions'**
  String get groupSessions;

  /// Button text to create a new group session
  ///
  /// In en, this message translates to:
  /// **'Create Group Session'**
  String get createGroupSession;

  /// Button text to join an existing group session
  ///
  /// In en, this message translates to:
  /// **'Join Group Session'**
  String get joinGroupSession;

  /// Button text to leave a group session
  ///
  /// In en, this message translates to:
  /// **'Leave Group Session'**
  String get leaveGroupSession;

  /// Label for group session name input
  ///
  /// In en, this message translates to:
  /// **'Group Session Name'**
  String get groupSessionName;

  /// Label for participants list
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// Label for Helpy participants list
  ///
  /// In en, this message translates to:
  /// **'Helpy Participants'**
  String get helpyParticipants;

  /// Placeholder text for group message input
  ///
  /// In en, this message translates to:
  /// **'Send Message to Group'**
  String get sendMessageToGroup;

  /// Success message when group session is created
  ///
  /// In en, this message translates to:
  /// **'Group session created successfully'**
  String get groupSessionCreated;

  /// Success message when user joins a group session
  ///
  /// In en, this message translates to:
  /// **'Joined group session successfully'**
  String get groupSessionJoined;

  /// Success message when user leaves a group session
  ///
  /// In en, this message translates to:
  /// **'Left group session successfully'**
  String get groupSessionLeft;

  /// Error message when group session creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create group session: {error}'**
  String failedToCreateGroupSession(String error);

  /// Error message when joining group session fails
  ///
  /// In en, this message translates to:
  /// **'Failed to join group session: {error}'**
  String failedToJoinGroupSession(String error);

  /// Error message when leaving group session fails
  ///
  /// In en, this message translates to:
  /// **'Failed to leave group session: {error}'**
  String failedToLeaveGroupSession(String error);

  /// Error message when group session cannot be found
  ///
  /// In en, this message translates to:
  /// **'Group session not found'**
  String get groupSessionNotFound;

  /// Status for active participant
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Status for inactive participant
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Status for participant who left
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// Status for disconnected participant
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// Status text for active group session
  ///
  /// In en, this message translates to:
  /// **'Group Session Active'**
  String get groupSessionActive;

  /// Status text for paused group session
  ///
  /// In en, this message translates to:
  /// **'Group Session Paused'**
  String get groupSessionPaused;

  /// Status text for completed group session
  ///
  /// In en, this message translates to:
  /// **'Group Session Completed'**
  String get groupSessionCompleted;

  /// Status text for cancelled group session
  ///
  /// In en, this message translates to:
  /// **'Group Session Cancelled'**
  String get groupSessionCancelled;

  /// Message shown when there are no group sessions
  ///
  /// In en, this message translates to:
  /// **'No group sessions yet'**
  String get noGroupSessions;

  /// Encouragement message to start first group session
  ///
  /// In en, this message translates to:
  /// **'Start a group session to collaborate with other students and Helpys!'**
  String get startGroupSession;

  /// Success message when group message is sent
  ///
  /// In en, this message translates to:
  /// **'Group message sent'**
  String get groupMessageSent;

  /// Error message when group message fails to send
  ///
  /// In en, this message translates to:
  /// **'Failed to send group message: {error}'**
  String failedToSendGroupMessage(String error);

  /// Indicator text when someone is typing in group chat
  ///
  /// In en, this message translates to:
  /// **'{name} is typing...'**
  String groupTyping(String name);

  /// Indicator text when multiple people are typing in group chat
  ///
  /// In en, this message translates to:
  /// **'{count} people are typing...'**
  String multipleGroupTyping(int count);

  /// Label for achievements section
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Arts subject name
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get arts;

  /// Status for being behind goal
  ///
  /// In en, this message translates to:
  /// **'Behind Goal'**
  String get behindGoal;

  /// Biology subject name
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get biology;

  /// Button text to browse subjects
  ///
  /// In en, this message translates to:
  /// **'Browse Subjects'**
  String get browseSubjects;

  /// Chemistry subject name
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get chemistry;

  /// Title for subject selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Your Subjects'**
  String get chooseYourSubjects;

  /// Computer Science subject name
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get computerScience;

  /// Message shown when continue learning feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'Continue learning feature coming soon!'**
  String get continueLearningComingSoon;

  /// Button text to proceed to Helpy customization
  ///
  /// In en, this message translates to:
  /// **'Continue to Helpy Setup'**
  String get continueToHelpySetup;

  /// Text for timestamp in days
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// Plural form of days
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysPlural;

  /// Singular form of day
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get daysSingular;

  /// Economics subject name
  ///
  /// In en, this message translates to:
  /// **'Economics'**
  String get economics;

  /// English subject name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Error message when saving profile fails
  ///
  /// In en, this message translates to:
  /// **'Error saving profile: {error}'**
  String errorSavingProfile(String error);

  /// Error message when saving subjects fails
  ///
  /// In en, this message translates to:
  /// **'Error saving subjects: {error}'**
  String errorSavingSubjects(String error);

  /// French subject name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Message shown when full activity history is not yet available
  ///
  /// In en, this message translates to:
  /// **'Full activity history coming soon!'**
  String get fullActivityHistoryComingSoon;

  /// Geography subject name
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get geography;

  /// Subtitle for quick actions section
  ///
  /// In en, this message translates to:
  /// **'Get started with these actions'**
  String get getStartedWithTheseActions;

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

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// History subject name
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Text for timestamp in hours
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// Text for very recent timestamp
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Encouragement message for learning progress
  ///
  /// In en, this message translates to:
  /// **'Keep up the great work!'**
  String get keepUpTheGreatWork;

  /// Languages category name
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// Success message when lesson is bookmarked
  ///
  /// In en, this message translates to:
  /// **'Lesson bookmarked!'**
  String get lessonBookmarked;

  /// Message shown when sharing a lesson
  ///
  /// In en, this message translates to:
  /// **'Sharing lesson...'**
  String get lessonSharing;

  /// Error message when lesson fails to start
  ///
  /// In en, this message translates to:
  /// **'Failed to start lesson: {error}'**
  String lessonStartFailed(String error);

  /// Label for completed lessons count
  ///
  /// In en, this message translates to:
  /// **'Lessons Completed'**
  String get lessonsCompleted;

  /// Loading message for progress data
  ///
  /// In en, this message translates to:
  /// **'Loading progress data...'**
  String get loadingProgressData;

  /// Mathematics subject name
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get mathematics;

  /// Text for timestamp in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(int minutes);

  /// Text for additional activity count
  ///
  /// In en, this message translates to:
  /// **'more activities'**
  String get moreActivities;

  /// Music subject name
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// Button text for progress tracking
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get myProgress;

  /// Message shown when there is no recent activity
  ///
  /// In en, this message translates to:
  /// **'No recent activity yet'**
  String get noRecentActivityYet;

  /// Status for being on track with goals
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// Text for percentage completion
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String percentComplete(int percent);

  /// Physics subject name
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get physics;

  /// Email format validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// Validation message for subject selection
  ///
  /// In en, this message translates to:
  /// **'Please select at least one subject'**
  String get pleaseSelectAtLeastOneSubject;

  /// Button text for practice quiz
  ///
  /// In en, this message translates to:
  /// **'Practice Quiz'**
  String get practiceQuiz;

  /// Message shown when practice quiz feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'Practice quiz feature coming soon!'**
  String get practiceQuizComingSoon;

  /// Title for quick actions section
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Greeting message asking if user is ready to continue learning
  ///
  /// In en, this message translates to:
  /// **'Ready to continue learning?'**
  String get readyToContinueLearning;

  /// Title for recent activity section
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Social Studies category name
  ///
  /// In en, this message translates to:
  /// **'Social Studies'**
  String get socialStudies;

  /// Spanish subject name
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Encouragement message to start learning
  ///
  /// In en, this message translates to:
  /// **'Start learning to see your progress here'**
  String get startLearningToSeeProgress;

  /// Button text to start a new chat
  ///
  /// In en, this message translates to:
  /// **'Start New Chat'**
  String get startNewChat;

  /// STEM category name
  ///
  /// In en, this message translates to:
  /// **'STEM'**
  String get stem;

  /// Progress indicator text
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepXOfY(int step, int total);

  /// Streak indicator text
  ///
  /// In en, this message translates to:
  /// **'streak!'**
  String get streak;

  /// Button text for study groups
  ///
  /// In en, this message translates to:
  /// **'Study Groups'**
  String get studyGroups;

  /// Message shown when study groups feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'Study groups feature coming soon!'**
  String get studyGroupsComingSoon;

  /// Label for study time
  ///
  /// In en, this message translates to:
  /// **'Study Time'**
  String get studyTime;

  /// Count of selected subjects
  ///
  /// In en, this message translates to:
  /// **'{count} subjects selected'**
  String subjectsSelected(int count);

  /// Label for time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Subtitle for progress section
  ///
  /// In en, this message translates to:
  /// **'Track your learning journey'**
  String get trackYourLearningJourney;

  /// Subtitle for recent activity section
  ///
  /// In en, this message translates to:
  /// **'Track your learning timeline'**
  String get trackYourLearningTimeline;

  /// Vietnamese subject name
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// Button text to view
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// Button text to view all
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Message shown when view all activities feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'View all activities coming soon!'**
  String get viewAllActivitiesComingSoon;

  /// Visual Arts subject name
  ///
  /// In en, this message translates to:
  /// **'Visual Arts'**
  String get visualArts;

  /// Subtitle for recent activity section
  ///
  /// In en, this message translates to:
  /// **'Your Learning Timeline'**
  String get yourLearningTimeline;

  /// Title for progress section
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

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
