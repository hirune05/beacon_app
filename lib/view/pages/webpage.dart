import 'dart:async';
import 'dart:io'; // Add this import.
import 'package:flutter/material.dart';
import 'package:sumple_beacon/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'navigation_controls.dart';

void main() {
  runApp(
    const MaterialApp(
      home: WebPage(),
    ),
  );
}

class WebPage extends StatefulWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  // Add from here ...
  @override
  void initState() {
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    super.initState();
  }
  // ... to here.

  final controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: subcolor),
        //leading: Image.asset('images/icon.png'),
        backgroundColor: Colors.white,
        title: const Text(
          '聴覚過敏について知る',
          style: TextStyle(color: Color.fromARGB(255, 21, 9, 4)),
        ),
        shape:
            Border(bottom: BorderSide(color: Colors.pink.shade100, width: 6)),
        actions: [
          NavigationControls(controller: controller),
        ],
      ),
      body: const WebView(
        initialUrl: 'https://cocomakersmap.glitch.me/1st.map.html',
      ),
    );
  }
}
