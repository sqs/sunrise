#library('compiler_test');

#import('dart:html');
#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');

TestCompiler() {
  Text textInDiv(String text) {
    DivElement div = new Element.html('<div>${text}</div>');
    return div.nodes[0];
  }

  group('AttributeInterpolationDirective', () {
    test('updates', () {
      Element div = new Element.html('<div shape="{{myShape}}"></div>');
      Scope s = new Scope({'myShape': 'circle'});
      AttributeInterpolationDirective d = new AttributeInterpolationDirective('shape');
      d.setUp(s, div);
      expect(div.attributes['shape'], 'circle');
      s['myShape'] = 'square';
      expect(div.attributes['shape'], 'square');
    });
  });

  group('scopedBoundDirectives', () {
    DirectiveRegistry reg = new DirectiveRegistry(
      elementDirectives: {'p': [new ElementDirective('testP')]});

    test('empty', () {
      Element appRoot = new Element.html('<div></div>'); // no bound directives
      var sbds = scopedBoundDirectives([appRoot], reg);
      expect(sbds.length, 0);
    });

    test('sets rootScope', () {
      Element appRoot = new Element.html('<p></p>');
      var sbds = scopedBoundDirectives([appRoot], reg);
      expect(sbds.length, 1);
      expect(sbds[0].boundDirective.node.tagName, 'P');
    });
  });

  group('boundDirectives', () {
    DirectiveRegistry reg = new DirectiveRegistry(
      elementDirectives: {'p': [new ElementDirective('testP')]},
      attributeDirectives: {'color': [new AttributeDirective('testColor')]});

    test('tree', () {
        Element appRoot = new Element.html('<div color="red"></div>');
        appRoot.innerHTML = '<p>Hello!</p><br><p color="blue"></p>';
        var bds = boundDirectives([appRoot], reg);
        expect(bds.length, 4);
        expect(bds[0].directive.name, 'testColor');
        expect(bds[0].node.tagName, 'DIV');
        expect(bds[1].directive.name, 'testP');
        expect(bds[1].node.tagName, 'P');
        expect(bds[2].directive.name, 'testP');
        expect(bds[2].node.tagName, 'P');
        expect(bds[3].directive.name, 'testColor');
        expect(bds[3].node.tagName, 'P');
    });
  });

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

    test('text node with bindings', () {
      DirectiveRegistry regWithBind = new DirectiveRegistry(
        attributeDirectives: {'ng-bind': [new AttributeDirective('bind')]});
      Text textNode = textInDiv('Hello, {{ name }}');

      var textDirectives = directives(textNode, regWithBind);
      expect(textDirectives.length, 0);

      var divDirectives = directives(textNode.parent.nodes[1], regWithBind);
      expect(divDirectives[0].name, 'bind');
    });

    test('attributes needing interpolation', () {
      Element e = new Element.html('<p shape="{{myShape}}"></p>');
      var ds = directives(e, new DirectiveRegistry());
      expect(ds.length, 1);
      expect(ds[0] is AttributeInterpolationDirective, reason: '${ds[0]} is not AttributeInterpolationDirective');
      expect(ds[0].name, '_interpolation');
    });
  });

  group('compileBindingsInTextNode', () {
    test('replace {{ ... }} with <span> tag', () {
      Text textNode = textInDiv('Hello, {{ name }}!');
      DivElement div = textNode.parent;
      compileBindingsInTextNode(textNode);

      expect(div.nodes.length, 3);
      expect(div.nodes[0].data, 'Hello, ');
      expect(div.nodes[2].data, '!');

      SpanElement boundElement = div.nodes[1];
      expect(boundElement.nodes.length, 0);
      expect(boundElement.attributes['ng-bind'], 'name');
    });

    test('do not introduce extraneous empty text nodes (except at the beginning)', () {
      // We don't want to remove empty text nodes at the beginning, because we want
      // to be able to iterate over the DOM while we are performing
      // compileBindingsInTextNode operations. If we can guarantee that the operation
      // only adds new DOM nodes that need compilation *after* the current node, then
      // we can just use a straight for-loop instead of having to potentially repeat indices.
      //
      // But removing them at the end is fine.
        
      Text textNode = textInDiv('{{ expr1 }}{{ expr2 }}');
      DivElement div = textNode.parent;
      compileBindingsInTextNode(textNode);

      expect(div.nodes.length, 3);
      expect(div.nodes[0] is Text, reason: '${div.nodes[0]} is not Text');
      expect(div.nodes[0].data, '');
      expect(div.nodes[1].attributes['ng-bind'], 'expr1');
      expect(div.nodes[2].attributes['ng-bind'], 'expr2');
    });

    test('replace multiple bindings in a single text node', () {
      Text textNode = textInDiv('{{ expr1 }} and {{ expr2 }}');
      DivElement div = textNode.parent;
      compileBindingsInTextNode(textNode);

      expect(div.nodes.length, 4);
      expect(div.nodes[0] is Text, reason: '${div.nodes[0]} is not Text');
      expect(div.nodes[0].data, '');
      expect(div.nodes[1].attributes['ng-bind'], 'expr1');
      expect(div.nodes[2].data, ' and ');
      expect(div.nodes[3].attributes['ng-bind'], 'expr2');
    });
  });
}
