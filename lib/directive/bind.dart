class BindDirective extends AttributeDirective {
  BindDirective() : super('bind');

  void setUp(Scope scope, Element element) {
    String attributeKey = 'ng-bind';
    String binding = element.attributes[attributeKey];
    assert(binding != null);
    scope.addListener(binding, (_, value) {
      element.innerHTML = value;
    });
  }
}
