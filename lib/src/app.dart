import 'package:flutter/material.dart';
import 'package:local_server/src/download_web_build.dart';
import 'package:local_server/src/web_view_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Local Server',
      home: WebViewScreen(),
    );
  }
}