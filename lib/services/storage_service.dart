import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'dart:io';

class StorageService {
  // Upload an image to S3
  Future<String?> uploadImage(File image, String userId) async {
    try {
      final key = 'images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final options = StorageUploadFileOptions(
        accessLevel: StorageAccessLevel.private,
        metadata: {
          'userId': userId,
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );
      
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(image.path),
        key: key,
        options: options,
      );
      
      // Get the URL for the uploaded file
      final urlOptions = StorageGetUrlOptions(
        accessLevel: StorageAccessLevel.private,
        expires: const Duration(minutes: 60),
      );
      
      final urlResult = await Amplify.Storage.getUrl(
        key: key,
        options: urlOptions,
      );
      
      return urlResult.url.toString();
    } catch (e) {
      safePrint('Error uploading image: $e');
      return null;
    }
  }
  
  // Upload a document to S3
  Future<String?> uploadDocument(File document, String userId, String filename) async {
    try {
      final key = 'documents/$userId/${DateTime.now().millisecondsSinceEpoch}_$filename';
      final options = StorageUploadFileOptions(
        accessLevel: StorageAccessLevel.private,
        metadata: {
          'userId': userId,
          'filename': filename,
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );
      
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(document.path),
        key: key,
        options: options,
      );
      
      // Get the URL for the uploaded file
      final urlOptions = StorageGetUrlOptions(
        accessLevel: StorageAccessLevel.private,
        expires: const Duration(hours: 24),
      );
      
      final urlResult = await Amplify.Storage.getUrl(
        key: key,
        options: urlOptions,
      );
      
      return urlResult.url.toString();
    } catch (e) {
      safePrint('Error uploading document: $e');
      return null;
    }
  }
  
  // Download a file from S3
  Future<File?> downloadFile(String key, String localPath) async {
    try {
      final result = await Amplify.Storage.downloadFile(
        key: key,
        localFile: AWSFile.fromPath(localPath),
        options: const StorageDownloadFileOptions(
          accessLevel: StorageAccessLevel.private,
        ),
      );
      
      return File(localPath);
    } catch (e) {
      safePrint('Error downloading file: $e');
      return null;
    }
  }
  
  // Delete a file from S3
  Future<bool> deleteFile(String key) async {
    try {
      await Amplify.Storage.remove(
        key: key,
        options: const StorageRemoveOptions(
          accessLevel: StorageAccessLevel.private,
        ),
      );
      
      return true;
    } catch (e) {
      safePrint('Error deleting file: $e');
      return false;
    }
  }
}