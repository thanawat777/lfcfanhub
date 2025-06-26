import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebViewPage extends StatefulWidget {
  final String url;

  const MyWebViewPage({super.key, required this.url});

  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  late final WebViewController _controller;
  String currentUrl = "Loading...";

  // ฟังก์ชันแปลง URL ให้เป็น https:// ถ้ายังไม่มี
  String normalizeUrl(String url) {
    if (!url.startsWith("http")) {
      return "https://$url";
    } else {
      return url;
    }

    //print(url);
  }

  @override
  void initState() {
    super.initState();
    final String fixedUrl = normalizeUrl(widget.url);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (fixedUrl) {
            setState(() {
              currentUrl = fixedUrl;
            });
          },
          onPageFinished: (fixedUrl) {
            setState(() {
              currentUrl = fixedUrl;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(fixedUrl)); // ✅ โหลด URL ที่ถูกแปลงแล้ว
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Liverpool News",
          style: TextStyle(color: Colors.white),
        ),

        backgroundColor: Colors.red,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
