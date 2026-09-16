import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_client.dart';

class UploadService {
  final _api = ApiClient.instance.dio;

  Future<void> createPost(
    XFile media,
    String caption, {
    ProgressCallback? onProgress,
  }) async {
    final form = FormData.fromMap({
      'media': await MultipartFile.fromFile(media.path, filename: media.name),
      'caption': caption.trim(),
    });
    await _api.post('/videos/upload', data: form, onSendProgress: onProgress);
  }

  Future<String> updateProfilePicture(
    XFile image, {
    ProgressCallback? onProgress,
  }) async {
    final form = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(
        image.path,
        filename: image.name,
      ),
    });
    final response = await _api.post(
      '/user/me/profile-picture',
      data: form,
      onSendProgress: onProgress,
    );
    return response.data['profile_picture'].toString();
  }

  Future<void> deletePost(int videoId) => _api.delete('/videos/$videoId');
}
