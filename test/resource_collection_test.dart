#library('resource_test');

#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');
#import('http_mocks.dart');

TestResourceCollection() {
  group('ResourceCollection', () {
    test('populates', () {
      var rf = new MockHttpRequestFactory('["mercury"]');
      var planetsResource = new Resource<String>('/planets', httpRequestFactory: rf.factory);
      var collection = new ResourceCollection<String>(planetsResource);
      collection.onLoadFn = expectAsync1((ResourceCollection<String> c) {
        expect(['mercury'], c);
      });
      collection.onChangeFn = expectAsync1((ResourceCollection<String> c) {
        expect(['mercury'], c);
      });
      collection.length; // trigger load
      rf.request.getLogs(callsTo('open', 'GET', '/planets')).verify(happenedOnce);
    });

    test('deserializes', () {
      var planetsResource = new Resource<String>('/planets', httpRequestFactory: new MockHttpRequestFactory('["mercury"]').factory);
      var collection = new ResourceCollection<String>(planetsResource);
      collection.deserializeFn = (Object rawData) => '_${rawData as String}_';
      collection.length; // trigger load
      expect(['_mercury_'], collection);
    });

    test('deserializeList', () {
      var planetsResource = new Resource<String>('/planets', httpRequestFactory: new MockHttpRequestFactory('{"items":["mercury"]}').factory);
      var collection = new ResourceCollection<String>(planetsResource);
      collection.deserializeListFn = (Object rawData) => rawData['items'];
      collection.length; // trigger load
      expect(['mercury'], collection);
    });

    test('adds', () {
      var rf = new MockHttpRequestFactory('[]');
      var planetsResource = new Resource<String>('/planets', httpRequestFactory: rf.factory);
      var collection = new ResourceCollection<String>(planetsResource);
      var venusAdded = false;
      collection.onChangeFn = expectAsync1((ResourceCollection<String> c) {
        if (venusAdded) {
          expect((new List.from(c)).indexOf('venus') != -1, reason: 'collection should contain venus');
        }
      }, count: 2);
      expect((new List.from(collection)).indexOf('venus') == -1, reason: 'collection should not contain venus');
      venusAdded = true;
      collection.add('venus');
      rf.request.getLogs(callsTo('open', 'POST', '/planets')).verify(happenedOnce);
      rf.request.getLogs(callsTo('send', '"venus"')).verify(happenedOnce);
    });

    test('removes', () {
      var rf = new MockHttpRequestFactory('["mercury","venus"]');
      var planetsResource = new Resource<String>('/planets', httpRequestFactory: rf.factory);
      var collection = new ResourceCollection<String>(planetsResource);
      var venusRemoved = false;
      collection.idParamsFn = (planetName) => {'id': planetName};
      collection.onChangeFn = expectAsync1((ResourceCollection<String> c) {
        if (venusRemoved) {
          expect((new List.from(c)).contains('venus') == false, reason: 'collection should not contain venus');
        }
      }, count: 2);
      collection.onLoadFn = expectAsync1((ResourceCollection<String> c) {
        venusRemoved = true;
        c.removeAt(c.indexOf('venus'));
      });
      collection.length; // trigger load
      rf.request.getLogs(callsTo('open', 'DELETE', '/planets/venus')).verify(happenedOnce);
      rf.request.getLogs(callsTo('send', null)).verify(happenedExactly(2));
    });

    test('Iterator', () {
      var rf = new MockHttpRequestFactory('["mercury"]');
      var planetsResource = new Resource<String>('/planets', httpRequestFactory: rf.factory);
      var collection = new ResourceCollection<String>(planetsResource);
      collection.length; // trigger load
      expect(true, collection.every((e) => e == 'mercury'));
      collection.forEach(expectAsync1((e) => expect('mercury', e)));
    });
  });
}
