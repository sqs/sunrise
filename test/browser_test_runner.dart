#library("sunrise:browser_test_runner");

#import('package:unittest/html_enhanced_config.dart');

#import('resource_test.dart');
#import('resource_collection_test.dart');

main() {
  useHtmlEnhancedConfiguration();

  TestResource();
  TestResourceCollection();
}
