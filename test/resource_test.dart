#library('resource_test');

#import('http_mocks.dart');
#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');

TestResource() {
  group('Resource', () {
    test('creates with base URL', () {
      var planets = new Resource('/planets');
      expect(planets.url, equals('/planets'));
    });

    group('query', () {
      group('basic', () {
        test('issues HTTP request and parses JSON', () {
          var planets = new Resource('/planets', httpRequestFactory: mockHttpRequestFactory('["mercury"]'));
          planets.query({}, expectAsync1((data) => expect(['mercury'], data)));
        });
      });
    });

    group('get', () {
      group('basic', () {
        test('issues HTTP request and parses JSON', () {
          String responseText = '{"id": "mercury", "name": "Mercury"}';
          var planets = new Resource('/planets', httpRequestFactory: mockHttpRequestFactory(responseText));
          planets.get({'id': 'mercury'}, expectAsync1((data) => expect({'id': 'mercury', 'name': 'Mercury'}, data)));
        });
      });
    });
  });
}
