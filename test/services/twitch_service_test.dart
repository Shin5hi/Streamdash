import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamdash/services/twitch_service.dart';

void main() {
  group('TwitchService credentials', () {
    test('sends the configured token as a Helix Bearer token', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.twitch.tv/helix'));
      RequestOptions? request;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            request = options;
            handler.resolve(
              Response(requestOptions: options, data: {'data': []}),
            );
          },
        ),
      );
      final service = TwitchService.forTesting(
        dio: dio,
        clientId: 'test-client-id',
        accessToken: 'oauth:test-access-token',
        channelLogin: 'test-channel',
      );

      await service.fetchChannelInfo();

      expect(request?.headers['Authorization'], 'Bearer test-access-token');
      expect(request?.headers['Client-Id'], 'test-client-id');
    });

    test('reports a missing access token without making a request', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.twitch.tv/helix'));
      var requestCount = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestCount++;
            handler.resolve(Response(requestOptions: options, data: {}));
          },
        ),
      );
      final service = TwitchService.forTesting(
        dio: dio,
        clientId: 'test-client-id',
        accessToken: '',
        channelLogin: 'test-channel',
      );

      expect(service.hasCredentials, isFalse);
      expect(
        service.configurationError,
        'Twitch access token is not configured.',
      );
      expect(await service.fetchChannelInfo(), isNull);
      expect(requestCount, 0);
    });
  });
}
