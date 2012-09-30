#library("sunrise:browser_test_runner");

#import('package:unittest/html_enhanced_config.dart');

#import('compiler_test.dart');
#import('resource_test.dart');
#import('scope_test.dart');

main() {
  useHtmlEnhancedConfiguration();

  TestCompiler();
  TestResource();
  TestScope();
}
