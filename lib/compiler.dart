void compile(Element appRoot, DirectiveRegistry registry) {
  List<ScopedBoundDirective> sbds = scopedBoundDirectives([appRoot], registry);
  for (ScopedBoundDirective sbd in sbds) {
    sbd.boundDirective.directive.setUp(sbd.scope, sbd.boundDirective.node);
  }
}

class ScopedBoundDirective {
  final BoundDirective boundDirective;
  final Scope scope;

  ScopedBoundDirective(this.boundDirective, this.scope);
}

List<ScopedBoundDirective> scopedBoundDirectives(List<Node> nodeList, DirectiveRegistry registry) {
  Scope rootScope = new Scope();
  return boundDirectives(nodeList, registry).map((bd) => new ScopedBoundDirective(bd, rootScope));
}

class BoundDirective {
  final Directive directive;
  final Node node;
  
  BoundDirective(this.directive, this.node);
}

List<BoundDirective> boundDirectives(List<Node> nodeList, DirectiveRegistry registry) {
  List<BoundDirective> _boundDirectives = [];

  for (var i = 0; i < nodeList.length; i++) {
    // Always refer to this node as nodeList[i], since it could be replaced beneath us

    List<Directive> directives = directives(nodeList[i], registry);

    _boundDirectives.addAll(directives.map((d) => new BoundDirective(d, nodeList[i])));

    _boundDirectives.addAll(boundDirectives(nodeList[i].nodes, registry));
  }

  return _boundDirectives;
}

List<Directive> directives(Node node, DirectiveRegistry registry) {
  List<Directive> _directives = [];

  switch(node.$dom_nodeType) {
    case Node.ELEMENT_NODE:
      Element elem = node;

      _directives.addAll(registry.elementDirectives(elem.tagName));

      for (String attributeKey in elem.attributes.getKeys()) {
        _directives.addAll(registry.attributeDirectives(attributeKey));
      }

      break;
    case Node.TEXT_NODE:
      compileBindingsInTextNode(node as Text);
      break;
  }

  return _directives;
}

RegExp _TextBindingPattern = const RegExp(r"\{\{([^\}]+)\}\}");

/// Compile bindings in DOM text nodes such as:
///   Hello, {{ name }}!
/// to the equivalent explicit form:
///   Hello, <span ng-bind="name"></span>!
void compileBindingsInTextNode(Text textNode) {
  Match m;
  bool isFirstMatch = true;
  while ((m = _TextBindingPattern.firstMatch(textNode.data)) != null) {
    String fullBinding = m.group(0);
    String bindExpr = m.group(1).trim();
  
    var startPos = textNode.data.indexOf(fullBinding);
    var endPos = startPos + fullBinding.length;
  
    if (startPos == 0 && isFirstMatch == false) {
      // The binding appears at the beginning of the text node. No action needed.
      //
      // The isFirstMatch check ensures we leave a text node (even if it's empty)
      // at the original position of this function's argument. This lets us use
      // a simple for-loop to forward iterate through the DOM while we perform
      // this operation. See compiler_test.dart for more info.
    } else {
      // Split the text node right before the binding so we have 2 nodes:
      // * one text node which contains the normal text leading up to the binding
      // * one text node that contains the binding string, followed by the rest of the text
      textNode = textNode.splitText(startPos);
    }
  
    // Remove the "{{ ... }}" binding expression from textNode's text
    textNode.deleteData(0, fullBinding.length);
  
    // Insert a new element at the beginning of textNode:
    //   <span ng-bind="<bindExpr>"></span>
    // where <bindExpr> is the expression that was wrapped in {{ ... }}
    SpanElement bindingElement = new SpanElement();
    bindingElement.attributes['ng-bind'] = bindExpr;
    textNode.parent.insertBefore(bindingElement, textNode);
  
    if (textNode.data.length == 0) {
      textNode.remove();
    }

    isFirstMatch = false;
  }
}
