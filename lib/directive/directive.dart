class Directive {}

class ElementDirective extends Directive {
  final String name;

  ElementDirective(this.name);
}

class AttributeDirective extends Directive {
  final String name;

  AttributeDirective(this.name);
}
