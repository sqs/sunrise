typedef HttpRequest HttpRequestFactory();
typedef void HttpClientResponseCallback(HttpRequest request);

class Resource {
  String url;

  final HttpRequestFactory httpRequestFactory;

  Resource(String url, [HttpRequestFactory httpRequestFactory = null])
  : url = url,
    httpRequestFactory = (httpRequestFactory != null) ? httpRequestFactory : (() => new HttpRequest()) {
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
