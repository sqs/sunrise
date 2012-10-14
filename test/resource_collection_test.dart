#library('resource_test');

#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');
#import('http_mocks.dart');

TestResourceCollection() {
  group('ResourceCollection', () {
    test('populates', () {
      var planetsResource = new Resource<String>('/planets', httpRequestFactory: mockHttpRequestFactory('["mercury"]'));
      var collection = new ResourceCollection<String>(planetsResource);
      collection.onLoad(expectAsync1((ResourceCollection<String> c) {
        expect(['mercury'], c);
      }));
      collection.length; // trigger load
    });
  });
}
