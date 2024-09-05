import 'dart:io';

import 'package:file_picker/file_picker.dart';
import '/constants/constants.dart';

class FilePickerProviderExcel {
  Future<File?> openGalary({required FileProviderType fileType}) async {
    File? pickedFile;

    if (fileType == FileProviderType.excel) {
      var result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );
      if (result != null) {
        pickedFile = File(result.files.single.path!);
      }
    } else if (fileType == FileProviderType.image) {
      var result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
        allowMultiple: false,
      );
      if (result != null) {
        pickedFile = File(result.files.single.path!);
      }
    }

    return pickedFile;
  }

  Future<File?> uploadSql() async {
    File? pickedFile;

    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      allowMultiple: false,
    );
    if (result != null) {
      pickedFile = File(result.files.single.path!);
    }

    return pickedFile;
  }
}
