import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamdash/services/twitch_service.dart';

void main() {
  group('TwitchService credentials', () {
    for (final token in [
      'oauth:test-access-token',
      'OAUTH:test-access-token',
      '  test-access-token  ',
    ]) {
      test('normalizes configured token "$token" before sending it', () async {
        RequestOptions? request;
        final service = _service(
          clientId: ' test-client-id ',
          accessToken: token,
          onRequest: (options) => request = options,
        );

        await service.fetchChannelInfo();

        expect(request?.headers['Authorization'], 'Bearer test-access-token');
        expect(request?.headers['Client-Id'], 'test-client-id');
      });
    }

    test('reports missing token without making a request', () async {
      var requestCount = 0;
      final service = _service(
        clientId: 'test-client-id',
        accessToken: '',
        onRequest: (_) => requestCount++,
      );

      expect(service.hasCredentials, isFalse);
      expect(
        service.configurationError,
        'Twitch access token is not configured.',
      );
      expect(await service.fetchChannelInfo(), isNull);
      expect(requestCount, 0);
    });

    test(
      'rejects a placeholder access token without making a request',
      () async {
        var requestCount = 0;
        final service = _service(
          clientId: 'test-client-id',
          accessToken: ' YOUR_TWITCH_ACCESS_TOKEN ',
          onRequest: (_) => requestCount++,
        );

        expect(service.hasCredentials, isFalse);
        expect(
          service.configurationError,
          'Twitch access token is not configured.',
        );
        expect(await service.fetchChannelInfo(), isNull);
        expect(requestCount, 0);
      },
    );

    test('rejects a whitespace-padded Client ID placeholder', () async {
      var requestCount = 0;
      final service = _service(
        clientId: ' YOUR_TWITCH_CLIENT_ID ',
        accessToken: 'test-access-token',
        onRequest: (_) => requestCount++,
      );

      expect(service.hasCredentials, isFalse);
      expect(service.configurationError, 'Twitch Client ID is not configured.');
      expect(await service.fetchChannelInfo(), isNull);
      expect(requestCount, 0);
    });

    test('reports a missing Client ID without making a request', () async {
      var requestCount = 0;
      final service = _service(
        clientId: '',
        accessToken: 'test-access-token',
        onRequest: (_) => requestCount++,
      );

      expect(service.hasCredentials, isFalse);
      expect(service.configurationError, 'Twitch Client ID is not configured.');
      expect(await service.fetchChannelInfo(), isNull);
      expect(requestCount, 0);
    });
  });
}

TwitchService _service({
  required String clientId,
  required String accessToken,
  required void Function(RequestOptions) onRequest,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.twitch.tv/helix'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        onRequest(options);
        handler.resolve(Response(requestOptions: options, data: {'data': []}));
      },
    ),
  );
  return TwitchService.forTesting(
    dio: dio,
    clientId: clientId,
    accessToken: accessToken,
    channelLogin: 'test-channel',
  );
}
