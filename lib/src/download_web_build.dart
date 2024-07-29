import 'dart:developer';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class LoadWebBuild extends StatelessWidget {
  const LoadWebBuild({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Web Build'),
      ),
      body: Center(
        child: ElevatedButton(onPressed: (){
          extractZipAndStoreInDocuments('assets/web.zip').then((value){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Done')));
          });
        }, child: const Text('Load')),
      ),
    );
  }
}


Future<void> extractZipAndStoreInDocuments(String assetPath) async {
  try {
    // Get the documents directory
    Directory documentsDir = await getApplicationDocumentsDirectory();

    // Load the zip file from assets as bytes
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List();

    // Decode the zip file
    Archive archive = ZipDecoder().decodeBytes(bytes);

    // Create the 'app' directory inside the documents directory
    Directory appDir = Directory('${documentsDir.path}/news');
    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }

    // Extract the contents of the zip file
    for (ArchiveFile file in archive) {
      String filename = file.name;
      List<int> fileData = file.content as List<int>;

      // Ensure that the file path does not end with a directory separator
      if (file.name.endsWith('/')) {
        // This is a directory, so create it if necessary
        Directory dir = Directory('${appDir.path}/$filename');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
      } else {
        // This is a file, so create it and write data to it
        File outFile = File('${appDir.path}/$filename');
        log(outFile.path);

        // Ensure the parent directory exists
        outFile.parent.createSync(recursive: true);

        // Write the data to the file
        outFile.writeAsBytesSync(fileData);
      }
    }

    print('Extraction and storage completed');
  } catch (e) {
    print('An error occurred during extraction: $e');
  }
}