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
          var planets = new Resource('/planets', httpRequestFactory: new MockHttpRequestFactory('["mercury"]').factory);
          planets.query({}, expectAsync1((data) => expect(['mercury'], data)));
        });
      });
    });

    group('get', () {
      group('basic', () {
        test('issues HTTP request and parses JSON', () {
          String responseText = '{"id": "mercury", "name": "Mercury"}';
          var planets = new Resource('/planets', httpRequestFactory: new MockHttpRequestFactory(responseText).factory);
          planets.get({'id': 'mercury'}, expectAsync1((data) => expect({'id': 'mercury', 'name': 'Mercury'}, data)));
        });
      });
    });

    group('post', () {
      group('basic', () {
        test('issues HTTP request and parses JSON', () {
          String responseText = '{"id": "mercury", "name": "Mercury"}';
          var planets = new Resource('/planets', httpRequestFactory: new MockHttpRequestFactory(responseText).factory);
          planets.post({'name': 'Mercury'}, expectAsync1((data) => expect({'id': 'mercury', 'name': 'Mercury'}, data)));
        });
      });
    });
  });
}
