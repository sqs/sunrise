#library('compiler_test');

#import('dart:html');
#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');

TestCompiler() {
  DivElement divWithText(String text) {
    DivElement div = new DivElement();
    div.nodes.add(new Text(text));
    return div;
  }

  group('directives', () {
    DirectiveRegistry reg = new DirectiveRegistry(
      elementDirectives: {'p': [new ElementDirective('testP')]},
      attributeDirectives: {'color': [new AttributeDirective('testColor')]});

    test('unattributed element', () {
      Element appRoot = new Element.html('<p></p>');
      var directives = directives(appRoot, reg);
      expect(directives.length, 1);
      expect(directives[0].name, 'testP');
      expect(directives[0] is ElementDirective, reason: '${directives[0]} is not ElementDirective');
    });

    test('only collect directives from root element', () {
      Element appRoot = new Element.html('<p></p>');
      appRoot.innerHTML = '<p><p></p></p>';
      var directives = directives(appRoot, reg);
      expect(directives.length, 1);
      expect(directives[0].name, 'testP');
      expect(directives[0] is ElementDirective, reason: '${directives[0]} is not ElementDirective');
    });

    test('attributed element', () {
      Element appRoot = new Element.html('<p color="red" shape="circle"></p>');
      var directives = directives(appRoot, reg);
      expect(directives.length, 2);
      expect(directives[0].name, 'testP');
      expect(directives[0] is ElementDirective, reason: '${directives[0]} is not ElementDirective');
      expect(directives[1].name, 'testColor');
      expect(directives[1] is AttributeDirective, reason: '${directives[1]} is not AttributeDirective');
    });
  });

  group('processBindingsInTextNodes', () {
    test('replace {{ ... }} with <span> tag', () {
      Element div = divWithText('Hello, {{ name }}!');
      processBindingsInTextNodes(div);

      expect(div.nodes.length, 3);
      expect(div.nodes[0].data, 'Hello, ');
      expect(div.nodes[2].data, '!');

      SpanElement boundElement = div.nodes[1];
      expect(boundElement.nodes.length, 0);
      expect(boundElement.attributes['ng-bind'], 'name');
    });

    test('do not introduce extraneous empty text nodes', () {
      Element div = divWithText('{{ expr1 }}{{ expr2 }}');
      processBindingsInTextNodes(div);

      expect(div.nodes.length, 2);
      expect(div.nodes[0].attributes['ng-bind'], 'expr1');
      expect(div.nodes[1].attributes['ng-bind'], 'expr2');
    });

    test('replace multiple bindings in a single text node', () {
      Element div = divWithText('{{ expr1 }} and {{ expr2 }}');
      processBindingsInTextNodes(div);

      expect(div.nodes.length, 3);
      expect(div.nodes[0].attributes['ng-bind'], 'expr1');
      expect(div.nodes[1].data, ' and ');
      expect(div.nodes[2].attributes['ng-bind'], 'expr2');
    });
  });
}
