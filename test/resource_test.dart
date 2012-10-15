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
        test('issues HTTP GET request and parses JSON', () {
          var rf = new MockHttpRequestFactory('["mercury"]');
          var planets = new Resource('/planets', httpRequestFactory: rf.factory);
          planets.query({}, expectAsync1((data) => expect(['mercury'], data)));
          rf.request.getLogs(callsTo('open', 'GET', '/planets')).verify(happenedOnce);
          rf.request.getLogs(callsTo('send')).verify(happenedOnce);
        });
      });
    });

    group('get', () {
      group('basic', () {
        test('issues HTTP GET request and parses JSON', () {
          String responseText = '{"id": "mercury", "name": "Mercury"}';
          var rf = new MockHttpRequestFactory(responseText);
          var planets = new Resource('/planets', httpRequestFactory: rf.factory);
          planets.get({'id': 'mercury'}, expectAsync1((data) => expect({'id': 'mercury', 'name': 'Mercury'}, data)));
          rf.request.getLogs(callsTo('open', 'GET', '/planets/mercury')).verify(happenedOnce);
          rf.request.getLogs(callsTo('send')).verify(happenedOnce);
        });
      });
    });

    group('post', () {
      group('basic', () {
        test('issues HTTP POST request and parses JSON', () {
          String responseText = '{"id": "mercury", "name": "Mercury"}';
          var rf = new MockHttpRequestFactory(responseText);
          var planets = new Resource('/planets', httpRequestFactory: rf.factory);
          planets.post({'name': 'Mercury'}, expectAsync1((data) => expect({'id': 'mercury', 'name': 'Mercury'}, data)));
          rf.request.getLogs(callsTo('open', 'POST', '/planets')).verify(happenedOnce);
          rf.request.getLogs(callsTo('send', '{"name":"Mercury"}')).verify(happenedOnce);
        });
      });
    });

    group('put', () {
      group('basic', () {
        test('issues HTTP PUT request and parses JSON', () {
          String responseText = '{"id": "mercury", "name": "Mercury"}';
          var rf = new MockHttpRequestFactory(responseText);
          var planets = new Resource('/planets', httpRequestFactory: rf.factory);
          planets.put({'id': 'mercury'}, {'name': 'Mercury'}, expectAsync1((data) => expect({'id': 'mercury', 'name': 'Mercury'}, data)));
          rf.request.getLogs(callsTo('open', 'PUT', '/planets/mercury')).verify(happenedOnce);
          rf.request.getLogs(callsTo('send', '{"name":"Mercury"}')).verify(happenedOnce);
        });
      });
    });

    group('delete', () {
      group('basic', () {
        test('issues HTTP DELETE request and parses JSON', () {
          String responseText = '{"id": "mercury", "name": "Mercury"}';
          var rf = new MockHttpRequestFactory(responseText);
          var planets = new Resource('/planets', httpRequestFactory: rf.factory);
          planets.delete({'id': 'mercury'}, expectAsync1((data) => expect({'id': 'mercury', 'name': 'Mercury'}, data)));
          rf.request.getLogs(callsTo('open', 'DELETE', '/planets/mercury')).verify(happenedOnce);
          rf.request.getLogs(callsTo('send')).verify(happenedOnce);
        });
      });
    });
  });
}
