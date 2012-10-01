#library('bind_directive_test');

#import('dart:html');
#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');

TestBindDirective() {

  group('BindDirective', () {
    test('updates on setUp and on scope key change', () {
      Element input = new Element.html('<span ng-bind="color"></span>');
      Scope s = new Scope();
      BindDirective d = new BindDirective();
      s['color'] = 'blue';
      d.setUp(s, input);
      expect(input.nodes[0].data, 'blue');
      s['color'] = 'red';
      expect(input.nodes[0].data, 'red');
    });
  });

}
