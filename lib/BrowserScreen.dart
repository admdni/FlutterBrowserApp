import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:video_browser_app/AppLocalizations.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  String _selectedEngine = 'google';
  String _selectedMode = 'Search';
  String _backgroundImageUrl = '';
  TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _searchEngines = [
    {'name': 'google', 'icon': 'https://www.google.com/favicon.ico'},
    {'name': 'bing', 'icon': 'https://www.bing.com/favicon.ico'},
    {'name': 'yahoo', 'icon': 'https://www.yahoo.com/favicon.ico'},
    {'name': 'duckduckgo', 'icon': 'https://duckduckgo.com/favicon.ico'},
    {'name': 'baidu', 'icon': 'https://www.baidu.com/favicon.ico'},
    {'name': 'yandex', 'icon': 'https://yandex.com/favicon.ico'},
    {'name': 'ecosia', 'icon': 'https://www.ecosia.org/favicon.ico'},
    {'name': 'ask', 'icon': 'https://www.ask.com/favicon.ico'},
    {'name': 'reddit', 'icon': 'https://www.reddit.com/favicon.ico'},
  ];

  final List<String> _popularSearches = [
    'bitcoin',
    'ethereum',
    'cryptocurrency',
    'stock_market',
    'blockchain',
    'nfts',
    'defi',
    'web3'
  ];

  void _onSearchEngineSelected(String engine) {
    setState(() {
      _selectedEngine = engine;
      _searchController.text = "$_selectedEngine selected: ";
    });
  }

  void _onSearchSubmitted() {
    String query = _searchController.text
        .replaceAll('$_selectedEngine selected: ', '')
        .trim();

    if (_selectedMode == 'URL') {
      if (Uri.parse(query).isAbsolute) {
        if (!query.startsWith('https://')) {
          _showHttpWarningPopup(query);
        } else {
          // URL WebView'e yönlendir
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context).translate('invalid_url')!)),
        );
      }
    } else {
      String searchUrl = 'https://www.google.com/search?q=$query';
      if (_selectedEngine == 'bing') {
        searchUrl = 'https://www.bing.com/search?q=$query';
      } else if (_selectedEngine == 'yahoo') {
        searchUrl = 'https://search.yahoo.com/search?p=$query';
      } else if (_selectedEngine == 'duckduckgo') {
        searchUrl = 'https://duckduckgo.com/?q=$query';
      } else if (_selectedEngine == 'baidu') {
        searchUrl = 'https://www.baidu.com/s?wd=$query';
      } else if (_selectedEngine == 'yandex') {
        searchUrl = 'https://yandex.com/search/?text=$query';
      } else if (_selectedEngine == 'ecosia') {
        searchUrl = 'https://www.ecosia.org/search?q=$query';
      } else if (_selectedEngine == 'ask') {
        searchUrl = 'https://www.ask.com/web?q=$query';
      } else if (_selectedEngine == 'reddit') {
        searchUrl = 'https://www.reddit.com/search/?q=$query';
      }

      // WebView sayfasına yönlendirme işlemi yapılabilir.
    }
  }

  void _showHttpWarningPopup(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('warning')!),
          content:
              Text(AppLocalizations.of(context).translate('http_warning')!),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Pop-up'ı kapat
              },
              child: Text(
                  AppLocalizations.of(context).translate('do_not_accept')!),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Pop-up'ı kapat
                // URL WebView'e yönlendir
              },
              child:
                  Text(AppLocalizations.of(context).translate('accept_risks')!),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchRandomBackgroundImage() async {
    final response = await http.get(Uri.parse(
        'https://api.unsplash.com/photos/random?client_id=0LlqmaPhM2j4BeFuTjAE5KabZhTpc1TlgNdAzBJEKEk'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _backgroundImageUrl = data['urls']['regular'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRandomBackgroundImage();
  }

  void _onPopularSearchTap(String searchTerm) {
    setState(() {
      _searchController.text = searchTerm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).translate('title')!,
            style: TextStyle(color: Colors.white, fontSize: 24)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(_backgroundImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: _selectedMode == 'URL'
                              ? AppLocalizations.of(context)
                                  .translate('enter_url')!
                              : AppLocalizations.of(context)
                                  .translate('search_placeholder')!,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                        ),
                        onChanged: (query) =>
                            setState(() => _searchQuery = query),
                        onSubmitted: (value) => _onSearchSubmitted(),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedMode,
                        onChanged: (mode) =>
                            setState(() => _selectedMode = mode ?? 'Search'),
                        items: ['Search', 'URL']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        underline: Container(),
                        icon: Icon(Icons.arrow_drop_down),
                        dropdownColor: Colors.blue[100],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: _onSearchSubmitted,
                      child: Text(
                          AppLocalizations.of(context).translate('search')!),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 40.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _popularSearches.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () =>
                              _onPopularSearchTap(_popularSearches[index]),
                          child: Text(AppLocalizations.of(context)
                              .translate(_popularSearches[index])!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _searchEngines.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => _onSearchEngineSelected(
                            _searchEngines[index]['name']!),
                        child: Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          shadowColor: Colors.black54,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CachedNetworkImage(
                                imageUrl: _searchEngines[index]['icon']!,
                                width: 48,
                                height: 48,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)
                                    .translate(_searchEngines[index]['name']!)!,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
