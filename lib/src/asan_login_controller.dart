import 'dart:async';
import 'dart:developer' as logger;
import 'dart:math';

import 'package:flutter/services.dart';

class AsanLoginController {
  AsanLoginController._() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static AsanLoginController? _instance;

  static AsanLoginController get instance =>
      _instance ??= AsanLoginController._();

  static const _channel = MethodChannel('asan_login');
  final _asanCodeController = StreamController<String>.broadcast();

  Stream<String> get asanCodeStream => _asanCodeController.stream;

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onCodeReceived' && call.arguments != null) {
      _asanCodeController.add(call.arguments);
    }
  }

  String get _generateCustomUuid {
    final random = Random();

    String formatSection(int length) => List.generate(
          length,
          (index) => random.nextInt(16).toRadixString(16),
        ).join();

    String uuid =
        '${formatSection(8)}-${formatSection(4)}-${formatSection(4)}-${formatSection(4)}-${formatSection(12)}';

    return uuid;
  }

  Future<void> performLogin({
    required String url,
    required String clientId,
    required String redirectUri,
    String scope = 'openid certificate',
    String responseType = 'code',
    required String scheme,
  }) async {
    try {
      await _channel.invokeMethod(
        'performLogin',
        {
          'url': url,
          'clientId': clientId,
          'redirectUri': redirectUri,
          'scope': scope,
          'sessionId': _generateCustomUuid,
          'responseType': responseType,
          'scheme': scheme,
        },
      );
    } on PlatformException catch (e) {
      logger.log('Failed to perform login: ${e.message}');
    }
  }

  void dispose() {
    _asanCodeController.close();
  }
}
