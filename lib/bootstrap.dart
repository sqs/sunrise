main() {
  Element appRoot = query('[ng-app]');

  compile(appRoot, DirectiveRegistry.defaultRegistry());
}
