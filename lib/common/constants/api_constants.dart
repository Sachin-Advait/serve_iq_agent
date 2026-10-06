enum AppEnvironment { testing, production }

class ApiConstants {
  ApiConstants._();

  static const AppEnvironment _environment = bool.fromEnvironment('PRODUCTION')
      ? AppEnvironment.production
      : AppEnvironment.testing;

  static const String _testingBaseUrl =
      "https://serveiqbackend.insyncproducts.online/serveiq/api/";
  static const String _testingWsUrl =
      "wss://serveiqbackend.insyncproducts.online/serveiq/ws";

  // static const String _testingBaseUrl =
  //     "http://192.168.1.121:8085/serveiq/api/";
  // static const String _testingWsUrl = "ws://192.168.1.121:8085/serveiq/ws";

  static const String _prodBaseUrl =
      "https://testqms.msspf.gov.om/serveiq/api/";
  static const String _prodWsUrl = "wss://testqms.msspf.gov.om/serveiq/ws";

  static String get baseUrl => _environment == AppEnvironment.production
      ? _prodBaseUrl
      : _testingBaseUrl;

  static String get wsUrl =>
      _environment == AppEnvironment.production ? _prodWsUrl : _testingWsUrl;

  // ---------- AUTH ----------
  static const String login = 'auth/login';

  // ---------- AGENT ----------
  static const String pauseCounter = 'counters/pause/';

  // ---------- AUTH ----------
  // logout already exists: static const String logout = 'auth/logout';

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

  static const String counterLogout = 'agent/counter/logout';
  static const String counterPause = 'agent/counter/';
  static const String counterResume = 'agent/counter/';

  // ---------- COUNTERS ----------
  static const String counters = 'counters';
  static const String singleCounter = 'counters/';
  static const String authCounters = 'auth/counters';

  // ---------- QUIZ and TRAINING ----------
  static const String quiz = 'user/quiz-survey';
  static const String submit = 'user/quiz-survey/user/submit/';
  static const String result = 'user/quiz-result/';
  static const String topScorer = 'user/quiz-survey/summary/';

  static const String training = 'user/training/user/';
  static const String trainingProgess = 'user/training/progress';

  // ---------- USERS ----------
  static const String fcmToken = 'users/update-fcm-token/';
}
