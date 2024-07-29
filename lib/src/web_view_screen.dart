// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class WebViewScreen extends StatefulWidget {
//   const WebViewScreen({super.key});
//
//   @override
//   WebViewScreenState createState() => WebViewScreenState();
// }
//
// class WebViewScreenState extends State<WebViewScreen> {
//   late HttpServer _localServer;
//   String? _localServerUrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _startLocalServer();
//   }
//
//   Future<void> _startLocalServer() async {
//     try {
//       final documentDirPath = await getApplicationDocumentsDirectory();
//       final webBuildPath = Directory('${documentDirPath.path}/app/web');
//
//       if (!await webBuildPath.exists()) {
//         log('Web build directory does not exist: ${webBuildPath.path}');
//         return;
//       }
//
//       _localServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
//       _localServer.listen((HttpRequest request) async {
//         final filePath = request.uri.path == '/' ? '/index.html' : request.uri.path;
//         final file = File('${webBuildPath.path}$filePath');
//
//         if (await file.exists()) {
//           final mimeType = _getMimeType(filePath);
//           request.response.headers.contentType = ContentType.parse(mimeType);
//           await request.response.addStream(file.openRead());
//           await request.response.close();
//         } else {
//           request.response.statusCode = HttpStatus.notFound;
//           await request.response.close();
//         }
//       });
//
//       setState(() {
//         _localServerUrl = 'http://${_localServer.address.host}:${_localServer.port}/';
//       });
//     } catch (e) {
//       log('Error starting local server: $e');
//     }
//   }
//
//   String _getMimeType(String filePath) {
//     if (filePath.endsWith('.html')) return 'text/html';
//     if (filePath.endsWith('.js')) return 'application/javascript';
//     if (filePath.endsWith('.css')) return 'text/css';
//     if (filePath.endsWith('.png')) return 'image/png';
//     if (filePath.endsWith('.jpg')) return 'image/jpeg';
//     if (filePath.endsWith('.svg')) return 'image/svg+xml';
//     return 'application/octet-stream';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = WebViewController();
//     if (_localServerUrl != null) {
//       controller.loadRequest(Uri.parse(_localServerUrl!));
//       controller.setJavaScriptMode(JavaScriptMode.unrestricted);
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Local Server'),
//       ),
//       body: _localServerUrl != null
//           ? SafeArea(child: WebViewWidget(controller: controller))
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
//
//   @override
//   void dispose() {
//     _localServer.close();
//     super.dispose();
//   }
//
// }

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:local_server/src/local_server.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final localServer = LocalServer();

  @override
  void initState() {
    super.initState();
    localServer.startServer('news').then((value) {
      log('Server Running: ${localServer.serving}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController();
    if (localServer.serving) {
      controller.loadRequest(Uri.parse(localServer.url!));
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    return Scaffold(
        body: SafeArea(
      child: localServer.serving
          ? WebViewWidget(
              controller: controller,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    ));
  }

  @override
  void dispose() {
    localServer.stopServer();
    super.dispose();
  }
}
