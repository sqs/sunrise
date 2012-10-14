typedef HttpRequest HttpRequestFactory();
typedef void HttpClientResponseCallback(HttpRequest request);

class Resource<T> {
  String url;

  ResourceCollection<T> collection;

  final HttpRequestFactory httpRequestFactory;

  Resource(String url, [HttpRequestFactory httpRequestFactory = null])
  : url = url,
    httpRequestFactory = (httpRequestFactory != null) ? httpRequestFactory : (() => new HttpRequest()) {
    collection = new ResourceCollection<T>(this);
  }

  void query(Map<String, String> params, void onSuccess(Object data)) {
    HttpRequest r = httpRequestFactory();
    _addResponseHandler(r, onSuccess);

    r.open('GET', url, true);
    r.send();
  }

  void get(Map<String, String> params, void onSuccess(Object data)) {
    HttpRequest r = httpRequestFactory();
    _addResponseHandler(r, onSuccess);

    String id = params['id'];
    String getUrl = '${url}/${id}';

    r.open('GET', url, true);
    r.send();
  }

  void _addResponseHandler(HttpRequest request, void onSuccess(Object data)) {
    request.on.load.add((event) {
      Object data = JSON.parse(request.responseText);
      onSuccess(data);
    });
    request.on.error.add((event) {
      window.console.error('HttpRequest error: ${event}');
    });
  }
}

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
