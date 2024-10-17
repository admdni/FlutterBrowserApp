import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_browser_app/AppLocalizations.dart'; // Çeviri dosyası import edildi

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _photos = [];
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = false;
  String? _userName; // Kullanıcı adını burada tutacağız

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
    _loadUserName(); // Kullanıcı adını yükle
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User'; // Kullanıcı adı
    });
  }

  Future<void> _loadFavorites() async {
    await _loadFavoritePhotos();
    await _loadFavoriteVideos();
  }

  Future<void> _loadFavoritePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritePhotoIds = prefs.getStringList('favorite_photo_ids') ?? [];

    if (favoritePhotoIds.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final url = 'https://api.pexels.com/v1/search?query=Nature&per_page=20';
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization':
            'ecekop4aP9FV3IJU1Wty1SW7cBL5bPy3BBEJLcSJIPlBkdOMeryROjGx',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> photos =
            data['photos'].map<Map<String, dynamic>>((photo) {
          return {
            'id': photo['id'] ?? 0,
            'url': photo['src']['medium'] ?? '',
            'photographer': photo['photographer'] ?? 'Unknown',
            'originalUrl': photo['src']['original'] ?? '',
          };
        }).toList();

        setState(() {
          _photos = photos
              .where(
                  (photo) => favoritePhotoIds.contains(photo['id'].toString()))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error fetching photos: ${response.reasonPhrase}');
      }
    }
  }

  Future<void> _loadFavoriteVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteVideoIds = prefs.getStringList('favorite_video_ids') ?? [];

    if (favoriteVideoIds.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final url =
          'https://api.pexels.com/videos/search?query=Nature&per_page=20';
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization':
            'ecekop4aP9FV3IJU1Wty1SW7cBL5bPy3BBEJLcSJIPlBkdOMeryROjGx',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> videos =
            data['videos'].map<Map<String, dynamic>>((video) {
          return {
            'id': video['id'] ?? 0,
            'videoUrl': video['video_files'][0]['link'] ?? '',
            'user': video['user']['name'] ?? 'Anonymous',
            'thumbnail': video['image'] ?? '',
          };
        }).toList();

        setState(() {
          _videos = videos
              .where(
                  (video) => favoriteVideoIds.contains(video['id'].toString()))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error fetching videos: ${response.reasonPhrase}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${appLocalization.translate('hello')}, $_userName'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: appLocalization.translate('photos')),
            Tab(text: appLocalization.translate('videos')),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildPhotoGrid(),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildVideoGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoDetailScreen(
                      photo: photo,
                      onShare: _sharePhoto,
                      onDownload: _downloadPhoto,
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
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _removePhotoFromFavorites(photo);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVideoGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoDetailScreen(video: video),
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
                    video['thumbnail'],
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
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _removeVideoFromFavorites(video);
                },
              ),
            ),
          ],
        );
      },
    );
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
                .translate('photo_downloaded_success')!)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context).translate('photo_download_failed')}: $e')),
      );
    }
  }

  Future<void> _removePhotoFromFavorites(Map<String, dynamic> photo) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritePhotoIds = prefs.getStringList('favorite_photo_ids') ?? [];
    favoritePhotoIds.remove(photo['id'].toString());
    await prefs.setStringList('favorite_photo_ids', favoritePhotoIds);

    setState(() {
      _photos.remove(photo);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('photo_removed_from_favorites')!)),
    );
  }

  Future<void> _removeVideoFromFavorites(Map<String, dynamic> video) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteVideoIds = prefs.getStringList('favorite_video_ids') ?? [];
    favoriteVideoIds.remove(video['id'].toString());
    await prefs.setStringList('favorite_video_ids', favoriteVideoIds);

    setState(() {
      _videos.remove(video);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('video_removed_from_favorites')!)),
    );
  }
}

class PhotoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> photo;
  final Function(String) onShare;
  final Function(String) onDownload;

  PhotoDetailScreen({
    required this.photo,
    required this.onShare,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalization.translate('photo_detail')!),
      ),
      body: Column(
        children: [
          Image.network(
            photo['url'],
            fit: BoxFit.cover,
            height: 300,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${appLocalization.translate('photographer')}: ${photo['photographer']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => onShare(photo['originalUrl']),
                child: Text(appLocalization.translate('share')!),
              ),
              ElevatedButton(
                onPressed: () => onDownload(photo['originalUrl']),
                child: Text(appLocalization.translate('download')!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VideoDetailScreen extends StatefulWidget {
  final Map<String, dynamic> video;

  VideoDetailScreen({required this.video});

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.video['videoUrl'])
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalization.translate('video_detail')!),
      ),
      body: Center(
        child: Column(
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
