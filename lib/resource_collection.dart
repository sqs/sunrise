typedef void OnLoadFn(ResourceCollection<T> rc);

class ResourceCollection<T> implements Collection<T> {
  final Resource<T> resource;
  bool loaded = false;

  OnLoadFn _onLoadFn = null;
  Collection<T> _collection = [];

  ResourceCollection(this.resource);

  void onLoad(void onLoadFn(ResourceCollection<T> rc)) {
    _onLoadFn = onLoadFn;
  }

  void _ensureLoadStarted() {
    if (loaded == false) {
      _load();
    }
  }

  void _load() {
    resource.query({}, (data) {
      _collection = data;
      loaded = true;
      if (_onLoadFn != null) {
        _onLoadFn(this);
      }
    });
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
