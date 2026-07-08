import 'package:flutter/foundation.dart';

import '../models/locale_config.dart';

/// No-op locale holder for shared wallet widgets (standalone build).
class EvolveProvider extends ChangeNotifier {
  LocaleConfig locale = LocaleConfig.defaults;

  void setLocale(LocaleConfig config) {
    if (locale.regionId == config.regionId &&
        locale.languageCode == config.languageCode) {
      return;
    }
    locale = config;
    notifyListeners();
  }
}