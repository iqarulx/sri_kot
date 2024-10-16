import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../services/services.dart';

Future saveFileToLocal(
  File file,
  Type type,
  String id,
) async {
  try {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final metadataFilePath = '${documentsDirectory.path}/metadata.json';

    final metadataFile = File(metadataFilePath);
    Map<String, List<Map<String, String>>> metadata = {
      'product': [],
      'staff': [],
      'user': [],
    };

    if (await metadataFile.exists()) {
      final metadataContent = await metadataFile.readAsString();
      final decodedMetadata =
          jsonDecode(metadataContent) as Map<String, dynamic>;

      if (decodedMetadata['product'] is List) {
        metadata['product'] = (decodedMetadata['product'] as List<dynamic>)
            .map((item) =>
                Map<String, String>.from(item as Map<String, dynamic>))
            .toList();
      }
      if (decodedMetadata['staff'] is List) {
        metadata['staff'] = (decodedMetadata['staff'] as List<dynamic>)
            .map((item) =>
                Map<String, String>.from(item as Map<String, dynamic>))
            .toList();
      }
      if (decodedMetadata['user'] is List) {
        metadata['user'] = (decodedMetadata['user'] as List<dynamic>)
            .map((item) =>
                Map<String, String>.from(item as Map<String, dynamic>))
            .toList();
      }
    }

    final uniqueFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final filePath = '${documentsDirectory.path}/$uniqueFileName';

    await file.copy(filePath);

    final fileMetadata = {
      'file_path': filePath,
      'id': id,
    };

    final typeString = type.toString().split('.').last;
    metadata[typeString]?.add(fileMetadata);

    await metadataFile.writeAsString(jsonEncode(metadata), flush: true);

    print('File saved and metadata updated.');
  } catch (e) {
    LogConfig.addLog("${DateTime.now()} : Error saving file: $e");
  }
}
