import 'package:filesize/filesize.dart';

const path = 'assets/images/files';

List<String> validFileTypes() {
  return [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
    'txt',
    'csv',
    'png',
    'jpg',
    'tiff',
    'tif',
    '7z',
    'zip',
    'rar',
  ];
}

String fileIcon(String fileName) {
  final fileType = fileName.split('.').last.toLowerCase();
  final validTypes = validFileTypes();

  if (validTypes.contains(fileType)) {
    print('$path/$fileType.png');
    return '$path/$fileType.png';
  } else {
    return '$path/file.png';
  }
}

String formatFileSize(int size) {
  return filesize(size);
}

bool isFileOpenInViewer(String fileName) {
  final fileType = fileName.split('.').last.toLowerCase();
  switch (fileType.toLowerCase()) {
    case "pdf":
    case "doc":
    case "docx":
    case "ppt":
    case "pptx":
      return true;
  }
  return false;
}
