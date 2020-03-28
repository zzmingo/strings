import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:strings/i10n/localization_intl.dart';
import 'package:strings/model/fretboard.dart';
import 'package:strings/model/settings.dart';
import 'package:strings/model/tuner.dart';
import 'package:strings/view/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var settingsModel = SettingsModel();
  var tunerModel = TunerModel(settingsModel);
  await tunerModel.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => settingsModel),
        ChangeNotifierProvider(create: (context) => tunerModel),
        ChangeNotifierProvider(create: (context) => FretboardModel()),
      ],
        child: StringsApp(),
      )
  );
}

class StringsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appBarTheme = AppBarTheme(
      brightness: Brightness.dark,
      color: Color(0xFF131313),
    );
    return MaterialApp(
      title: 'Strings',
      theme: ThemeData(
        appBarTheme: appBarTheme,
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
      ),
      darkTheme: ThemeData(
        appBarTheme: appBarTheme,
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
      ),
      home: HomePage(),
      localizationsDelegates: [
        // 本地化的代理类
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        StringsLocalizationsDelegate(),
      ],
      supportedLocales: [
        const Locale('en', 'US'), // 美国英语
        const Locale('zh', 'CN'), // 中文简体
      ],
    );
  }
}