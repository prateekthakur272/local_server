import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalServer {
  HttpServer? _localServer;
  bool _serving = false;
  String? _url;
  LocalServer();

  String? get url => _url;
  bool get serving => _serving;

  Future<String?> startServer(String appName) async {
    if(_serving) {
      return _url;
    }
    try {
      final documentDirPath = await getApplicationDocumentsDirectory();
      final webBuildPath = Directory('${documentDirPath.path}/$appName/web');

      if (!await webBuildPath.exists()) {
        log('Web build directory does not exist: ${webBuildPath.path}');
        return null;
      }

      _localServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _localServer!.listen((HttpRequest request) async {
        final filePath =
            request.uri.path == '/' ? '/index.html' : request.uri.path;
        final file = File('${webBuildPath.path}$filePath');

        if (await file.exists()) {
          final mimeType = _getMimeType(filePath);
          request.response.headers.contentType = ContentType.parse(mimeType);
          await request.response.addStream(file.openRead());
          await request.response.close();
        } else {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
        }
      });
      _serving = true;
    } catch (e) {
      log('Error starting local server: $e');
    }
    _url = 'http://${_localServer!.address.host}:${_localServer!.port}/';
    return _url;
  }

  String _getMimeType(String filePath) {
    if (filePath.endsWith('.html')) return 'text/html';
    if (filePath.endsWith('.js')) return 'application/javascript';
    if (filePath.endsWith('.css')) return 'text/css';
    if (filePath.endsWith('.png')) return 'image/png';
    if (filePath.endsWith('.jpg')) return 'image/jpeg';
    if (filePath.endsWith('.svg')) return 'image/svg+xml';
    return 'application/octet-stream';
  }

  Future<void> stopServer() async {
    // localServer.
    if (_localServer != null) {
      await _localServer?.close(force: true);
      _serving = false;
      _url = null;
    }
  }
}
