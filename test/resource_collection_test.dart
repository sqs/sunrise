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
      collection.length; // trigger load
    });
  });
}
