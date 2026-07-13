import 'package:perccent_wallet/providers/locale_provider.dart';
import 'package:perccent_wallet/wallet_core/services/locale_store_memory.dart';

Future<LocaleProvider> createTestLocaleProvider() async {
  final locale = LocaleProvider(
    store: LocaleStoreMemory(),
    autoDetectFromDevice: false,
  );
  await locale.initialize();
  return locale;
}