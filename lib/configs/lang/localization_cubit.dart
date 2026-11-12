// lib/bloc/localization/localization_cubit.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

part 'localization_state.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  // Kept in its own box so logging out (which erases the session box) does
  // not reset the language.
  static const storageBox = 'settings';
  static const _langKey = 'Language';
  static final _storage = GetStorage(storageBox);

  static const english = Locale('en', 'US');
  static const arabic = Locale('ar', 'SA');

  // Arabic unless the user already picked a language on this device.
  LocalizationCubit()
    : super(
        LocalizationState(
          locale: _storage.read<String?>(_langKey) == 'en' ? english : arabic,
        ),
      ) {
    _instance = this;
  }

  static LocalizationCubit? _instance;

  /// For code with no BuildContext (cubits, services, toasts): the current
  /// language's text for [key], or [key] itself when there is none.
  static String translateKey(String key) => _instance?.translate(key) ?? key;

  /// The app's current language code ('en' before the cubit exists)
  static String get currentLanguageCode =>
      _instance?.state.locale.languageCode ?? 'en';

  Map<String, String> _localizedStrings = {};

  Future<void> load() async {
    final langCode = state.locale.languageCode;
    final jsonString = await _loadLanguageFile(langCode);
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    emit(state.copyWith());
  }

  /// On the web the browser keeps serving an old copy of the language file
  /// after a deploy, so new texts showed as their keys (feedback_none). Fetch
  /// it fresh there, falling back to the bundled copy.
  static Future<String> _loadLanguageFile(String langCode) async {
    final asset = 'assets/lang/$langCode.json';
    if (kIsWeb) {
      try {
        // Relative, so the browser resolves it against <base href> like
        // Flutter's own asset requests; the query skips its cache.
        final response = await Dio().get<String>(
          'assets/$asset?v=${DateTime.now().millisecondsSinceEpoch}',
          options: Options(
            responseType: ResponseType.plain,
            headers: {'Cache-Control': 'no-cache'},
          ),
        );
        final body = response.data;
        if (response.statusCode == 200 && body != null && body.isNotEmpty) {
          json.decode(body); // only use it if it parses
          return body;
        }
      } catch (e) {
        debugPrint('Fresh $asset failed, using the bundled one: $e');
      }
    }
    return rootBundle.loadString(asset, cache: false);
  }

  void toggleLanguage() =>
      setLocale(state.locale.languageCode == 'en' ? arabic : english);

  void setLocale(Locale locale) {
    if (locale.languageCode == state.locale.languageCode) return;
    _storage.write(_langKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
    load();
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

extension LocalizationExtension on BuildContext {
  /// ✅ Use this INSIDE normal widget build methods
  String tr(String key) {
    watch<LocalizationCubit>(); // rebuild-safe
    return read<LocalizationCubit>().translate(key);
  }

  /// ✅ Use this INSIDE PopupMenu, dialogs, callbacks, gestures
  String trNoListen(String key) {
    return read<LocalizationCubit>().translate(key);
  }

  Locale get currentLocale => watch<LocalizationCubit>().state.locale;
}

/// A counter's name for display: leading zeros dropped ("Counter 01" ->
/// "Counter 1") and, in Arabic, "Counter" translated. The number stays in
/// English digits in both languages.
String counterDisplayName(BuildContext context, String name) {
  final arabic = context.currentLocale.languageCode == 'ar';
  final unpadded = name.trim().replaceAllMapped(
    RegExp(r'\d+'),
    (m) => int.parse(m[0]!).toString(),
  );
  if (!arabic) return unpadded;
  final match = RegExp(
    r'^counter\s+(.+)$',
    caseSensitive: false,
  ).firstMatch(unpadded);
  final label = match == null
      ? unpadded
      : '${context.tr('counter')} ${match.group(1)}';
  return label;
}
