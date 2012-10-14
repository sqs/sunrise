#library('http_mocks');

#import('dart:html', prefix:'html');
#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');

class MockHttpRequest extends Mock implements html.HttpRequest {}
class MockHttpRequestEvents extends Mock implements html.HttpRequestEvents {}
class MockEventListenerList extends Mock implements html.EventListenerList {
  final bool shouldCallHandler;

  MockEventListenerList(this.shouldCallHandler);

  html.EventListenerList add(html.EventListener handler, [bool useCapture]) {
    if (shouldCallHandler) {
      handler(null);
    }
  }
}

HttpRequestFactory mockHttpRequestFactory(String responseText) {
  return () {
    html.HttpRequest r = new MockHttpRequest();
    html.HttpRequestEvents mockEvents = new MockHttpRequestEvents();
    html.EventListenerList mockLoadEvents = new MockEventListenerList(true);
    html.EventListenerList mockErrorEvents = new MockEventListenerList(false);

    r.when(callsTo('get on')).alwaysReturn(mockEvents);
    r.when(callsTo('get responseText')).alwaysReturn(responseText);
    mockEvents.when(callsTo('get load')).alwaysReturn(mockLoadEvents);
    mockEvents.when(callsTo('get error')).alwaysReturn(mockErrorEvents);

    return r;
  };
}
