import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../standalone/wallet_ports.dart';
import '../wallet_core/services/device_locale_resolver.dart';
import '../wallet_core/services/locale_store.dart';
import '../wallet_core/services/locale_store_factory.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider({
    LocaleStore? store,
    this.autoDetectFromDevice = true,
    Locale? deviceLocaleOverride,
  })  : _store = store ?? createLocaleStore(),
        _deviceLocaleOverride = deviceLocaleOverride;

  final LocaleStore _store;

  final bool autoDetectFromDevice;
  final Locale? _deviceLocaleOverride;

  LocaleConfig config = LocaleConfig.defaults;
  var _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    final saved = await _store.load();
    if (saved != null) {
      config = saved;
    } else if (autoDetectFromDevice) {
      config = DeviceLocaleResolver.resolve(
        deviceLocale: _deviceLocaleOverride,
      );
      unawaited(_store.save(config));
    }
    _initialized = true;
    notifyListeners();
  }

  void apply(LocaleConfig next) {
    if (config.regionId == next.regionId &&
        config.languageCode == next.languageCode) {
      return;
    }
    config = next;
    notifyListeners();
    unawaited(_store.save(config));
  }

  void setRegion(String regionId) {
    apply(config.copyWith(regionId: regionId));
  }

  void setLanguage(String languageCode) {
    apply(config.copyWith(languageCode: languageCode));
  }
}