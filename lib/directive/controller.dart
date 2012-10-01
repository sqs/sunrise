class ControllerDirective extends ElementDirective {
  ControllerDirective() : super('controller');

  void setUp(Scope scope, Element controllerRootElement) {
    String attributeKey = 'ng-controller';
    String controllerName = controllerRootElement.attributes[attributeKey];
    assert(controllerName != null);

    scope['__controllerName'] = controllerName;

    Future<Controller> ctrlFuture = _newControllerFromName(controllerName);
    ctrlFuture.then((Controller ctrl) {
      ctrl.scope = scope;
      ctrl.init();
    });
  }
}

Future<Controller> _newControllerFromName(String ctrlName) {
  final ms = currentMirrorSystem();

  var library;
  String ctrlClassName;
  if (ctrlName.contains('.')) {
    int dotIndex = ctrlName.indexOf('.');
    String libraryName = ctrlName.substring(0, dotIndex);
    ctrlClassName = ctrlName.substring(dotIndex + 1);
    library = ms.libraries[libraryName];
    if (library == null) {
      throw 'Library "$libraryName" for controller "$ctrlName" not found';
    }
  } else {
    library = ms.isolate.rootLibrary;
    ctrlClassName = ctrlName;
  }

  ClassMirror ctrlCM = library.classes[ctrlClassName];
  if (ctrlCM == null) {
     throw 'Controller class "${ctrlClassName}" not found in library "${library.qualifiedName}"';
  }

  Completer completer = new Completer();

  Future<InstanceMirror> f = ctrlCM.newInstance('', []);
  f.then((InstanceMirror ctrlIM) {
    Controller ctrl = ctrlIM.reflectee;
    completer.complete(ctrl);
  });
  f.handleException((exception) {
    completer.completeException(exception);
    return true;
  });

  return completer.future;
}
