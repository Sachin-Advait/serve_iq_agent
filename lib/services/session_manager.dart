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
    debugPrint("Username ==> $username.");
    return username;
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
    debugPrint("Counter Id ==> $counter.");
    return counter;
  }

  static void clearSession() {
    _userStorage.erase();
    debugPrint("Session Cleared.");
  }
}
