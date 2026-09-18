import 'package:flutter/foundation.dart';

class ApiConfig {
  static const productionUrl = String.fromEnvironment(
    'HERITRACE_API_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (productionUrl.isNotEmpty) {
      return productionUrl.replaceFirst(RegExp(r'/$'), '');
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }
}
