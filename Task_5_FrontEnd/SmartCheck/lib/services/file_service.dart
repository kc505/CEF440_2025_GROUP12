import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FileService {
  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status == PermissionStatus.granted;
    }
    return true; // iOS doesn't need explicit storage permission for file picker
  }

  // Pick a single file
  static Future<File?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      // Request permission if needed
      if (Platform.isAndroid) {
        final hasPermission = await requestStoragePermission();
        if (!hasPermission) return null;
      }

      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          return File(filePath);
        }
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  // Pick multiple files
  static Future<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      // Request permission if needed
      if (Platform.isAndroid) {
        final hasPermission = await requestStoragePermission();
        if (!hasPermission) return [];
      }

      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error picking files: $e');
      return [];
    }
  }

  // Pick image file
  static Future<File?> pickImageFile() async {
    return await pickFile(
      type: FileType.image,
    );
  }

  // Pick document file
  static Future<File?> pickDocumentFile() async {
    return await pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
    );
  }

  // Get file size in readable format
  static String getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Get file name from path
  static String getFileName(String filePath) {
    return filePath.split('/').last;
  }
}
