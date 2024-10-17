import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_browser_app/BrowserScreen.dart';
import 'package:video_browser_app/DiscoveryScreen.dart';
import 'package:video_browser_app/FavoriteScreen.dart';
import 'package:video_browser_app/NewsScreen.dart';
import 'package:video_browser_app/SettingsScreen.dart';
import 'package:video_browser_app/ShuffleVideos.dart';
import 'package:video_browser_app/UsersInfo.dart';
import 'package:video_browser_app/main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Uygulama SplashScreen ile başlıyor
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animasyon kontrolcüsü ve tween ayarları
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Animasyonu başlat
    _controller.forward();

    // Kullanıcı bilgilerini kontrol et ve yönlendir
    _checkUserInfo();
  }

  Future<void> _checkUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');

    // Eğer kullanıcı bilgisi kaydedilmemişse UserInfoScreen'e yönlendir
    if (userName == null) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserInfoScreen()),
        );
      });
    } else {
      // Eğer kullanıcı bilgisi varsa ana ekrana yönlendir
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Animasyon kontrolcüsünü serbest bırak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan gradyanı (değişken tonlarda mavi)
          AnimatedContainer(
            duration: Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlueAccent,
                  Colors.blueAccent,
                  Colors.blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Logo ve animasyonlu text
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/logo.png', // Kendi logonuzun yolunu ekleyin
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 20),
                  // Uygulama ismi
                  Text(
                    'PexVi App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
