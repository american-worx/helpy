// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Helpy Ninja';

  @override
  String get welcome => 'Chào mừng';

  @override
  String get meetYourHelpy => 'Gặp gỡ Helpy của bạn';

  @override
  String get personalAITutor => 'Gia sư AI cá nhân học cùng bạn, phát triển cùng bạn';

  @override
  String get getStarted => 'Bắt đầu';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản?';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get askHelpyAnything => 'Hỏi Helpy bất cứ điều gì...';

  @override
  String get helpyIsThinking => 'Helpy đang suy nghĩ';

  @override
  String get chat => 'Trò chuyện';

  @override
  String get home => 'Trang chủ';

  @override
  String get learn => 'Học tập';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get settings => 'Cài đặt';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get loading => 'Đang tải...';

  @override
  String get error => 'Lỗi';

  @override
  String get offline => 'Ngoại tuyến';

  @override
  String get online => 'Trực tuyến';

  @override
  String get startYourLearningJourney => 'Bắt đầu hành trình học tập!';

  @override
  String get chooseHelpyPersonality => 'Chọn một phong cách Helpy để bắt đầu trò chuyện và nhận được sự hỗ trợ cá nhân hóa cho việc học của bạn.';

  @override
  String get chooseYourHelpy => 'Chọn Helpy của bạn';

  @override
  String get seeAllPersonalities => 'Xem tất cả phong cách';

  @override
  String get startFirstChat => 'Bắt đầu cuộc trò chuyện đầu tiên';

  @override
  String get oopsSomethingWentWrong => 'Ồ! Có lỗi xảy ra';

  @override
  String get tryAgain => 'Thử lại';

  @override
  String get conversationNotFound => 'Không tìm thấy cuộc trò chuyện';

  @override
  String get failedToLoadMessages => 'Không thể tải tin nhắn';

  @override
  String get retry => 'Thử lại';

  @override
  String get newChat => 'Trò chuyện mới';

  @override
  String get chooseYourHelpyPersonality => 'Chọn tính cách Helpy của bạn';

  @override
  String get unreadMessages => 'tin nhắn chưa đọc';

  @override
  String get markAsRead => 'Đánh dấu đã đọc';

  @override
  String get archive => 'Lưu trữ';

  @override
  String get delete => 'Xóa';

  @override
  String get archiveFeatureComingSoon => 'Tính năng lưu trữ sắp ra mắt!';

  @override
  String get deleteConversation => 'Xóa cuộc hội thoại';

  @override
  String deleteConversationConfirm(String title) {
    return 'Bạn có chắc chắn muốn xóa \"$title\"? Hành động này không thể hoàn tác.';
  }

  @override
  String get cancel => 'Hủy';

  @override
  String get conversationDeleted => 'Đã xóa cuộc hội thoại';

  @override
  String failedToDeleteConversation(String error) {
    return 'Không thể xóa cuộc hội thoại: $error';
  }

  @override
  String failedToStartChat(String error) {
    return 'Không thể bắt đầu trò chuyện: $error';
  }

  @override
  String get groupChatTitle => 'Trò chuyện nhóm';

  @override
  String get participantListTitle => 'Người tham gia';

  @override
  String get sessionStatusActive => 'Hoạt động';

  @override
  String get sessionStatusPaused => 'Tạm dừng';

  @override
  String get sessionStatusCompleted => 'Đã hoàn thành';

  @override
  String get sessionStatusCancelled => 'Đã hủy';

  @override
  String get helpyStatusOnline => 'Trực tuyến';

  @override
  String get helpyStatusThinking => 'Đang suy nghĩ';

  @override
  String get helpyStatusResponding => 'Đang phản hồi';

  @override
  String get helpyStatusOffline => 'Ngoại tuyến';

  @override
  String get participantStatusActive => 'Hoạt động';

  @override
  String get participantStatusInactive => 'Không hoạt động';

  @override
  String get participantStatusLeft => 'Đã rời đi';

  @override
  String get participantStatusDisconnected => 'Mất kết nối';

  @override
  String get addParticipants => 'Thêm người tham gia';

  @override
  String get addParticipant => 'Thêm người tham gia';

  @override
  String get inviteParticipants => 'Mời người tham gia';

  @override
  String get participantAdded => 'Đã thêm người tham gia thành công';

  @override
  String failedToAddParticipant(String error) {
    return 'Không thể thêm người tham gia: $error';
  }

  @override
  String get selectParticipants => 'Chọn người tham gia';

  @override
  String get noParticipantsToAdd => 'Không có người tham gia để thêm';

  @override
  String failedToLoadConversations(String error) {
    return 'Không thể tải cuộc trò chuyện: $error';
  }

  @override
  String get noConversationsYet => 'Chưa có cuộc trò chuyện nào';

  @override
  String get startAConversation => 'Bắt đầu một cuộc trò chuyện với Helpy của bạn để bắt đầu học!';

  @override
  String get sendMessage => 'Gửi tin nhắn';

  @override
  String get typeYourMessage => 'Nhập tin nhắn của bạn...';

  @override
  String failedToSendMessage(String error) {
    return 'Không thể gửi tin nhắn: $error';
  }

  @override
  String get messageSent => 'Tin nhắn đã gửi';

  @override
  String get messageFailed => 'Tin nhắn thất bại';

  @override
  String get messageDelivered => 'Tin nhắn đã được gửi';

  @override
  String get messageRead => 'Tin nhắn đã đọc';

  @override
  String get typing => 'đang nhập...';

  @override
  String get onlineNow => 'Đang trực tuyến';

  @override
  String lastSeen(String time) {
    return 'Lần cuối thấy $time';
  }

  @override
  String get helpyThinking => 'Helpy đang suy nghĩ...';

  @override
  String get helpyTyping => 'Helpy đang nhập...';

  @override
  String get helpyOnline => 'Helpy đang trực tuyến';

  @override
  String get helpyOffline => 'Helpy đang ngoại tuyến';

  @override
  String failedToLoadHelpy(String error) {
    return 'Không thể tải Helpy: $error';
  }

  @override
  String get helpyNotFound => 'Không tìm thấy Helpy';

  @override
  String get selectHelpy => 'Chọn Helpy';

  @override
  String get changeHelpy => 'Thay đổi Helpy';

  @override
  String get helpyChanged => 'Helpy đã được thay đổi thành công';

  @override
  String failedToChangeHelpy(String error) {
    return 'Không thể thay đổi Helpy: $error';
  }

  @override
  String get helpyPersonality => 'Tính cách Helpy';

  @override
  String get friendly => 'Thân thiện';

  @override
  String get professional => 'Chuyên nghiệp';

  @override
  String get playful => 'Vui nhộn';

  @override
  String get wise => 'Thông thái';

  @override
  String get encouraging => 'Khuyến khích';

  @override
  String get patient => 'Kiên nhẫn';

  @override
  String get lessonViewer => 'Trình xem bài học';

  @override
  String get nextSection => 'Phần tiếp theo';

  @override
  String get previousSection => 'Phần trước';

  @override
  String get section => 'Phần';

  @override
  String get oF => 'trong số';

  @override
  String get completeLesson => 'Hoàn thành bài học';

  @override
  String get takeQuiz => 'Làm bài kiểm tra';

  @override
  String get lessonCompleted => 'Bài học đã hoàn thành';

  @override
  String get quizResults => 'Kết quả bài kiểm tra';

  @override
  String get reviewAnswers => 'Xem lại câu trả lời';

  @override
  String get retakeQuiz => 'Làm lại bài kiểm tra';

  @override
  String get quizCompleted => 'Bài kiểm tra đã hoàn thành';

  @override
  String get correct => 'Đúng';

  @override
  String get incorrect => 'Sai';

  @override
  String get yourAnswer => 'Câu trả lời của bạn';

  @override
  String get correctAnswer => 'Câu trả lời đúng';

  @override
  String get quizScore => 'Điểm bài kiểm tra';

  @override
  String get totalQuestions => 'Tổng số câu hỏi';

  @override
  String get correctAnswers => 'Câu trả lời đúng';

  @override
  String get incorrectAnswers => 'Câu trả lời sai';

  @override
  String get unanswered => 'Chưa trả lời';

  @override
  String get timeTaken => 'Thời gian thực hiện';

  @override
  String get quizFeedback => 'Phản hồi bài kiểm tra';

  @override
  String get greatJob => 'Làm tốt lắm!';

  @override
  String get keepPracticing => 'Tiếp tục luyện tập!';

  @override
  String get needMoreStudy => 'Cần học thêm!';

  @override
  String get perfectScore => 'Điểm tuyệt đối!';

  @override
  String get lessonReportSubmitted => 'Báo cáo đã được gửi';

  @override
  String get lessonComplete => 'Hoàn thành bài học!';

  @override
  String get lessonCompleteMessage => 'Chúc mừng! Bạn đã hoàn thành bài học này thành công.';

  @override
  String get continueLearning => 'Tiếp tục học tập';

  @override
  String get lessonNotFound => 'Không tìm thấy bài học';

  @override
  String quizStartFailed(String error) {
    return 'Không thể bắt đầu bài kiểm tra: $error';
  }

  @override
  String get noQuestionsAvailable => 'Không có câu hỏi nào cho bài học này';

  @override
  String get quizPractice => 'Luyện tập kiểm tra';

  @override
  String questionNumber(int number) {
    return 'Câu hỏi $number';
  }

  @override
  String scoreLabel(int correct, int total) {
    return 'Điểm: $correct/$total';
  }

  @override
  String get explanation => 'Giải thích';

  @override
  String get unlockedAchievements => 'Thành tích đã mở khóa';

  @override
  String get lockedAchievements => 'Thành tích bị khóa';

  @override
  String get progressAnalytics => 'Phân tích tiến độ';

  @override
  String get weeklyProgress => 'Tiến độ hàng tuần';

  @override
  String get weeklyGoal => 'Mục tiêu hàng tuần';

  @override
  String get averagePerDay => 'Trung bình mỗi ngày';

  @override
  String get subjectProgress => 'Tiến độ môn học';

  @override
  String lessonsCount(String count) {
    return '$count Bài học';
  }

  @override
  String get progressLabel => 'Tiến độ';

  @override
  String get completionLabel => 'Hoàn thành';

  @override
  String get lessons => 'Bài học';

  @override
  String get studyTimeAnalytics => 'Phân tích thời gian học tập';

  @override
  String get totalStudyTime => 'Tổng thời gian học tập';

  @override
  String get averagePerSession => 'Trung bình mỗi buổi';

  @override
  String get mostActive => 'Hoạt động nhất';

  @override
  String get streakAnalytics => 'Phân tích chuỗi học tập';

  @override
  String get currentStreak => 'Chuỗi hiện tại';

  @override
  String get longestStreak => 'Chuỗi dài nhất';

  @override
  String get keepGoingOnFire => 'Tiếp tục phát huy, bạn đang rất tích cực! 🚒';

  @override
  String get startStudyingToBuildStreak => 'Bắt đầu học để xây dựng chuỗi học tập của bạn';

  @override
  String get monday => 'Thứ Hai';

  @override
  String get tuesday => 'Thứ Ba';

  @override
  String get wednesday => 'Thứ Tư';

  @override
  String get thursday => 'Thứ Năm';

  @override
  String get friday => 'Thứ Sáu';

  @override
  String get saturday => 'Thứ Bảy';

  @override
  String get sunday => 'Chủ Nhật';

  @override
  String get morning => 'Buổi sáng';

  @override
  String get afternoon => 'Buổi chiều';

  @override
  String get evening => 'Buổi tối';

  @override
  String get night => 'Ban đêm';

  @override
  String get days => 'Ngày';

  @override
  String get groupSessions => 'Phiên Học Nhóm';

  @override
  String get createGroupSession => 'Tạo Phiên Học Nhóm';

  @override
  String get joinGroupSession => 'Tham gia Phiên Học Nhóm';

  @override
  String get leaveGroupSession => 'Rời khỏi Phiên Học Nhóm';

  @override
  String get groupSessionName => 'Tên Phiên Học Nhóm';

  @override
  String get participants => 'Người tham gia';

  @override
  String get helpyParticipants => 'Helpy tham gia';

  @override
  String get sendMessageToGroup => 'Gửi tin nhắn đến nhóm';

  @override
  String get groupSessionCreated => 'Phiên học nhóm đã được tạo thành công';

  @override
  String get groupSessionJoined => 'Đã tham gia phiên học nhóm thành công';

  @override
  String get groupSessionLeft => 'Đã rời khỏi phiên học nhóm thành công';

  @override
  String failedToCreateGroupSession(String error) {
    return 'Không thể tạo phiên học nhóm: $error';
  }

  @override
  String failedToJoinGroupSession(String error) {
    return 'Không thể tham gia phiên học nhóm: $error';
  }

  @override
  String failedToLeaveGroupSession(String error) {
    return 'Không thể rời khỏi phiên học nhóm: $error';
  }

  @override
  String get groupSessionNotFound => 'Không tìm thấy phiên học nhóm';

  @override
  String get active => 'Hoạt động';

  @override
  String get inactive => 'Không hoạt động';

  @override
  String get left => 'Đã rời đi';

  @override
  String get disconnected => 'Mất kết nối';

  @override
  String get groupSessionActive => 'Phiên Học Nhóm Đang Hoạt Động';

  @override
  String get groupSessionPaused => 'Phiên Học Nhóm Tạm Dừng';

  @override
  String get groupSessionCompleted => 'Phiên Học Nhóm Đã Hoàn Thành';

  @override
  String get groupSessionCancelled => 'Phiên Học Nhóm Đã Bị Hủy';

  @override
  String get noGroupSessions => 'Chưa có phiên học nhóm nào';

  @override
  String get startGroupSession => 'Bắt đầu một phiên học nhóm để hợp tác với các học sinh và Helpy khác!';

  @override
  String get groupMessageSent => 'Tin nhắn nhóm đã được gửi';

  @override
  String failedToSendGroupMessage(String error) {
    return 'Không thể gửi tin nhắn nhóm: $error';
  }

  @override
  String groupTyping(String name) {
    return '$name đang nhập...';
  }

  @override
  String multipleGroupTyping(int count) {
    return '$count người đang nhập...';
  }

  @override
  String get achievements => 'Thành Tích';

  @override
  String get arts => 'Nghệ thuật';

  @override
  String get behindGoal => 'Chậm Tiến Độ';

  @override
  String get biology => 'Sinh học';

  @override
  String get browseSubjects => 'Duyệt Môn Học';

  @override
  String get chemistry => 'Hóa học';

  @override
  String get chooseYourSubjects => 'Chọn môn học của bạn';

  @override
  String get computerScience => 'Khoa học máy tính';

  @override
  String get continueLearningComingSoon => 'Chức năng tiếp tục học sẽ sớm ra mắt!';

  @override
  String get continueToHelpySetup => 'Tiếp tục thiết lập Helpy';

  @override
  String daysAgo(int days) {
    return '$days ngày trước';
  }

  @override
  String get daysPlural => 'ngày';

  @override
  String get daysSingular => 'ngày';

  @override
  String get economics => 'Kinh tế';

  @override
  String get english => 'Tiếng Anh';

  @override
  String errorSavingProfile(String error) {
    return 'Lỗi khi lưu hồ sơ: $error';
  }

  @override
  String errorSavingSubjects(String error) {
    return 'Lỗi khi lưu môn học: $error';
  }

  @override
  String get french => 'Tiếng Pháp';

  @override
  String get fullActivityHistoryComingSoon => 'Lịch sử hoạt động đầy đủ sẽ sớm ra mắt!';

  @override
  String get geography => 'Địa lý';

  @override
  String get getStartedWithTheseActions => 'Bắt đầu với những hành động này';

  @override
  String get goodAfternoon => 'Chào buổi chiều';

  @override
  String get goodEvening => 'Chào buổi tối';

  @override
  String get goodMorning => 'Chào buổi sáng';

  @override
  String get history => 'Lịch sử';

  @override
  String hoursAgo(int hours) {
    return '$hours giờ trước';
  }

  @override
  String get justNow => 'Vừa xong';

  @override
  String get keepUpTheGreatWork => 'Tiếp tục phát huy nhé!';

  @override
  String get languages => 'Ngôn ngữ';

  @override
  String get lessonBookmarked => 'Bài học đã được đánh dấu!';

  @override
  String get lessonSharing => 'Đang chia sẻ bài học...';

  @override
  String lessonStartFailed(String error) {
    return 'Không thể bắt đầu bài học: $error';
  }

  @override
  String get lessonsCompleted => 'Bài Học Đã Hoàn Thành';

  @override
  String get loadingProgressData => 'Đang tải dữ liệu tiến độ...';

  @override
  String get mathematics => 'Toán học';

  @override
  String minutesAgo(int minutes) {
    return '$minutes phút trước';
  }

  @override
  String get moreActivities => 'hoạt động khác';

  @override
  String get music => 'Âm nhạc';

  @override
  String get myProgress => 'Tiến Độ Của Tôi';

  @override
  String get noRecentActivityYet => 'Chưa có hoạt động gần đây';

  @override
  String get onTrack => 'Đúng Tiến Độ';

  @override
  String percentComplete(int percent) {
    return '$percent% hoàn thành';
  }

  @override
  String get physics => 'Vật lý';

  @override
  String get pleaseEnterValidEmail => 'Vui lòng nhập email hợp lệ';

  @override
  String get pleaseEnterYourEmail => 'Vui lòng nhập email của bạn';

  @override
  String get pleaseSelectAtLeastOneSubject => 'Vui lòng chọn ít nhất một môn học';

  @override
  String get practiceQuiz => 'Luyện Tập Câu Hỏi';

  @override
  String get practiceQuizComingSoon => 'Chức năng luyện tập câu hỏi sẽ sớm ra mắt!';

  @override
  String get quickActions => 'Hành Động Nhanh';

  @override
  String get readyToContinueLearning => 'Sẵn sàng tiếp tục hành trình học tập của bạn?';

  @override
  String get recentActivity => 'Hoạt Động Gần Đây';

  @override
  String get socialStudies => 'Khoa học xã hội';

  @override
  String get spanish => 'Tiếng Tây Ban Nha';

  @override
  String get startLearningToSeeProgress => 'Bắt đầu học để xem tiến độ của bạn ở đây';

  @override
  String get startNewChat => 'Bắt Đầu Trò Chuyện Mới';

  @override
  String get stem => 'STEM';

  @override
  String stepXOfY(int step, int total) {
    return 'Bước $step trong tổng số $total';
  }

  @override
  String get streak => 'liên tiếp!';

  @override
  String get studyGroups => 'Nhóm Học Tập';

  @override
  String get studyGroupsComingSoon => 'Chức năng nhóm học tập sẽ sớm ra mắt!';

  @override
  String get studyTime => 'Thời Gian Học';

  @override
  String subjectsSelected(int count) {
    return '$count môn học đã chọn';
  }

  @override
  String get time => 'Thời gian';

  @override
  String get trackYourLearningJourney => 'Theo dõi hành trình học tập của bạn';

  @override
  String get trackYourLearningTimeline => 'Dòng thời gian học tập của bạn';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get view => 'Xem';

  @override
  String get viewAll => 'Xem Tất Cả';

  @override
  String get viewAllActivitiesComingSoon => 'Xem tất cả hoạt động sẽ sớm ra mắt!';

  @override
  String get visualArts => 'Mỹ thuật';

  @override
  String get yourLearningTimeline => 'Dòng thời gian học tập của bạn';

  @override
  String get yourProgress => 'Tiến độ của bạn';

  @override
  String get yourProgressInDifferentSubjects => 'Tiến độ của bạn trong các môn học khác nhau';
}
