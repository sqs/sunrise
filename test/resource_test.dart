#import('package:unittest/vm_config.dart');
#import('package:unittest/unittest.dart');

// VM-only
#import("dart:io");

#import('package:sunrise/sunrise.dart');

// VM-only
class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpClientConnection extends Mock implements HttpClientConnection {
  final String responseText;

  MockHttpClientConnection(this.responseText);

  set onResponse(void callback(HttpClientResponse response)) {
    var response = new MockHttpClientResponse();

    var stream = new ListInputStream();
    stream.write(responseText.charCodes());
    stream.markEndOfStream();

    response.when(callsTo('get inputStream')).alwaysReturn(stream);
    callback(response);
  }
}

class MockHttpClient extends Mock implements HttpClient {}

main() {
  useVmConfiguration();

  group('Resource', () {
    test('creates with base URL', () {
      var planets = new Resource('/planets');
      expect(planets.url, equals('/planets'));
    });

    group('query', () {
      group('basic', () {
        test('issues HTTP request and parses JSON', () {
          HttpClientConnection clientConn = new MockHttpClientConnection('["mercury"]');
          HttpClient client = new MockHttpClient();

          var clientCall = callsTo('get', 'localhost', 9000, '/planets');
          client.when(clientCall).alwaysReturn(clientConn);

          var planets = new Resource('/planets', httpClient: client);
          planets.query({}, expectAsync1((data) => expect(['mercury'], data)));

          client.getLogs(clientCall).verify(happenedOnce);
        });
      });
    });

    group('get', () {
      group('basic', () {
        test('issues HTTP request and parses JSON', () {
          HttpClientConnection clientConn = new MockHttpClientConnection('{"id": "mercury", "name": "Mercury"}');
          HttpClient client = new MockHttpClient();

          var clientCall = callsTo('get', 'localhost', 9000, '/planets/mercury');
          client.when(clientCall).alwaysReturn(clientConn);

          var planets = new Resource('/planets', httpClient: client);
          planets.get({'id': 'mercury'}, expectAsync1((data) => expect({'id': 'mercury', 'name': 'Mercury'}, data)));

          client.getLogs(clientCall).verify(happenedOnce);          
        });
      });
    });
  });
}
