typedef void OnChangeFn(ResourceCollection<T> rc);
typedef void OnLoadFn(ResourceCollection<T> rc);
typedef T DeserializeFn<T>(Object rawData);

class ResourceCollection<T> implements Collection<T> {
  final Resource<T> resource;
  bool loaded = false;
  OnChangeFn onChangeFn = null;
  OnLoadFn onLoadFn = null;
  DeserializeFn<T> deserializeFn = null;

  Collection<T> _collection = [];

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

  void add(T value) {
    _collection.add(value);
    if (onChangeFn != null) {
      onChangeFn(this);
    }
    resource.post(value, null);
  }

  bool every(bool f(T element)) {
    _ensureLoadStarted();
    return _collection.every(f);
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
}
