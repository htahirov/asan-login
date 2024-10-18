import 'dart:async';
import 'dart:developer' as logger;

import 'package:flutter/services.dart';

import 'helpers/uuid_helper.dart';

class AsanLoginController {
  AsanLoginController._() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static AsanLoginController? _instance;

  static AsanLoginController get instance =>
      _instance ??= AsanLoginController._();

  static const _channel = MethodChannel('asan_login');
  final _asanCodeController = StreamController<String>();

  Stream<String> get asanCodeStream => _asanCodeController.stream;

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onCodeReceived' && call.arguments != null) {
      _asanCodeController.add(call.arguments);
    }
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
      final sessionId = UuidHelper.generateUuid();
      logger.log('UUID: $sessionId');
      await _channel.invokeMethod(
        'performLogin',
        {
          'url': url,
          'clientId': clientId,
          'redirectUri': redirectUri,
          'scope': scope,
          'sessionId': sessionId,
          'responseType': responseType,
          'scheme': scheme,
        },
      );
    } on PlatformException catch (e) {
      logger.log('Failed to perform login: ${e.message}');
    }
  }

  void dispose() => _asanCodeController.close();
}
