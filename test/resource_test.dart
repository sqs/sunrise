#import('package:unittest/vm_config.dart');
#import('package:unittest/unittest.dart');

#import('package:sunrise/sunrise.dart');

main() {
  useVmConfiguration();

  group('Resource', () {
    test('creates with base URL', () {
      var planets = new Resource('/planets');
      expect(planets.url, equals('/planets'));
    });
  });
}
