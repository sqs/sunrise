main() {
  Element appRoot = query('[ng-app]');

  processBindingsInTextNodes(appRoot);
  compileDirectives(appRoot);
}
