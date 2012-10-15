#library('resource_test');

#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');
#import('http_mocks.dart');

TestResourceCollection() {
  group('ResourceCollection', () {
    test('populates', () {
      var planetsResource = new Resource<String>('/planets', httpRequestFactory: new MockHttpRequestFactory('["mercury"]').factory);
      var collection = new ResourceCollection<String>(planetsResource);
      collection.onLoadFn = expectAsync1((ResourceCollection<String> c) {
        expect(['mercury'], c);
      });
      collection.onChangeFn = expectAsync1((ResourceCollection<String> c) {
        expect(['mercury'], c);
      });
      collection.length; // trigger load
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
