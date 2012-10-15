import 'dart:json';
import 'package:synth/synth.dart';

main() {
  use(logPath);
  use(reqJsonContent);

  route('GET', '/todos', (req, res)
    => res.write(JSON.stringify(todos)));

  route('GET', '/todos/:id', (req, res) {
    var id = int.parse(req.path.split('/')[2]);
    res.write(JSON.stringify(getTodoById(id)));
  });

  route('POST', '/todos', (req, res) {
    var todoData = req.dataObj as Map;
    var newTodo = new Todo(todos.length + 1, todoData['task']);
    todos.add(newTodo);
    res.write(JSON.stringify(newTodo));
  });

  route('OPTIONS', '/todos', (req, res) {
    // TODO
    res.write('todo');
  });

  start(7001);
  print('Listening on port 7001');
}

class Todo {
  int id;
  String task;
  Todo(this.id, this.task);

  Object toJson() => {"id": id, "task": task};
}

List<Todo> todos = [
  new Todo(1, "Walk the dog"),
];

Todo getTodoById(int id) => todos.filter((t) => t.id == id)[0];
