import "dart:developer";
import "dart:io";

import "package:app_settings/app_settings.dart";
import "package:flow/data/upcoming_transactions.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/main.dart";
import "package:flow/prefs.dart";
import "package:flow/routes/preferences/language_selection_sheet.dart";
import "package:flow/routes/preferences/theme_selection_sheet.dart";
import "package:flow/widgets/select_currency_sheet.dart";
import "package:flutter/material.dart" hide Flow;
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool _themeBusy = false;
  bool _currencyBusy = false;
  bool _languageBusy = false;

  @override
  Widget build(BuildContext context) {
    final ThemeMode currentThemeMode = Flow.of(context).themeMode;

    final UpcomingTransactionsDuration homeTabPlannedTransactionsDuration =
        LocalPreferences().homeTabPlannedTransactionsDuration.get() ??
            LocalPreferences.homeTabPlannedTransactionsDurationDefault;


    return Scaffold(
      appBar: AppBar(
        title: Text("preferences".t(context)),
      ),
      body: SafeArea(
        child: ListView(children: [
          ListTile(
            title: Text("preferences.home.upcoming".t(context)),
            subtitle: Text(
              homeTabPlannedTransactionsDuration.localizedNameContext(context),
            ),
            leading: const Icon(Symbols.hourglass_top_rounded),
            onTap: openHomeTabPrefs,
            // subtitle: Text(FlowLocalizations.of(context).locale.endonym),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.themeMode".t(context)),
            leading: switch (currentThemeMode) {
              ThemeMode.system => const Icon(Symbols.routine_rounded),
              ThemeMode.dark => const Icon(Symbols.dark_mode_rounded),
              ThemeMode.light => const Icon(Symbols.light_mode_rounded),
            },
            subtitle: Text(switch (currentThemeMode) {
              ThemeMode.system => "preferences.themeMode.system".t(context),
              ThemeMode.dark => "preferences.themeMode.dark".t(context),
              ThemeMode.light => "preferences.themeMode.light".t(context),
            }),
            onTap: () => updateTheme(),
            onLongPress: () => updateTheme(ThemeMode.system),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.language".t(context)),
            leading: const Icon(Symbols.language_rounded),
            onTap: () => updateLanguage(),
            subtitle: Text(FlowLocalizations.of(context).locale.endonym),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.primaryCurrency".t(context)),
            leading: const Icon(Symbols.universal_currency_alt_rounded),
            onTap: () => updatePrimaryCurrency(),
            subtitle: Text(LocalPreferences().getPrimaryCurrency()),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.numpad".t(context)),
            leading: const Icon(Symbols.dialpad_rounded),
            onTap: openNumpadPrefs,
            subtitle: Text(
              LocalPreferences().usePhoneNumpadLayout.get()
                  ? "preferences.numpad.layout.modern".t(context)
                  : "preferences.numpad.layout.classic".t(context),
            ),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.transfer".t(context)),
            leading: const Icon(Symbols.sync_alt_rounded),
            onTap: openTransferPrefs,
            subtitle: Text(
              "preferences.transfer.description".t(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.transactionButtonOrder".t(context)),
            leading: const Icon(Symbols.action_key_rounded),
            onTap: openTransactionButtonOrderPrefs,
            subtitle: Text(
              "preferences.transactionButtonOrder.description".t(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
        ]),
      ),
    );
  }

  void updateTheme([ThemeMode? force]) async {
    if (_themeBusy) return;

    setState(() {
      _themeBusy = true;
    });

    try {
      final ThemeMode? selected = await showModalBottomSheet<ThemeMode>(
        context: context,
        builder: (context) => ThemeSelectionSheet(
          currentTheme: Flow.of(context).themeMode,
        ),
      );

      if (selected != null) {
        await LocalPreferences().themeMode.set(selected);
      }

      if (mounted) {
        // Even tho the whole app state refreshes, it doesn't get refreshed
        // if we switch from same ThemeMode as system from ThemeMode.system.
        // So this call is necessary
        setState(() {});
      }
    } finally {
      _themeBusy = false;
    }
  }

  void updateLanguage() async {
    if (Platform.isIOS) {
      await LocalPreferences().localeOverride.remove().catchError((e) {
        log("[PreferencesPage] failed to remove locale override: $e");
        return false;
      });
      try {
        await AppSettings.openAppSettings(type: AppSettingsType.appLocale);
        return;
      } catch (e) {
        log("[PreferencesPage] failed to open system app settings on iOS: $e");
      }
    }

    if (_languageBusy || !mounted) return;

    setState(() {
      _languageBusy = true;
    });

    try {
      Locale current = LocalPreferences().localeOverride.get() ??
          FlowLocalizations.supportedLanguages.first;

      final selected = await showModalBottomSheet<Locale>(
        context: context,
        builder: (context) => LanguageSelectionSheet(
          currentLocale: current,
        ),
      );

      if (selected != null) {
        await LocalPreferences().localeOverride.set(selected);
      }
    } finally {
      _languageBusy = false;
    }
  }

  void updatePrimaryCurrency() async {
    if (_currencyBusy) return;

    setState(() {
      _currencyBusy = true;
    });

    try {
      String current = LocalPreferences().getPrimaryCurrency();

      final selected = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SelectCurrencySheet(currentlySelected: current),
      );

      if (selected != null) {
        await LocalPreferences().primaryCurrency.set(selected);
      }
    } finally {
      _currencyBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void openNumpadPrefs() async {
    await context.push("/preferences/numpad");

    // Rebuild to update description text
    if (mounted) setState(() {});
  }

  void openTransferPrefs() async {
    await context.push("/preferences/transfer");
  }

  void openHomeTabPrefs() async {
    await context.push("/preferences/home");

    // Rebuild to update description text
    if (mounted) setState(() {});
  }

  void openTransactionButtonOrderPrefs() async {
    await context.push("/preferences/transactionButtonOrder");
  }

}
