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
      break;
  }

  return _directives;
}

RegExp _TextBindingPattern = const RegExp(r"\{\{([^\}]+)\}\}");

void processBindingsInTextNodes(Node node) {
  if (node.$dom_nodeType == Node.TEXT_NODE) {
    Text textNode = node;

    Match m;
    while (textNode.parent != null && (m = _TextBindingPattern.firstMatch(textNode.data)) != null) {
      String fullBinding = m.group(0);
      String bindExpr = m.group(1).trim();

      var startPos = textNode.data.indexOf(fullBinding);
      var endPos = startPos + fullBinding.length;

      if (startPos == 0) {
         // The binding appears at the beginning of the text node. No action needed.
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
      bindingElement.$dom_setAttribute('ng-bind', bindExpr);
      textNode.parent.insertBefore(bindingElement, textNode);

      if (textNode.data.length == 0) {
          textNode.remove();
      }
    }
  } else {
    for (Node c in node.$dom_childNodes) {
      processBindingsInTextNodes(c);
    }
  }
}
