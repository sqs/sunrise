#library('compiler_test');

#import('dart:html');
#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');

TestCompiler() {
  group('processBindingsInTextNodes', () {
    test('replace {{ ... }} with <span> tag', () {
      DivElement parentNode = new DivElement();
      Text origNode = new Text('Hello, {{ name }}!');
      parentNode.nodes.add(origNode);

      expect(parentNode.nodes.length, 1);

      processBindingsInTextNodes(parentNode);

      expect(parentNode.nodes.length, 3);
      expect(parentNode.nodes[0].data, 'Hello, ');
      expect(parentNode.nodes[2].data, '!');
      
      SpanElement boundElement = parentNode.nodes[1];
      expect(boundElement.nodes.length, 0);
      expect(boundElement.attributes['ng-bind'], 'name');
    });
  });
}
