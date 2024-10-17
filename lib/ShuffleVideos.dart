import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_browser_app/AppLocalizations.dart'; // Çeviri dosyası import edildi

class ShuffleVideosScreen extends StatefulWidget {
  @override
  _ShuffleVideosScreenState createState() => _ShuffleVideosScreenState();
}

class _ShuffleVideosScreenState extends State<ShuffleVideosScreen> {
  List<String> _categories = [
    'Nature',
    'News',
    'Foods',
    'Art',
    'Comedy',
    'Movies',
    'Games',
    'Animals',
    'People',
    'Technology'
  ];
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = false;
  int _currentVideoIndex = 0;
  Set<String> _likedVideos = {};
  bool _showControls = false;
  bool _isMuted = false;
  Timer? _hideControlsTimer;
  final Random _random = Random();

  VideoPlayerController? _videoController;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _fetchRandomCategoryVideos();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadLikedVideos();
  }

  void _loadLikedVideos() {
    final likedVideos = _prefs.getStringList('favorite_video_ids') ?? [];
    setState(() {
      _likedVideos = likedVideos.toSet();
    });
  }

  void _saveLikedVideos() {
    _prefs.setStringList('favorite_video_ids', _likedVideos.toList());
  }

  Future<void> _fetchVideosByCategory(String category) async {
    setState(() {
      _isLoading = true;
    });

    final url =
        'https://api.pexels.com/videos/search?query=$category&per_page=10';
    final response =
        await http.get(Uri.parse(url), headers: {'Authorization': ''});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, dynamic>> videos = List<Map<String, dynamic>>.from(
        data['videos'].map<Map<String, dynamic>>((video) {
          return {
            'videoUrl': video['video_files'][0]['link'].toString(),
            'user': video['user']['name'],
            'duration': video['duration'],
            'videoId': video['id'].toString(),
          };
        }).toList(),
      );

      videos.shuffle(_random);

      setState(() {
        _videos = videos;
        _isLoading = false;
      });

      _initializeVideoPlayer(_videos[0]['videoUrl']);
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Error: ${response.reasonPhrase}');
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    if (_videoController != null) {
      _videoController!.dispose();
    }

    _videoController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _videoController!.setLooping(true);
        _videoController!.play();
      });
  }

  void _toggleLike(String videoId) {
    setState(() {
      if (_likedVideos.contains(videoId)) {
        _likedVideos.remove(videoId);
      } else {
        _likedVideos.add(videoId);
      }
    });
    _saveLikedVideos();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _videoController!.setVolume(0);
      } else {
        _videoController!.setVolume(1);
      }
    });
  }

  Future<void> _fetchRandomCategoryVideos() async {
    final randomCategory = _categories[_random.nextInt(_categories.length)];
    await _fetchVideosByCategory(randomCategory);
  }

  Future<void> _fetchRecommendedVideos() async {
    final recommendedCategory = 'People';
    await _fetchVideosByCategory(recommendedCategory);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onTap: _toggleControls,
                  child: PageView.builder(
                    itemCount: _videos.length,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) {
                      setState(() {
                        _currentVideoIndex = index;
                      });
                      _initializeVideoPlayer(_videos[index]['videoUrl']);
                    },
                    itemBuilder: (context, index) {
                      final videoInfo = _videos[index];
                      final isLiked =
                          _likedVideos.contains(videoInfo['videoId']);
                      return Stack(
                        children: [
                          _videoController != null &&
                                  _videoController!.value.isInitialized
                              ? SizedBox.expand(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _videoController!.value.size.width,
                                      height:
                                          _videoController!.value.size.height,
                                      child: VideoPlayer(_videoController!),
                                    ),
                                  ),
                                )
                              : Center(child: CircularProgressIndicator()),
                          if (_showControls) ...[
                            Center(
                              child: IconButton(
                                iconSize: 80,
                                color: Colors.white,
                                icon: Icon(
                                  _videoController != null &&
                                          _videoController!.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_videoController!.value.isPlaying) {
                                      _videoController!.pause();
                                    } else {
                                      _videoController!.play();
                                    }
                                  });
                                  _startHideControlsTimer();
                                },
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 10,
                              child: IconButton(
                                icon: Icon(
                                  _isMuted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: _toggleMute,
                              ),
                            ),
                          ],
                          Positioned(
                            right: 10,
                            bottom: 80,
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    _toggleLike(videoInfo['videoId']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.share,
                                      color: Colors.white, size: 40),
                                  onPressed: () {
                                    Share.share(videoInfo['videoUrl']);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 50,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${appLocalization.translate('uploader')}: ${videoInfo['user']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${appLocalization.translate('duration')}: ${videoInfo['duration']} ${appLocalization.translate('seconds')}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _fetchRandomCategoryVideos,
                    child: Text(appLocalization.translate('collection')!),
                  ),
                  ElevatedButton(
                    onPressed: _fetchRecommendedVideos,
                    child: Text(appLocalization.translate('recommended')!),
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
