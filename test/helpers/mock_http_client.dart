import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements HttpClient {}
class MockHttpClientRequest extends Mock implements HttpClientRequest {}
class MockHttpClientResponse extends Mock implements HttpClientResponse {}
class MockHttpHeaders extends Mock implements HttpHeaders {}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = MockHttpClient();
    final request = MockHttpClientRequest();
    final response = MockHttpClientResponse();
    final headers = MockHttpHeaders();

    // Mock openUrl instead of getUrl as http package might use it
    when(() => client.openUrl(any(), any())).thenAnswer((_) async => request);
    when(() => client.getUrl(any())).thenAnswer((_) async => request);
    when(() => request.headers).thenReturn(headers);
    when(() => request.close()).thenAnswer((_) async => response);
    when(() => response.statusCode).thenReturn(200);
    when(() => response.contentLength).thenReturn(_svgData.length);
    
    // Mock the listen method which is a bit tricky
    when(() => response.listen(any(),
        cancelOnError: any(named: 'cancelOnError'),
        onDone: any(named: 'onDone'),
        onError: any(named: 'onError'))).thenAnswer((invocation) {
      final onData = invocation.positionalArguments[0] as void Function(List<int>);
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      onData(utf8.encode(_svgData));
      onDone?.call();
      return MockStreamSubscription();
    });

    return client;
  }
}

class MockStreamSubscription extends Mock implements StreamSubscription<List<int>> {
  @override
  Future<void> cancel() async {}
}

const _svgData = '<svg height="100" width="100"><circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" /></svg>';
