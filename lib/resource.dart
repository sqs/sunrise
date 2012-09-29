typedef void HttpClientResponseCallback(HttpClientResponse response);

class Resource {
  String url;

  final HttpClient httpClient;

  Resource(String url, [HttpClient httpClient = null])
  : url = url,
    httpClient = ((httpClient != null) ? httpClient : new HttpClient()) {
  }

  void query(Map<String, String> params, void onSuccess(Object data)) {
    HttpClientConnection clientConn = httpClient.get('localhost', 9000, url);
    clientConn.onResponse = _makeResponseHandler(onSuccess);
  }

  void get(Map<String, String> params, void onSuccess(Object data)) {
    String id = params['id'];
    HttpClientConnection clientConn = httpClient.get('localhost', 9000, '${url}/${id}');
    clientConn.onResponse = _makeResponseHandler(onSuccess);
  }

  HttpClientResponseCallback _makeResponseHandler(void onSuccess(Object data)) {
    return (HttpClientResponse response) {
      StringInputStream stream = new StringInputStream(response.inputStream);
      StringBuffer body = new StringBuffer();
      stream.onData = () {
        body.add(stream.read());
      };
      stream.onClosed = () {
        Object data = JSON.parse(body.toString());
        onSuccess(data);
      };
    };
  }
}
