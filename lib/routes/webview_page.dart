import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flow/prefs.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (url == 'https://johnybrown.website/lander/money-pitcher/start_chat') {
              openApp();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://johnybrown.website/MP'));
  }

  void openApp() {
    if (LocalPreferences().completedInitialSetup.get()) {
      GoRouter.of(context).go('/home');
    } else {
      GoRouter.of(context).go('/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
