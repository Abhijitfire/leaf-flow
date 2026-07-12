import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_translations.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class LocaleNotifier extends Notifier<String> {
  static const _localeKey = 'selected_locale';

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_localeKey) ?? 'en';
  }

  Future<void> toggleLocale() async {
    final newLocale = state == 'en' ? 'bn' : 'en';
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_localeKey, newLocale);
    state = newLocale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, String>(() {
  return LocaleNotifier();
});

final appTranslationsProvider = Provider<AppTranslations>((ref) {
  final locale = ref.watch(localeProvider);
  return AppTranslations(locale);
});
