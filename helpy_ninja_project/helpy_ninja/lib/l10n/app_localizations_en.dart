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
  String get groupChatTitle => 'Group Chat';

  @override
  String get participantListTitle => 'Participants';

  @override
  String get sessionStatusActive => 'Active';

  @override
  String get sessionStatusPaused => 'Paused';

  @override
  String get sessionStatusCompleted => 'Completed';

  @override
  String get sessionStatusCancelled => 'Cancelled';

  @override
  String get helpyStatusOnline => 'Online';

  @override
  String get helpyStatusThinking => 'Thinking';

  @override
  String get helpyStatusResponding => 'Responding';

  @override
  String get helpyStatusOffline => 'Offline';

  @override
  String get participantStatusActive => 'Active';

  @override
  String get participantStatusInactive => 'Inactive';

  @override
  String get participantStatusLeft => 'Left';

  @override
  String get participantStatusDisconnected => 'Disconnected';

  @override
  String get addParticipants => 'Add Participants';

  @override
  String get addParticipant => 'Add Participant';

  @override
  String get inviteParticipants => 'Invite Participants';

  @override
  String get participantAdded => 'Participant added successfully';

  @override
  String failedToAddParticipant(String error) {
    return 'Failed to add participant: $error';
  }

  @override
  String get selectParticipants => 'Select Participants';

  @override
  String get noParticipantsToAdd => 'No participants to add';

  @override
  String failedToLoadConversations(String error) {
    return 'Failed to load conversations: $error';
  }

  @override
  String get noConversationsYet => 'No conversations yet';

  @override
  String get startAConversation => 'Start a conversation with your Helpy to begin learning!';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String failedToSendMessage(String error) {
    return 'Failed to send message: $error';
  }

  @override
  String get messageSent => 'Message sent';

  @override
  String get messageFailed => 'Message failed';

  @override
  String get messageDelivered => 'Message delivered';

  @override
  String get messageRead => 'Message read';

  @override
  String get typing => 'typing...';

  @override
  String get onlineNow => 'Online now';

  @override
  String lastSeen(String time) {
    return 'Last seen $time';
  }

  @override
  String get helpyThinking => 'Helpy is thinking...';

  @override
  String get helpyTyping => 'Helpy is typing...';

  @override
  String get helpyOnline => 'Helpy is online';

  @override
  String get helpyOffline => 'Helpy is offline';

  @override
  String failedToLoadHelpy(String error) {
    return 'Failed to load Helpy: $error';
  }

  @override
  String get helpyNotFound => 'Helpy not found';

  @override
  String get selectHelpy => 'Select Helpy';

  @override
  String get changeHelpy => 'Change Helpy';

  @override
  String get helpyChanged => 'Helpy changed successfully';

  @override
  String failedToChangeHelpy(String error) {
    return 'Failed to change Helpy: $error';
  }

  @override
  String get helpyPersonality => 'Helpy Personality';

  @override
  String get friendly => 'Friendly';

  @override
  String get professional => 'Professional';

  @override
  String get playful => 'Playful';

  @override
  String get wise => 'Wise';

  @override
  String get encouraging => 'Encouraging';

  @override
  String get patient => 'Patient';

  @override
  String get lessonViewer => 'Lesson Viewer';

  @override
  String get nextSection => 'Next Section';

  @override
  String get previousSection => 'Previous Section';

  @override
  String get section => 'Section';

  @override
  String get oF => 'of';

  @override
  String get completeLesson => 'Complete Lesson';

  @override
  String get takeQuiz => 'Take Quiz';

  @override
  String get lessonCompleted => 'Lesson Completed';

  @override
  String get quizResults => 'Quiz Results';

  @override
  String get reviewAnswers => 'Review Answers';

  @override
  String get retakeQuiz => 'Retake Quiz';

  @override
  String get quizCompleted => 'Quiz Completed';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get yourAnswer => 'Your Answer';

  @override
  String get correctAnswer => 'Correct Answer';

  @override
  String get quizScore => 'Quiz Score';

  @override
  String get totalQuestions => 'Total Questions';

  @override
  String get correctAnswers => 'Correct Answers';

  @override
  String get incorrectAnswers => 'Incorrect Answers';

  @override
  String get unanswered => 'Unanswered';

  @override
  String get timeTaken => 'Time Taken';

  @override
  String get quizFeedback => 'Quiz Feedback';

  @override
  String get greatJob => 'Great Job!';

  @override
  String get keepPracticing => 'Keep Practicing!';

  @override
  String get needMoreStudy => 'Need More Study!';

  @override
  String get perfectScore => 'Perfect Score!';

  @override
  String get lessonReportSubmitted => 'Lesson report submitted successfully';

  @override
  String get lessonComplete => 'Lesson Complete!';

  @override
  String get lessonCompleteMessage => 'Congratulations! You have successfully completed this lesson.';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get lessonNotFound => 'Lesson not found';

  @override
  String quizStartFailed(String error) {
    return 'Failed to start quiz: $error';
  }

  @override
  String get noQuestionsAvailable => 'No questions available for this lesson';

  @override
  String get quizPractice => 'Quiz Practice';

  @override
  String questionNumber(int number) {
    return 'Question $number';
  }

  @override
  String scoreLabel(int correct, int total) {
    return 'Score: $correct/$total';
  }

  @override
  String get explanation => 'Explanation';

  @override
  String get unlockedAchievements => 'Unlocked Achievements';

  @override
  String get lockedAchievements => 'Locked Achievements';

  @override
  String get progressAnalytics => 'Progress Analytics';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get weeklyGoal => 'Weekly Goal';

  @override
  String get averagePerDay => 'Average Per Day';

  @override
  String get subjectProgress => 'Subject Progress';

  @override
  String lessonsCount(String count) {
    return '$count Lessons';
  }

  @override
  String get progressLabel => 'Progress';

  @override
  String get completionLabel => 'Completion';

  @override
  String get lessons => 'Lessons';

  @override
  String get studyTimeAnalytics => 'Study Time Analytics';

  @override
  String get totalStudyTime => 'Total Study Time';

  @override
  String get averagePerSession => 'Average Per Session';

  @override
  String get mostActive => 'Most Active';

  @override
  String get streakAnalytics => 'Streak Analytics';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get keepGoingOnFire => 'Keep going, you\'re on fire! 🚒';

  @override
  String get startStudyingToBuildStreak => 'Start studying to build your streak';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get night => 'Night';

  @override
  String get days => 'Days';

  @override
  String get groupSessions => 'Group Sessions';

  @override
  String get createGroupSession => 'Create Group Session';

  @override
  String get joinGroupSession => 'Join Group Session';

  @override
  String get leaveGroupSession => 'Leave Group Session';

  @override
  String get groupSessionName => 'Group Session Name';

  @override
  String get participants => 'Participants';

  @override
  String get helpyParticipants => 'Helpy Participants';

  @override
  String get sendMessageToGroup => 'Send Message to Group';

  @override
  String get groupSessionCreated => 'Group session created successfully';

  @override
  String get groupSessionJoined => 'Joined group session successfully';

  @override
  String get groupSessionLeft => 'Left group session successfully';

  @override
  String failedToCreateGroupSession(String error) {
    return 'Failed to create group session: $error';
  }

  @override
  String failedToJoinGroupSession(String error) {
    return 'Failed to join group session: $error';
  }

  @override
  String failedToLeaveGroupSession(String error) {
    return 'Failed to leave group session: $error';
  }

  @override
  String get groupSessionNotFound => 'Group session not found';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get left => 'Left';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get groupSessionActive => 'Group Session Active';

  @override
  String get groupSessionPaused => 'Group Session Paused';

  @override
  String get groupSessionCompleted => 'Group Session Completed';

  @override
  String get groupSessionCancelled => 'Group Session Cancelled';

  @override
  String get noGroupSessions => 'No group sessions yet';

  @override
  String get startGroupSession => 'Start a group session to collaborate with other students and Helpys!';

  @override
  String get groupMessageSent => 'Group message sent';

  @override
  String failedToSendGroupMessage(String error) {
    return 'Failed to send group message: $error';
  }

  @override
  String groupTyping(String name) {
    return '$name is typing...';
  }

  @override
  String multipleGroupTyping(int count) {
    return '$count people are typing...';
  }

  @override
  String get achievements => 'Achievements';

  @override
  String get arts => 'Arts';

  @override
  String get behindGoal => 'Behind Goal';

  @override
  String get biology => 'Biology';

  @override
  String get browseSubjects => 'Browse Subjects';

  @override
  String get chemistry => 'Chemistry';

  @override
  String get chooseYourSubjects => 'Choose Your Subjects';

  @override
  String get computerScience => 'Computer Science';

  @override
  String get continueLearningComingSoon => 'Continue learning feature coming soon!';

  @override
  String get continueToHelpySetup => 'Continue to Helpy Setup';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get daysPlural => 'days';

  @override
  String get daysSingular => 'day';

  @override
  String get economics => 'Economics';

  @override
  String get english => 'English';

  @override
  String errorSavingProfile(String error) {
    return 'Error saving profile: $error';
  }

  @override
  String errorSavingSubjects(String error) {
    return 'Error saving subjects: $error';
  }

  @override
  String get french => 'French';

  @override
  String get fullActivityHistoryComingSoon => 'Full activity history coming soon!';

  @override
  String get geography => 'Geography';

  @override
  String get getStartedWithTheseActions => 'Get started with these actions';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get history => 'History';

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get keepUpTheGreatWork => 'Keep up the great work!';

  @override
  String get languages => 'Languages';

  @override
  String get lessonBookmarked => 'Lesson bookmarked!';

  @override
  String get lessonSharing => 'Sharing lesson...';

  @override
  String lessonStartFailed(String error) {
    return 'Failed to start lesson: $error';
  }

  @override
  String get lessonsCompleted => 'Lessons Completed';

  @override
  String get loadingProgressData => 'Loading progress data...';

  @override
  String get mathematics => 'Mathematics';

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String get moreActivities => 'more activities';

  @override
  String get music => 'Music';

  @override
  String get myProgress => 'My Progress';

  @override
  String get noRecentActivityYet => 'No recent activity yet';

  @override
  String get onTrack => 'On Track';

  @override
  String percentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String get physics => 'Physics';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get pleaseSelectAtLeastOneSubject => 'Please select at least one subject';

  @override
  String get practiceQuiz => 'Practice Quiz';

  @override
  String get practiceQuizComingSoon => 'Practice quiz feature coming soon!';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get readyToContinueLearning => 'Ready to continue learning?';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get socialStudies => 'Social Studies';

  @override
  String get spanish => 'Spanish';

  @override
  String get startLearningToSeeProgress => 'Start learning to see your progress here';

  @override
  String get startNewChat => 'Start New Chat';

  @override
  String get stem => 'STEM';

  @override
  String stepXOfY(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get streak => 'streak!';

  @override
  String get studyGroups => 'Study Groups';

  @override
  String get studyGroupsComingSoon => 'Study groups feature coming soon!';

  @override
  String get studyTime => 'Study Time';

  @override
  String subjectsSelected(int count) {
    return '$count subjects selected';
  }

  @override
  String get time => 'Time';

  @override
  String get trackYourLearningJourney => 'Track your learning journey';

  @override
  String get trackYourLearningTimeline => 'Track your learning timeline';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get view => 'View';

  @override
  String get viewAll => 'View All';

  @override
  String get viewAllActivitiesComingSoon => 'View all activities coming soon!';

  @override
  String get visualArts => 'Visual Arts';

  @override
  String get yourLearningTimeline => 'Your Learning Timeline';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get yourProgressInDifferentSubjects => 'Your progress in different subjects';
}
