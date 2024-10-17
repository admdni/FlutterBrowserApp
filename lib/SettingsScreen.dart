import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_browser_app/PrivacyPolicy.dart';
import 'package:video_browser_app/TermsOfC.dart';
import 'package:video_browser_app/main.dart';
import 'package:video_browser_app/AppLocalizations.dart'; // Çeviri için import

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkTheme = false;
  String? _userName;
  String? _selectedLanguage = 'en'; // Varsayılan dil İngilizce
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadUserName();
    _loadLanguage(); // Kaydedilen dili yükle
  }

  Future<void> _loadTheme() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      _isDarkTheme = savedThemeMode == AdaptiveThemeMode.dark;
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  Future<void> _saveUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
    setState(() {
      _userName = newName;
    });
  }

  Future<void> _saveTheme(bool value) async {
    if (value) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
  }

  Future<void> _deleteCaches() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('caches_deleted')!)),
    );
  }

  Future<void> _deleteFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favorite_photo_ids');
    await prefs.remove('favorite_video_ids');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('favorites_deleted')!)),
    );
  }

  Future<void> _rateApp() async {
    const appId = '6670561070';
    final url = 'https://apps.apple.com/app/6670561070?action=write-review';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('rate_app_error')!)),
      );
    }
  }

  Future<void> _exitApp() async {
    bool confirmExit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('exit_app')!),
        content: Text(AppLocalizations.of(context).translate('confirm_exit')!),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context).translate('cancel')!),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(AppLocalizations.of(context).translate('exit')!),
            onPressed: () => exit(0),
          ),
        ],
      ),
    );
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
    });
  }

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('language_changed_to')! +
                  languageCode)),
    );

    // Uygulamanın dil değişikliği sonrasında yeniden başlaması
    MyApp.setLocale(context, Locale(languageCode));
  }

  void _showLanguageSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('select_language')!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text(AppLocalizations.of(context).translate('english')!),
                onTap: () {
                  _saveLanguage('en');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).translate('chinese')!),
                onTap: () {
                  _saveLanguage('zh');
                  Navigator.of(context).pop();
                },
              ),
              // Diğer diller buraya eklenebilir...
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditNameDialog() async {
    _nameController.text = _userName ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('change_info')!),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate('enter_new_name')!),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).translate('cancel')!),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).translate('save')!),
              onPressed: () {
                _saveUserName(_nameController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context)
                          .translate('name_changed_success')!)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings')!),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  '${AppLocalizations.of(context).translate('hello')} $_userName',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 10),
                Image.asset(
                  'assets/logo.png',
                  height: 100,
                ),
                SizedBox(height: 10),
                Text(
                  '${AppLocalizations.of(context).translate('version')} 1.0.0',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            title: Text(
                AppLocalizations.of(context).translate('light_dark_theme')!),
            trailing: Switch(
              value: _isDarkTheme,
              onChanged: (value) {
                setState(() {
                  _isDarkTheme = value;
                  _saveTheme(value);
                });
              },
            ),
          ),
          ListTile(
            title:
                Text(AppLocalizations.of(context).translate('privacy_policy')!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            title:
                Text(AppLocalizations.of(context).translate('delete_caches')!),
            onTap: _deleteCaches,
          ),
          ListTile(
            title: Text(
                AppLocalizations.of(context).translate('delete_favorites')!),
            onTap: _deleteFavorites,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).translate('change_info')!),
            onTap: _showEditNameDialog,
          ),
          ListTile(
            title: Text(
                AppLocalizations.of(context).translate('terms_conditions')!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsOfC()),
              );
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).translate('exit_app')!),
            onTap: _exitApp,
          ),
          ListTile(
            title: Text(
                AppLocalizations.of(context).translate('change_language')!),
            onTap: _showLanguageSelection,
          ),
        ],
      ),
    );
  }
}
