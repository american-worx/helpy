// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Helpy Ninja';

  @override
  String get welcome => 'Welcome';

  @override
  String get meetYourHelpy => 'Meet Your Helpy';

  @override
  String get personalAITutor => 'Your personal AI tutor that learns with you, grows with you';

  @override
  String get getStarted => 'Get Started';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get askHelpyAnything => 'Ask Helpy anything...';

  @override
  String get helpyIsThinking => 'Helpy is thinking';

  @override
  String get chat => 'Chat';

  @override
  String get home => 'Home';

  @override
  String get learn => 'Learn';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get startYourLearningJourney => 'Start Your Learning Journey!';

  @override
  String get chooseHelpyPersonality => 'Choose a Helpy personality to begin chatting and get personalized help with your studies.';

  @override
  String get chooseYourHelpy => 'Choose Your Helpy';

  @override
  String get seeAllPersonalities => 'See All Personalities';

  @override
  String get startFirstChat => 'Start First Chat';

  @override
  String get oopsSomethingWentWrong => 'Oops! Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get conversationNotFound => 'Conversation not found';

  @override
  String get failedToLoadMessages => 'Failed to load messages';

  @override
  String get retry => 'Retry';

  @override
  String get newChat => 'New Chat';

  @override
  String get chooseYourHelpyPersonality => 'Choose Your Helpy Personality';

  @override
  String get unreadMessages => 'unread messages';

  @override
  String get markAsRead => 'Mark as Read';

  @override
  String get archive => 'Archive';

  @override
  String get delete => 'Delete';

  @override
  String get archiveFeatureComingSoon => 'Archive feature coming soon!';

  @override
  String get deleteConversation => 'Delete Conversation';

  @override
  String deleteConversationConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get conversationDeleted => 'Conversation deleted';

  @override
  String failedToDeleteConversation(String error) {
    return 'Failed to delete conversation: $error';
  }

  @override
  String failedToStartChat(String error) {
    return 'Failed to start chat: $error';
  }

  @override
  String get chooseYourSubjects => 'Choose Your Subjects';

  @override
  String stepXOfY(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String subjectsSelected(int count) {
    return '$count subjects selected';
  }

  @override
  String get pleaseSelectAtLeastOneSubject => 'Please select at least one subject';

  @override
  String get continueToHelpySetup => 'Continue to Helpy Setup';

  @override
  String errorSavingSubjects(String error) {
    return 'Error saving subjects: $error';
  }

  @override
  String get mathematics => 'Mathematics';

  @override
  String get physics => 'Physics';

  @override
  String get chemistry => 'Chemistry';

  @override
  String get biology => 'Biology';

  @override
  String get computerScience => 'Computer Science';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get french => 'French';

  @override
  String get spanish => 'Spanish';

  @override
  String get history => 'History';

  @override
  String get geography => 'Geography';

  @override
  String get economics => 'Economics';

  @override
  String get visualArts => 'Visual Arts';

  @override
  String get music => 'Music';

  @override
  String get stem => 'STEM';

  @override
  String get languages => 'Languages';

  @override
  String get socialStudies => 'Social Studies';

  @override
  String get arts => 'Arts';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get readyToContinueLearning => 'Ready to continue learning?';

  @override
  String get daysSingular => 'day';

  @override
  String get daysPlural => 'days';

  @override
  String get streak => 'streak!';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get trackYourLearningJourney => 'Track your learning journey';

  @override
  String get loadingProgressData => 'Loading progress data...';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String errorSavingProfile(String error) {
    return 'Error saving profile: $error';
  }

  @override
  String get keepUpTheGreatWork => 'Keep up the great work!';

  @override
  String get lessonsCompleted => 'Lessons Completed';

  @override
  String get achievements => 'Achievements';

  @override
  String get studyTime => 'Study Time';

  @override
  String get weeklyGoal => 'Weekly Goal';

  @override
  String get onTrack => 'On Track';

  @override
  String get behindGoal => 'Behind Goal';

  @override
  String get continueLearningComingSoon => 'Continue learning functionality coming soon!';

  @override
  String get practiceQuizComingSoon => 'Practice quiz functionality coming soon!';

  @override
  String get studyGroupsComingSoon => 'Study groups functionality coming soon!';

  @override
  String get fullActivityHistoryComingSoon => 'Full activity history coming soon!';

  @override
  String get viewAllActivitiesComingSoon => 'View all activities coming soon!';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String percentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get getStartedWithTheseActions => 'Get started with these actions';

  @override
  String get startNewChat => 'Start New Chat';

  @override
  String get browseSubjects => 'Browse Subjects';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get practiceQuiz => 'Practice Quiz';

  @override
  String get myProgress => 'My Progress';

  @override
  String get studyGroups => 'Study Groups';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noRecentActivityYet => 'No recent activity yet';

  @override
  String get startLearningToSeeProgress => 'Start learning to see your progress here';

  @override
  String get yourLearningTimeline => 'Your learning timeline';

  @override
  String get viewAll => 'View All';

  @override
  String get view => 'View';

  @override
  String get moreActivities => 'more activities';

  @override
  String get subjectProgress => 'Subject Progress';

  @override
  String get yourProgressInDifferentSubjects => 'Your progress in different subjects';
}
