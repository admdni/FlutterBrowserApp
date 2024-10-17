import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:video_browser_app/AppLocalizations.dart';
import 'package:video_browser_app/BrowserScreen.dart';
import 'package:video_browser_app/DiscoveryScreen.dart';
import 'package:video_browser_app/FavoriteScreen.dart';
import 'package:video_browser_app/NewsScreen.dart';
import 'package:video_browser_app/SettingsScreen.dart';
import 'package:video_browser_app/ShuffleVideos.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:video_browser_app/SplashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
      ),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        theme: theme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        locale: _locale, // Dil değişikliği burada kontrol edilir
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate, // MaterialLocalizations eklendi
          GlobalWidgetsLocalizations.delegate, // WidgetsLocalizations eklendi
          GlobalCupertinoLocalizations.delegate // iOS yerelleştirmeleri
        ],
        supportedLocales: [
          const Locale('en', ''), // İngilizce
          const Locale('zh', ''), // Çince
        ],
        home: SplashScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    SearchScreen(),
    NewsScreen(),
    ShuffleVideosScreen(),
    DiscoveryScreen(),
    FavoriteScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: MotionTabBar(
        labels: [
          appLocalization.translate('browser') ?? "Browser", // Tarayıcı
          appLocalization.translate('news') ?? "News", // Haberler
          appLocalization.translate('shuffle') ?? "Shuffle", // Rastgele
          appLocalization.translate('discover') ?? "Discover", // Keşfet
          appLocalization.translate('favorites') ?? "Favorites", // Favoriler
          appLocalization.translate('settings') ?? "Settings" // Ayarlar
        ],
        initialSelectedTab: appLocalization.translate('browser') ?? "Browser",
        tabIconColor: Colors.blue,
        tabSelectedColor: Colors.red,
        onTabItemSelected: (int value) {
          setState(() {
            _currentIndex = value;
          });
        },
        icons: [
          Icons.browser_updated_sharp,
          Icons.newspaper,
          Icons.shuffle,
          Icons.explore,
          Icons.favorite,
          Icons.settings
        ],
        textStyle: TextStyle(color: Colors.blue),
      ),
    );
  }
}
