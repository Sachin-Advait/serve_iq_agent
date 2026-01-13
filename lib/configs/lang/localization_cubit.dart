// lib/bloc/localization/localization_cubit.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'localization_state.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  LocalizationCubit()
    : super(LocalizationState(locale: const Locale('en', 'US')));

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

  void toggleLanguage() {
    final newLocale = state.locale.languageCode == 'en'
        ? const Locale('ar', 'SA')
        : const Locale('en', 'US');

    emit(state.copyWith(locale: newLocale));
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
