import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UrlWebview extends StatefulWidget {
  final String url;

  UrlWebview({required this.url});

  @override
  _UrlWebviewState createState() => _UrlWebviewState();
}

class _UrlWebviewState extends State<UrlWebview> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Yükleme ilerleme durumu isteğe bağlı
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true; // Sayfa yüklenirken gösterge
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false; // Sayfa yüklendiğinde göstergeyi gizle
            });
          },
          onHttpError: (HttpResponseError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('HTTP Error: ${error}')),
            );
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${error.description}')),
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision
                  .prevent; // YouTube bağlantılarını engelle
            }
            return NavigationDecision.navigate; // Diğer bağlantılar için devam
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url)); // Başlangıç URL'sini yükle
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _controller.runJavaScript(
        'document.body.style.filter = "${_isDarkMode ? 'invert(1)' : 'invert(0)'}";');
  }

  // Zoom işlemini JavaScript ile uygula
  void _zoomIn() {
    _controller.runJavaScript("document.body.style.zoom = '150%';");
  }

  void _zoomOut() {
    _controller.runJavaScript("document.body.style.zoom = '100%';");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8.0), // Kenar boşlukları
          decoration: BoxDecoration(
            color: Colors.blue, // Arka plan rengi
            borderRadius: BorderRadius.circular(8.0), // Köşe yuvarlama
          ),
          child: SizedBox(
            width: 48, // Buton genişliği
            height: 48, // Buton yüksekliği
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Geri git
              },
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8.0), // Kenar boşlukları
            decoration: BoxDecoration(
              color: Colors.blue, // Arka plan rengi
              borderRadius: BorderRadius.circular(8.0), // Köşe yuvarlama
            ),
            child: SizedBox(
              width: 48, // Buton genişliği
              height: 48, // Buton yüksekliği
              child: IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  _controller.reload(); // Sayfayı yenile
                },
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar:
          true, // AppBar'ı şeffaf yaparak vücudun arkasına genişletir
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: WebViewWidget(controller: _controller), // WebView içeriği
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator()) // Yükleme göstergesi
              : Container(), // Yüklendikten sonra gizle
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                _controller.goBack(); // Geri git
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                _controller.goForward(); // İleri git
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: _zoomIn, // Zoom yap (büyüt)
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: _zoomOut, // Zoom yap (küçült)
          ),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleDarkMode, // Karanlık/Açık temayı değiştir
          ),
        ],
      ),
    );
  }
}
