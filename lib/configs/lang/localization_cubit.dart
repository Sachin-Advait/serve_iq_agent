// lib/bloc/localization/localization_cubit.dart
import 'dart:convert';

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

  Map<String, String> _localizedStrings = {};

  Future<void> load() async {
    final langCode = state.locale.languageCode;
    final jsonString = await rootBundle.loadString(
      'assets/lang/$langCode.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    emit(state.copyWith());
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

/// Western digits in [text] written as Arabic digits (١٢٣) when [arabic].
String localizedDigits(String text, {required bool arabic}) {
  if (!arabic) return text;
  const digits = '٠١٢٣٤٥٦٧٨٩';
  return text.replaceAllMapped(
    RegExp(r'[0-9]'),
    (m) => digits[m[0]!.codeUnitAt(0) - 48],
  );
}

/// A counter's name for display: leading zeros dropped ("Counter 01" ->
/// "Counter 1") and, in Arabic, "Counter" translated with Arabic digits.
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
  return localizedDigits(label, arabic: true);
}
