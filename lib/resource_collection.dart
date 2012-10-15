typedef void OnChangeFn(ResourceCollection<T> rc);
typedef void OnLoadFn(ResourceCollection<T> rc);
typedef T DeserializeFn<T>(Object rawData);
typedef Object SerializeFn<T>(T modelObj);

class ResourceCollection<T> implements List<T> {
  final Resource<T> resource;
  bool loaded = false;
  OnChangeFn onChangeFn = null;
  OnLoadFn onLoadFn = null;
  DeserializeFn<T> deserializeFn = null;
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
      _collection = data.map((e) => (deserializeFn != null) ? deserializeFn(e) : e);
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

  Iterator<T> iterator() {
    _ensureLoadStarted();
    return _collection.iterator();
  }

  Collection map(f(T element)) {
    _ensureLoadStarted();
    return _collection.map(f);
  }
}
