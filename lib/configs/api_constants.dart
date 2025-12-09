class ApiConstants {
  // static const String baseUrl = "http://109.205.180.193/api/";
  static const String baseUrl = "https://msspf.duckdns.org/serveiq/api/";
  static const String wsUrl = "wss://msspf.duckdns.org/serveiq/ws";

  // ---------- AUTH ----------
  static const String login = 'auth/login';
  static const String register = 'auth/register';

  // ---------- AGENT ----------
  static const String queue = 'agent/counter/queue/';
  static const String callNext = 'agent/counter/call-next/';
  static const String activeToken = 'agent/counter/active-token/';
  static const String startServing = 'agent/token/start-serving/';
  static const String completeService = 'agent/token/complete/';
  static const String recentServices = 'agent/recent-services/';
  static const String recall = 'agent/recall';
  static const String transfer = 'agent/transfer';

  // ---------- COUNTERS ----------
  static const String counters = 'counters';
  static const String singleCounter = 'counters/';
}
