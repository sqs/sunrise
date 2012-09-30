class InputDirective extends ElementDirective {
  InputDirective() : super('input');

  void setUp(Scope scope, Element element) {
    assert(element.tagName == 'INPUT');
    InputElement inputElement = element;
    String attributeKey = 'ng-model';
    String binding = element.attributes[attributeKey];
    assert(binding != null);
    element.on.input.add((Event event) {
      scope[binding] = inputElement.value;
    });
  }
}
