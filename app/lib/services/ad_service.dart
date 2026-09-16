import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/feed_ad.dart';

class AdService {
  AdService._() : _session = 'mobile-${DateTime.now().microsecondsSinceEpoch}';
  static final instance = AdService._();
  final String _session;
  Map<String, String> get _headers => {'X-Ad-Session': _session};

  Future<List<FeedAd>> load(String placement, {int limit = 5}) async {
    final response = await ApiClient.instance.dio.get(
      '/ads/delivery',
      queryParameters: {'placement': placement, 'limit': limit},
      options: Options(headers: _headers),
    );
    return (response.data as List? ?? const [])
        .map((item) => FeedAd.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> impression(String token) => ApiClient.instance.dio.post(
    '/ads/impressions',
    data: {'deliveryToken': token},
    options: Options(headers: _headers),
  );

  Future<void> click(String token) => ApiClient.instance.dio.post(
    '/ads/clicks',
    data: {'deliveryToken': token},
    options: Options(headers: _headers),
  );
}
