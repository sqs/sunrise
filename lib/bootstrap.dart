main() {
  Element appRoot = query('[ng-app]');

  processBindingsInTextNodes(appRoot);
  compile(appRoot, DirectiveRegistry.defaultRegistry());
}
