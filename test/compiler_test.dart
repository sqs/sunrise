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
