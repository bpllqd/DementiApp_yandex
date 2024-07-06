// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `SAVE`
  String get createScreenAppBarSave {
    return Intl.message(
      'SAVE',
      name: 'createScreenAppBarSave',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get createScreenDeleteButtonDelete {
    return Intl.message(
      'Delete',
      name: 'createScreenDeleteButtonDelete',
      desc: '',
      args: [],
    );
  }

  /// `What i need to do...`
  String get createScreenTextfieldLabel {
    return Intl.message(
      'What i need to do...',
      name: 'createScreenTextfieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Importance`
  String get createScreenDropDownLabel {
    return Intl.message(
      'Importance',
      name: 'createScreenDropDownLabel',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get createScreenDropdownMenuHint {
    return Intl.message(
      'No',
      name: 'createScreenDropdownMenuHint',
      desc: '',
      args: [],
    );
  }

  /// `Basic`
  String get createScreenDropdownMenuBasic {
    return Intl.message(
      'Basic',
      name: 'createScreenDropdownMenuBasic',
      desc: '',
      args: [],
    );
  }

  /// `Low`
  String get createScreenDropdownMenuLow {
    return Intl.message(
      'Low',
      name: 'createScreenDropdownMenuLow',
      desc: '',
      args: [],
    );
  }

  /// `Important`
  String get createScreenDropdownMenuImportant {
    return Intl.message(
      'Important',
      name: 'createScreenDropdownMenuImportant',
      desc: '',
      args: [],
    );
  }

  /// `Deadline`
  String get createScreenSwitchTileTitle {
    return Intl.message(
      'Deadline',
      name: 'createScreenSwitchTileTitle',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get listScreenAddNewButtonTitle {
    return Intl.message(
      'New',
      name: 'listScreenAddNewButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `Completed - {completedTasks}`
  String listScreenAppBarCompletedN(Object completedTasks) {
    return Intl.message(
      'Completed - $completedTasks',
      name: 'listScreenAppBarCompletedN',
      desc: '',
      args: [completedTasks],
    );
  }

  /// `My tasks`
  String get listScreenAppBarTitle {
    return Intl.message(
      'My tasks',
      name: 'listScreenAppBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get listScreenAppBarError {
    return Intl.message(
      'Error',
      name: 'listScreenAppBarError',
      desc: '',
      args: [],
    );
  }

  /// `Got internet connection!`
  String get listScreenListWidgetOnline {
    return Intl.message(
      'Got internet connection!',
      name: 'listScreenListWidgetOnline',
      desc: '',
      args: [],
    );
  }

  /// `Lost internet connection :(`
  String get listScreenListWidgetOfline {
    return Intl.message(
      'Lost internet connection :(',
      name: 'listScreenListWidgetOfline',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
