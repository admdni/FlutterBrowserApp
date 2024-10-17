import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_browser_app/UrlWebview.dart'; // Uygulamanızdaki Webview ekranı

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = false;
  final String _defaultImageUrl =
      'https://fl-1.cdn.flockler.com/embed/no-image.svg'; // Varsayılan görsel URL

  @override
  void initState() {
    super.initState();
    _fetchFootballNews(); // Futbol haberlerini çekiyoruz
  }

  Future<void> _fetchFootballNews() async {
    setState(() {
      _isLoading = true;
    });

    // Futbol anahtar kelimesiyle spor haberlerini çekiyoruz
    final url =
        'https://api.currentsapi.services/v1/search?keywords=sports&category=sports&apiKey=';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, dynamic>> articles = data['news']
          .map<Map<String, dynamic>?>((article) {
            final imageUrl = article['image'];
            return {
              'title': article['title'],
              'description': article['description'],
              'url': article['url'],
              'source': article['source'],
              'imageUrl': imageUrl != null && imageUrl.isNotEmpty
                  ? imageUrl
                  : _defaultImageUrl,
              'publishedAt': article['published'],
            };
          })
          .cast<Map<String, dynamic>>()
          .toList();

      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching football news: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    SizedBox(height: 150),
                    Container(
                      height: 250,
                      child: PageView.builder(
                        itemCount:
                            _articles.length > 10 ? 10 : _articles.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final article = _articles[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UrlWebview(
                                    url: article['url'],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      article['imageUrl'],
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey,
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.white,
                                            size: 100,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    right: 10,
                                    child: Container(
                                      color: Colors.black54,
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        article['title'] ?? 'No Title',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            _articles.length > 10 ? _articles.length - 10 : 0,
                        itemBuilder: (context, index) {
                          final article = _articles[index + 10];
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  article['imageUrl'],
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey,
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              title: Text(article['title'] ?? 'No Title',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UrlWebview(
                                      url: article['url'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
