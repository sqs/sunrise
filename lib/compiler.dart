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

void compileDirectives(Element appRoot) {
  for (Element modelBoundInput in appRoot.queryAll('input[ng-model]')) {
    String modelExpr = modelBoundInput.attributes['ng-model'];
    // TODO: escape modelExpr before using it in the queryAll selector
    for (Element boundElement in appRoot.queryAll('[ng-bind="${modelExpr}"]')) {
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

  final mainLib = currentMirrorSystem().isolate.rootLibrary;
  for (Element controllerRootElement in appRoot.queryAll('[ng-controller]')) {
    String ctrlClassName = controllerRootElement.attributes['ng-controller'];
    ClassMirror ctrlCM = mainLib.classes[ctrlClassName];
    if (ctrlCM == null) {
      throw 'Controller class "${ctrlClassName}" not found in main library "${mainLib.qualifiedName}"';
    }
    ctrlCM.newInstance('', []).then((InstanceMirror ctrlIM) {
      Controller ctrl = ctrlIM.reflectee;
      ctrl.rootElement = controllerRootElement;
    });
  }
}
