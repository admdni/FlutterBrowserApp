import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsOfC extends StatefulWidget {
  @override
  _TermsOfCState createState() => _TermsOfCState();
}

class _TermsOfCState extends State<TermsOfC> {
  String _privacyPolicyText = '';

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    final privacyPolicyText =
        await rootBundle.loadString('assets/terms_of_users.txt');
    setState(() {
      _privacyPolicyText = privacyPolicyText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          _privacyPolicyText,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
