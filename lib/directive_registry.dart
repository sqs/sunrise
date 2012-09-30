class DirectiveRegistry {
  final Map<String, List<ElementDirective>> _elementDirectives;
  final Map<String, List<AttributeDirective>> _attributeDirectives;

  DirectiveRegistry([elementDirectives = null, attributeDirectives = null]) :
    _elementDirectives   = (elementDirectives != null)   ? elementDirectives   : {},
    _attributeDirectives = (attributeDirectives != null) ? attributeDirectives : {} {
  }

  List<ElementDirective> elementDirectives(String elementTagName) {
    elementTagName = elementTagName.toLowerCase();
    if (_elementDirectives.containsKey(elementTagName)) {
      return _elementDirectives[elementTagName];
    } else {
      return [];
    }
  }

  List<AttributeDirective> attributeDirectives(String attributeKey) {
    if (_attributeDirectives.containsKey(attributeKey)) {
      return _attributeDirectives[attributeKey];
    } else {
      return [];
    }
  }
}
