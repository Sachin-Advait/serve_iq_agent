// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SessionManager {
  static final _userStorage = GetStorage();

  static const String _tokenKey = 'Token Key';
  static const String _username = 'UserName';

  static Future<void> saveToken(String token) async {
    await _userStorage.write(_tokenKey, token);
    debugPrint("Token saved ==> $token.");
  }

  static String getToken() {
    String token = _userStorage.read<String?>(_tokenKey) ?? '';
    debugPrint("Token ==> $token.");
    return token;
  }

  static Future<void> saveUsername(String username) async {
    await _userStorage.write(_username, username);
    debugPrint("Is Guest saved ==> $username.");
  }

  static String getUsername() {
    String username = _userStorage.read<String?>(_username) ?? '';
    debugPrint("Is Guest ==> $username.");
    return username;
  }

  static void clearSession() {
    _userStorage.erase();
    debugPrint("Session Cleared.");
  }
}
