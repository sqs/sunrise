// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library model;

import '../../lib/sunrise.dart' as sunrise;
import 'package:web_components/watcher.dart' as watcher;

class MainComponent {
  MainComponent();

  bool isVisible(Todo todo) => todo != null &&
      ((showIncomplete && !todo.done) || (showDone && todo.done));

  bool showIncomplete = true;

  bool showDone = true;

  bool get hasElements => app.todos.length > 0;
}

MainComponent _viewModel;
MainComponent get viewModel {
  if (_viewModel == null) {
    _viewModel = new MainComponent();
  }
  return _viewModel;
}

// The real model:

class App {
  sunrise.Resource<Todo> todosResource;
  Collection<Todo> todos;

  App() : todosResource = new sunrise.Resource<Todo>('http://localhost:7001/todos') {
    todos = todosResource.collection;
    todos.onChangeFn = (c) => watcher.dispatch();
    todos.deserializeFn = (Map<String, Object> data) {
      return new Todo(data['task']);
    };
  }
}

class Todo {
  String task;
  bool done = false;

  Todo(this.task);

  String toString() => "$task ${done ? '(done)' : '(not done)'}";
  Object toJson() => {"task": task};
}

App _app;
App get app {
  if (_app == null) {
    _app = new App();
  }
  return _app;
}
