class ApiConstants {
  // static const String baseUrl = "http://localhost:8085/serveiq/api/";
  static const String baseUrl =
      "https://serveiqbackend.insyncproducts.online/serveiq/api/";
  static const String wsUrl =
      "wss://serveiqbackend.insyncproducts.online/serveiq/ws";

  // ---------- AUTH ----------
  static const String login = 'auth/login';
  static const String register = 'auth/register';

  // ---------- AGENT ----------
  static const String queue = 'agent/queue/';
  static const String callNext = 'agent/call-next-token/';
  static const String activeToken = 'agent/active-token/';
  static const String startServing = 'agent/token/start-serving/';
  static const String completeService = 'agent/token/complete/';
  static const String recentServices = 'agent/recent-services/';
  static const String recall = 'agent/token/recall/';
  static const String transfer = 'agent/token/transfer';
  static const String hold = 'agent/hold-token/';
  static const String callHoldToken = 'agent/call-hold-token/';
  static const String noShow = 'agent/no-show-token/';

  // ---------- COUNTERS ----------
  static const String counters = 'counters';
  static const String singleCounter = 'counters/';

  // ---------- QUIZ and TRAINING ----------
  static const String quiz = '/user/quiz-survey';
  static const String submit = 'user/quiz-survey/user/submit/';
  static const String result = 'user/quiz-result/';
  static const String topScorer = 'user/quiz-survey/summary/';

  static const String training = 'user/training/user/';
  static const String trainingProgess = 'user/training/progress';

  // ---------- USERS ----------
  static const String fcmToken = 'users/update-fcm-token/';
}
