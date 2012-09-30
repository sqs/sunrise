RegExp _TextBindingPattern = const RegExp(r"\{\{([^\}]+)\}\}");

void processBindingsInTextNodes(Node node) {
  if (node.$dom_nodeType == Node.TEXT_NODE) {
    Text textNode = node;
    String nodeText = textNode.data;
    
    Iterable<Match> bindingMatches = _TextBindingPattern.allMatches(nodeText);
    for (Match m in bindingMatches) {
      String fullBinding = m.group(0);
      String bindExpr = m.group(1).trim();

      var startPos = nodeText.indexOf(fullBinding);

      // Split the text node right before the binding so we have 2 nodes:
      // * textNode, which contains the normal text leading up to the binding
      // * textNode2, which contains the binding string, followed by the rest of the text
      Text textNode2 = textNode.splitText(startPos);

      // Remove the "{{ ... }}" binding expression from textNode2's text
      textNode2.deleteData(0, fullBinding.length);

      // Insert a new element between textNode and textNode2:
      //   <span ng-bind="<bindExpr>"></span>
      // where <bindExpr> is the expression that was wrapped in {{ ... }}
      SpanElement bindingElement = new SpanElement();
      bindingElement.$dom_setAttribute('ng-bind', bindExpr);
      textNode.parent.insertBefore(bindingElement, textNode2);
    }
  } else {
    for (Node c in node.$dom_childNodes) {
      processBindingsInTextNodes(c);
    }
  }
}

void compileDirectives(Element appRoot) {
  for (Element modelBoundInput in appRoot.queryAll('input[ng-model]')) {
    for (Element boundElement in appRoot.queryAll('[ng-bind="yourName"]')) {
      modelBoundInput.on.input.add((event) {
        String inputValue = modelBoundInput.value;

        // Set the bound element's text data to the new inputValue
        Text newInputValueTextNode = new Text(inputValue);
        if (boundElement.hasChildNodes()) {
          boundElement.$dom_replaceChild(newInputValueTextNode, boundElement.$dom_firstChild);
        } else {
          boundElement.$dom_appendChild(newInputValueTextNode);
        }
      });
    }
  }
}
