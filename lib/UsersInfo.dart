import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_browser_app/BrowserScreen.dart'; // Ana sayfa

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  String _selectedContent = 'Photo'; // Varsayılan içerik seçimi
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Animasyon kontrolcüsü
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward(); // Animasyonu başlat
  }

  @override
  void dispose() {
    _controller.dispose(); // AnimationController'ı serbest bırak
    super.dispose();
  }

  Future<void> _saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('contentPreference', _selectedContent);

    // Bilgi kaydedildikten sonra ana sayfaya yönlendir
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan için mavi tonlarda gradyant
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade200,
                  Colors.blue.shade500,
                  Colors.blue.shade800,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeInAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40), // Yukarıdan boşluk
                    // Başlık
                    Center(
                      child: Text(
                        'Welcome to PexVi App',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Beyaz yazı rengi
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Kullanıcı adı girişi
                    TextField(
                      controller: _nameController,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Enter Your Name',
                        labelStyle:
                            TextStyle(fontSize: 18, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                        filled: true,
                        fillColor: Colors.blue[100]?.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: 30),

                    // İçerik tercihi başlığı
                    Text(
                      'What type of content are you interested in?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),

                    // İçerik tercihi seçenekleri
                    RadioListTile<String>(
                      title:
                          Text('Photo', style: TextStyle(color: Colors.white)),
                      value: 'Photo',
                      groupValue: _selectedContent,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedContent = value!;
                        });
                      },
                      activeColor: Colors.white,
                    ),
                    RadioListTile<String>(
                      title:
                          Text('Video', style: TextStyle(color: Colors.white)),
                      value: 'Video',
                      groupValue: _selectedContent,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedContent = value!;
                        });
                      },
                      activeColor: Colors.white,
                    ),
                    RadioListTile<String>(
                      title: Text('Browser',
                          style: TextStyle(color: Colors.white)),
                      value: 'Browser',
                      groupValue: _selectedContent,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedContent = value!;
                        });
                      },
                      activeColor: Colors.white,
                    ),

                    SizedBox(height: 40),

                    // Kaydet butonu
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveUserInfo,
                        child: Text(
                          'Save',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          backgroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
