// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SessionManager {
  static final _userStorage = GetStorage();

  static const String _tokenKey = 'Token Key';
  static const String _username = 'UserName';
  static const String _branch = 'Branch ID';
  static const String _counter = 'counter ID';
  static const String _quizTime = 'Quiz Time';
  static const String _userId = 'User ID';
  static const String _fcmToken = 'FCM Token';

  static Future<void> saveToken(String token) async {
    await _userStorage.write(_tokenKey, token);
    debugPrint("User ID saved ==> $token.");
  }

  static String getToken() {
    String token = _userStorage.read<String?>(_tokenKey) ?? '';
    debugPrint("User ID ==> $token.");
    return token;
  }

  static Future<void> saveUsername(String username) async {
    await _userStorage.write(_username, username);
    debugPrint("Username ==> $username.");
  }

  static String getUsername() {
    String username = _userStorage.read<String?>(_username) ?? '';
    return username;
  }

  static Future<void> saveUserId(String userId) async {
    await _userStorage.write(_userId, userId);
    debugPrint("User ID saved ==> $userId.");
  }

  static String getUserId() {
    String userId = _userStorage.read<String?>(_userId) ?? '';
    debugPrint("User ID ==> $userId.");
    return userId;
  }

  static Future<void> savebranch(String branch) async {
    await _userStorage.write(_branch, branch);
    debugPrint("Branch saved ==> $branch.");
  }

  static String getBranch() {
    String branch = _userStorage.read<String?>(_branch) ?? '';
    debugPrint("Branch Id ==> $branch.");
    return branch;
  }

  static Future<void> saveCounter(String counter) async {
    await _userStorage.write(_counter, counter);
    debugPrint("Counter saved ==> $counter.");
  }

  static String getCounter() {
    String counter = _userStorage.read<String?>(_counter) ?? '';
    return counter;
  }

  static Future<void> saveQuizStartTime(
    String quizId,
    DateTime startTime,
  ) async {
    await _userStorage.write('$_quizTime$quizId', startTime.toIso8601String());
    debugPrint("Quiz start time saved for $quizId ==> $startTime");
  }

  static DateTime? getQuizStartTime(String quizId) {
    final value = _userStorage.read<String?>('$_quizTime$quizId');
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  static Future<void> clearQuizStartTime(String quizId) async {
    await _userStorage.remove('$_quizTime$quizId');
  }

  static Future<void> saveFcmToken(String token) async {
    await _userStorage.write(_fcmToken, token);
    debugPrint("FCM Token saved ==> $token");
  }

  static String getFcmToken() {
    return _userStorage.read<String?>(_fcmToken) ?? '';
  }

  static Future<void> clearFcmToken() async {
    await _userStorage.remove(_fcmToken);
  }

  static void clearSession() {
    _userStorage.erase();
    debugPrint("Session Cleared.");
  }
}
