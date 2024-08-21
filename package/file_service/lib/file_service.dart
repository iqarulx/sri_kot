library file_service;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

enum Type { user, company, staff, product, none }

class FileService {
  static Future<void> syncFiles({
    required String fileUrl,
    required Type type,
    required String id,
  }) async {
    try {
      // Get the application documents directory
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final metadataFilePath =
          path.join(documentsDirectory.path, 'metadata.json');
      final metadataFile = File(metadataFilePath);

      // Initialize metadata map
      Map<String, List<Map<String, String>>> metadata = {
        'user': [],
        'company': [],
        'staff': [],
        'product': [],
      };

      // Load existing metadata if available
      if (await metadataFile.exists()) {
        final metadataContent = await metadataFile.readAsString();
        final decodedMetadata =
            jsonDecode(metadataContent) as Map<String, dynamic>;

        metadata['user'] = _parseMetadataList(decodedMetadata['user']);
        metadata['company'] = _parseMetadataList(decodedMetadata['company']);
        metadata['staff'] = _parseMetadataList(decodedMetadata['staff']);
        metadata['product'] = _parseMetadataList(decodedMetadata['product']);
      }

      // Prepare the file metadata
      final fileMetadata = {
        'file_path': '',
        'id': id,
      };

      if (fileUrl.isNotEmpty) {
        // Download the file from the URL
        final response = await http.get(Uri.parse(fileUrl));

        if (response.statusCode == 200) {
          final uniqueFileName =
              '${DateTime.now().millisecondsSinceEpoch}_${path.basename(fileUrl)}';
          final filePath = path.join(documentsDirectory.path, uniqueFileName);
          final file = File(filePath);

          // Save the downloaded file to local storage
          await file.writeAsBytes(response.bodyBytes);

          // Update the file metadata with the local file path
          fileMetadata['file_path'] = filePath;
        } else {
          throw Exception('Failed to download file: ${response.statusCode}');
        }
      }
      // Update metadata with new entry
      final typeString = type.toString().split('.').last;
      metadata[typeString]?.add(fileMetadata);

      // Save the updated metadata to file
      await metadataFile.writeAsString(jsonEncode(metadata), flush: true);
    } catch (e) {
      throw 'Error: $e';
    }
  }

  // Helper method to parse and return metadata list
  static List<Map<String, String>> _parseMetadataList(dynamic data) {
    if (data is List) {
      return (data)
          .map((item) => Map<String, String>.from(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<void> clearDirectory() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      for (var file in files) {
        if (file is File) {
          await file.delete();
        } else if (file is Directory) {
          await clearDirectory();
          await file.delete();
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
