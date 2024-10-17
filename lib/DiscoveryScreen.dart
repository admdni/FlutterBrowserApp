import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_browser_app/AppLocalizations.dart'; // Çeviri dosyası import edildi

class DiscoveryScreen extends StatefulWidget {
  @override
  _DiscoveryScreenState createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List<String> _categories = [
    'Nature',
    'Animals',
    'People',
    'Technology',
    'Food',
    'Travel',
    'Fashion'
  ];
  List<Map<String, dynamic>> _photos = [];
  int _currentCategoryIndex = 0;
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPhotosByCategory(_categories[_currentCategoryIndex]);
  }

  Future<void> _fetchPhotosByCategory(String category) async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://api.pexels.com/v1/search?query=$category&per_page=20';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': '',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, dynamic>> photos = List<Map<String, dynamic>>.from(
        data['photos'].map<Map<String, dynamic>>((photo) {
          return {
            'id': photo['id'],
            'url': photo['src']['medium'],
            'photographer': photo['photographer'],
            'originalUrl': photo['src']['original'],
          };
        }).toList(),
      );

      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Error: ${response.reasonPhrase}');
    }
  }

  Future<void> _searchPhotos(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final url = 'https://api.pexels.com/v1/search?query=$query&per_page=20';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization':
          'ecekop4aP9FV3IJU1Wty1SW7cBL5bPy3BBEJLcSJIPlBkdOMeryROjGx',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, dynamic>> photos = List<Map<String, dynamic>>.from(
        data['photos'].map<Map<String, dynamic>>((photo) {
          return {
            'id': photo['id'],
            'url': photo['src']['medium'],
            'photographer': photo['photographer'],
            'originalUrl': photo['src']['original'],
          };
        }).toList(),
      );

      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Error: ${response.reasonPhrase}');
    }
  }

  void _onCategorySelected(int index) {
    setState(() {
      _currentCategoryIndex = index;
    });
    _fetchPhotosByCategory(_categories[index]);
  }

  Future<void> _sharePhoto(String url) async {
    final tempDir = await getTemporaryDirectory();
    final file = await ImageDownloader.downloadImage(url,
        destination: AndroidDestinationType.directoryPictures);
    if (file != null) {
      final filePath = '${tempDir.path}/${file}';
      await Share.shareXFiles([XFile(filePath)], text: 'Check out this photo!');
    }
  }

  Future<void> _downloadPhoto(String url) async {
    try {
      await ImageDownloader.downloadImage(url,
          destination: AndroidDestinationType.directoryPictures);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                    ?.translate('photo_downloaded_success') ??
                'Downloaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                    ?.translate('photo_download_failed') ??
                'Download failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(96.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: appLocalization?.translate('search_photos') ??
                        'Search for photos',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onSubmitted: (query) {
                    _searchPhotos(query);
                  },
                ),
              ),
              SizedBox(height: 10),
              _isLoading
                  ? Expanded(child: Center(child: CircularProgressIndicator()))
                  : Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          final photo = _photos[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoDetailScreen(
                                    photo: photo,
                                    onShare: _sharePhoto,
                                    onDownload: _downloadPhoto,
                                    category:
                                        _categories[_currentCategoryIndex],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  photo['url'],
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
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

class PhotoDetailScreen extends StatefulWidget {
  final Map<String, dynamic> photo;
  final Function(String) onShare;
  final Function(String) onDownload;
  final String category;

  PhotoDetailScreen({
    required this.photo,
    required this.onShare,
    required this.onDownload,
    required this.category,
  });

  @override
  _PhotoDetailScreenState createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  bool _isFavorite = false;
  List<Map<String, dynamic>> _relatedPhotos = [];

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _fetchRelatedPhotos(); // İlgili fotoğrafları getir
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_photo_ids') ?? [];
    setState(() {
      _isFavorite = favoriteIds.contains(widget.photo['id'].toString());
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_photo_ids') ?? [];
    final photoId = widget.photo['id'].toString();

    if (_isFavorite) {
      favoriteIds.remove(photoId);
    } else {
      favoriteIds.add(photoId);
    }

    await prefs.setStringList('favorite_photo_ids', favoriteIds);
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<void> _fetchRelatedPhotos() async {
    final url =
        'https://api.pexels.com/v1/search?query=${widget.category}&per_page=5';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization':
          'ecekop4aP9FV3IJU1Wty1SW7cBL5bPy3BBEJLcSJIPlBkdOMeryROjGx',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, dynamic>> photos = List<Map<String, dynamic>>.from(
        data['photos'].map<Map<String, dynamic>>((photo) {
          return {
            'id': photo['id'],
            'url': photo['src']['medium'],
            'photographer': photo['photographer'],
            'originalUrl': photo['src']['original'],
          };
        }).toList(),
      );

      setState(() {
        _relatedPhotos = photos;
      });
    } else {
      print('Error fetching related photos: ${response.reasonPhrase}');
    }
  }

  void _showFullScreenImage() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.network(
              widget.photo['url'],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(appLocalization?.translate('photo_detail') ?? 'Photo Detail'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: _showFullScreenImage,
            child: Image.network(
              widget.photo['url'],
              fit: BoxFit.cover,
              height: 300,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${appLocalization?.translate('photographer') ?? 'Photographer'}: ${widget.photo['photographer']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => widget.onShare(widget.photo['originalUrl']),
                child: Text(appLocalization?.translate('share') ?? 'Share'),
              ),
              ElevatedButton(
                onPressed: () => widget.onDownload(widget.photo['originalUrl']),
                child:
                    Text(appLocalization?.translate('download') ?? 'Download'),
              ),
              ElevatedButton(
                onPressed: _toggleFavorite,
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            appLocalization?.translate('related_photos') ?? 'Related Photos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _relatedPhotos.length,
              itemBuilder: (context, index) {
                final relatedPhoto = _relatedPhotos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoDetailScreen(
                          photo: relatedPhoto,
                          onShare: widget.onShare,
                          onDownload: widget.onDownload,
                          category: widget.category,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      relatedPhoto['url'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey,
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
