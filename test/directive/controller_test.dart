#library('controller_directive_test');

#import('dart:html');
#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');

class TestCtrl extends Controller {
  void init() {
    scope['color'] = 'blue';
  }
}

TestControllerDirective() {

  group('ControllerDirective', () {
    test('sets __controllerName and scope attribute on setUp', () {
      Element root = new Element.html('<div ng-controller="controller_directive_test.TestCtrl"></div>');
      Scope s = new Scope();
      ControllerDirective d = new ControllerDirective();
      d.setUp(s, root);
      expect(s['__controllerName'], 'controller_directive_test.TestCtrl');
      expect(s['color'], 'blue');
    });
  });

}
