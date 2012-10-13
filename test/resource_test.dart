#library('resource_test');

#import('package:unittest/unittest.dart');

#import('dart:html', prefix:'html');

#import('package:sunrise/sunrise.dart');

class MockHttpRequest extends Mock implements html.HttpRequest {}
class MockHttpRequestEvents extends Mock implements html.HttpRequestEvents {}
class MockEventListenerList extends Mock implements html.EventListenerList {
  html.EventListenerList add(html.EventListener handler, [bool useCapture]) {
    handler(null);
  }
}

HttpRequestFactory mockHttpRequestFactory(String responseText) {
  return () {
    html.HttpRequest r = new MockHttpRequest();
    html.HttpRequestEvents mockEvents = new MockHttpRequestEvents();
    html.EventListenerList mockLoadEvents = new MockEventListenerList();
    html.EventListenerList mockErrorEvents = new MockEventListenerList();

    r.when(callsTo('get on')).alwaysReturn(mockEvents);
    r.when(callsTo('get responseText')).alwaysReturn(responseText);
    mockEvents.when(callsTo('get load')).alwaysReturn(mockLoadEvents);
    mockEvents.when(callsTo('get error')).alwaysReturn(mockErrorEvents);

    return r;
  };
}

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
