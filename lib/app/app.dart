import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class SalonAdminApp extends ConsumerWidget {
  const SalonAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);
    final locale = ref.watch(languageProvider);
    return MaterialApp.router(
      title: 'Lushe Admin',
      debugShowCheckedModeBanner: false,
      theme: buildAdminTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
