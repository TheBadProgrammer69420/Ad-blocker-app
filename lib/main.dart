
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AdBlockBrowser(),
    );
  }
}

class AdBlockBrowser extends StatefulWidget {
  @override
  _AdBlockBrowserState createState() => _AdBlockBrowserState();
}

class _AdBlockBrowserState extends State<AdBlockBrowser> {
  InAppWebViewController? webViewController;
  TextEditingController urlController = TextEditingController(text: "https://www.google.com");

  final adBlockScript = '''
    const adSelectors = [
      '[id^="ad"], [class*="ad"], .adsbygoogle, .ad-container, iframe[src*="ads"]',
      'iframe[src*="doubleclick.net"]',
      'div[class*="sponsor"], div[class*="ad-"], div[id*="ad-"]'
    ];

    const observer = new MutationObserver(() => {
      adSelectors.forEach(selector => {
        document.querySelectorAll(selector).forEach(el => el.remove());
      });
    });

    observer.observe(document.body, { childList: true, subtree: true });
    adSelectors.forEach(selector => {
      document.querySelectorAll(selector).forEach(el => el.remove());
    });
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: urlController,
          keyboardType: TextInputType.url,
          onSubmitted: (url) {
            if (!url.startsWith("http")) url = "https://" + url;
            webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
          },
          decoration: InputDecoration(
            hintText: "Enter website URL",
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(urlController.text)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            useOnLoadResource: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStop: (controller, url) async {
          await controller.evaluateJavascript(source: adBlockScript);
        },
      ),
    );
  }
}
