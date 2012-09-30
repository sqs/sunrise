#library("sunrise:browser_test_runner");

#import('package:unittest/html_enhanced_config.dart');

#import('compiler_test.dart');
#import('interpolation_test.dart');
#import('resource_test.dart');
#import('scope_test.dart');

#import('directive/input_test.dart');

main() {
  useHtmlEnhancedConfiguration();

  TestCompiler();
  TestInterpolation();
  TestResource();
  TestScope();

  TestInputDirective();
}
