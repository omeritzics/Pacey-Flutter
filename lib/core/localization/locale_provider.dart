import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale> {
  // Special locale to indicate "Follow System"
  static const Locale _systemLocale = Locale('system');
  
  @override
  Locale build() {
    // Default to follow system
    return _systemLocale;
  }

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLocale() {
    if (state.languageCode == _systemLocale.languageCode) {
      state = const Locale("en");
    } else if (state.languageCode == "en") {
      state = const Locale("he");
    } else {
      state = _systemLocale;
    }
  }

  /// Gets the effective locale to use (resolves system locale if needed)
  Locale getEffectiveLocale() {
    if (state.languageCode == _systemLocale.languageCode) {
      return _getSystemLocale();
    }
    return state;
  }

  /// Gets the system locale, falling back to supported languages
  Locale _getSystemLocale() {
    try {
      // Get system locale
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      
      // Check if system language is supported (English or Hebrew)
      if (systemLocale.languageCode == "he") {
        return const Locale("he");
      } else if (systemLocale.languageCode == "en") {
        return const Locale("en");
      }
      
      // For web platform, try to get browser language
      if (kIsWeb) {
        // Web-specific locale detection could be added here
        // For now, fall back to English
      }
      
      // Default to English for unsupported languages
      return const Locale("en");
    } catch (e) {
      // If there's any error getting system locale, default to English
      return const Locale("en");
    }
  }

  /// Checks if the current locale is following system
  bool get isFollowingSystem => state.languageCode == _systemLocale.languageCode;
}
