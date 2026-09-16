import 'package:flutter/foundation.dart';

class AppConfig {
  static const apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kReleaseMode ? '' : 'http://10.64.199.162:3000/api',
  );
  static const socketBase = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: kReleaseMode ? '' : 'http://10.64.199.162:3000',
  );
  static String mediaUrl(String path) => path.startsWith('http')
      ? path
      : '${apiBase.replaceFirst(RegExp(r'/api$'), '')}/${path.replaceFirst(RegExp(r'^/'), '')}';
}
