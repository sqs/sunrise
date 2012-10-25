typedef void OnChangeFn(ResourceCollection rc);
typedef void OnLoadFn(ResourceCollection rc);
typedef Map<String, String> IdParamsFn<T>(T modelObj);
typedef T DeserializeFn<T>(Object rawSingleObjectData);
typedef T DeserializeListFn<T>(Object rawData);
typedef Object SerializeFn<T>(T modelObj);

class ResourceCollection<T> implements List<T> {
  final Resource<T> resource;
  bool loaded = false;
  OnChangeFn onChangeFn = null;
  OnLoadFn onLoadFn = null;
  IdParamsFn<T> idParamsFn = null;
  DeserializeFn<T> deserializeFn = null;
  DeserializeListFn<T> deserializeListFn = null;
  SerializeFn<T> serializeFn = JSON.stringify;

  List<T> _collection = [];
  List<T> get collection => new List.from(_collection);

  ResourceCollection(this.resource);

  void _ensureLoadStarted() {
    if (loaded == false) {
      _load();
    }
  }

  void _load() {
    resource.query({}, (data) {
      List<T> objs = (deserializeListFn != null) ? deserializeListFn(data) : data;
      _collection = (deserializeFn != null) ? objs.map(deserializeFn) : objs;
      loaded = true;
      if (onLoadFn != null) {
        onLoadFn(this);
      }
      if (onChangeFn != null) {
        onChangeFn(this);
      }
    });
  }

  T operator [](int index) {
    _ensureLoadStarted();
    return _collection[index];
  }

  void add(T value) {
    _collection.add(value);
    if (onChangeFn != null) {
      onChangeFn(this);
    }
    resource.post(serializeFn(value), null);
  }

  bool every(bool f(T element)) {
    _ensureLoadStarted();
    return _collection.every(f);
  }

  Collection<T> filter(bool f(T element)) {
    _ensureLoadStarted();
    return _collection.filter(f);
  }

  void forEach(void f(T element)) {
    _ensureLoadStarted();
    _collection.forEach(f);
  }

  int get length {
    _ensureLoadStarted();
    return _collection.length;
  }

  int indexOf(T element, [int start = 0]) {
    _ensureLoadStarted();
    return _collection.indexOf(element, start);
  }

  bool isEmpty() {
    _ensureLoadStarted();
    return _collection.isEmpty();
  }

  Iterator<T> iterator() {
    _ensureLoadStarted();
    return _collection.iterator();
  }

  Collection map(f(T element)) {
    _ensureLoadStarted();
    return _collection.map(f);
  }

  T removeAt(int index) {
    T removedElement = _collection.removeAt(index);
    if (onChangeFn != null) {
      onChangeFn(this);
    }
    resource.delete(idParamsFn(removedElement), null);
  }

  String toString() {
    return _collection.toString();
  }
}
