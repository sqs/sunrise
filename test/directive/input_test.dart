#library('input_directive_test');

#import('dart:html');
#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');

TestInputDirective() {

  group('InputDirective', () {
    test('updates on setUp and on input event', () {
      Element input = new Element.html('<input ng-model="shape" value="circle">');
      Scope s = new Scope();
      InputDirective d = new InputDirective();
      d.setUp(s, input);
      expect(s['shape'], 'circle');
      input.value = 'square';
      input.on.input.dispatch(new Event('input'));
      window.setTimeout(expectAsync0(() => expect(s['shape'], 'square')), 200);
    });

    test('ignores <inputs> with no ng-model', () {
      Element input = new Element.html('<input type=text value=hello>');
      Scope s = new Scope();
      InputDirective d = new InputDirective();
      expect(() => d.setUp(s, input), returnsNormally);
    });
  });
}
