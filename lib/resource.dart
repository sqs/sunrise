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
    HttpRequest r = _makeHttpRequest(onSuccess);
    r..open('GET', url, true)
     ..send();
  }

  void get(Map<String, String> params, void onSuccess(Object data)) {
    HttpRequest r = _makeHttpRequest(onSuccess);
    r..open('GET', _singleItemUrl(params), true)
     ..send();
  }

  void post(Object data, void onSuccess(Object data)) {
    HttpRequest r = _makeHttpRequest(onSuccess);
    r..open('POST', url, true)
     ..send();
  }

  void put(Map<String, String> params, Object data, void onSuccess(Object data)) {
    HttpRequest r = _makeHttpRequest(onSuccess);
    r..open('PUT', _singleItemUrl(params), true)
     ..send();
  }

  void delete(Map<String, String> params, void onSuccess(Object data)) {
    HttpRequest r = _makeHttpRequest(onSuccess);
    r..open('DELETE', _singleItemUrl(params), true)
     ..send();
  }

  String _singleItemUrl(Map<String, String> params) => "$url/${params['id']}";

  HttpRequest _makeHttpRequest(void onSuccess(Object data)) {
    HttpRequest request = httpRequestFactory();

    request.on.load.add((event) {
      Object data = JSON.parse(request.responseText);
      if (onSuccess != null) {
        onSuccess(data);
      }
    });
    request.on.error.add((event) {
      window.console.error('HttpRequest error: ${event}');
    });

    return request;
  }
}
