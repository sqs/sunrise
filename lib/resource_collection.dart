typedef void OnChangeFn(ResourceCollection<T> rc);
typedef void OnLoadFn(ResourceCollection<T> rc);

class ResourceCollection<T> implements Collection<T> {
  final Resource<T> resource;
  bool loaded = false;
  OnChangeFn onChangeFn = null;
  OnLoadFn onLoadFn = null;

  Collection<T> _collection = [];

  ResourceCollection(this.resource);

  void _ensureLoadStarted() {
    if (loaded == false) {
      _load();
    }
  }

  void _load() {
    resource.query({}, (data) {
      _collection = data;
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

  int get length {
    _ensureLoadStarted();
    return _collection.length;
  }

  Iterator<T> iterator() {
    _ensureLoadStarted();
    return _collection.iterator();
  }
}
