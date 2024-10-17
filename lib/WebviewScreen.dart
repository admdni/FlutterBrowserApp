import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String initialUrl;

  WebViewScreen({required this.initialUrl});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Progress bar can be updated here.
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
            // Control back/forward button states
            bool canGoBack = await _controller.canGoBack();
            bool canGoForward = await _controller.canGoForward();
            setState(() {
              _canGoBack = canGoBack;
              _canGoForward = canGoForward;
            });
          },
          onHttpError: (HttpResponseError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('HTTP error: ')),
            );
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${error.description}')),
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          _isLoading ? Center(child: CircularProgressIndicator()) : Container(),
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
            onPressed: _canGoBack
                ? () async {
                    if (await _controller.canGoBack()) {
                      _controller.goBack();
                    }
                  }
                : null, // Disable if cannot go back
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: _canGoForward
                ? () async {
                    if (await _controller.canGoForward()) {
                      _controller.goForward();
                    }
                  }
                : null, // Disable if cannot go forward
          ),
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              _controller.loadRequest(Uri.parse(widget.initialUrl));
            },
          ),
        ],
      ),
    );
  }
}
