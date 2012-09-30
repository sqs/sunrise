typedef void ScopeKeyChangeListener(String key, Object newValue);

class Scope implements Map<String, Object> {
  Map<String, Object> _data;
  Map<String, List<ScopeKeyChangeListener>> _listeners;

  Scope([data = null]) :
    _data = (data != null) ? data : new Map<String,Object>(),
    _listeners = new Map<String, List<ScopeKeyChangeListener>>() {
  }


  // Partial Map interface

  bool containsKey(String key) => _data.containsKey(key);

  void operator []=(String key, Object newValue) {
    Object currentValue = _data[key];
    if (currentValue != newValue) {
      _data[key] = newValue;
      _didChange(key);
    }
  }

  Object operator [](String key) => _data[key];

  Object remove(String key) {
    _data.remove(key);
    _didChange(key);
  }


  // Listeners

  void addListener(String key, ScopeKeyChangeListener listener) {
    if (!_listeners.containsKey(key)) {
      _listeners[key] = [];
    }
    _listeners[key].add(listener);
  }

  void _didChange(String key) {
    List<ScopeKeyChangeListener> keyListeners = _listeners[key];
    if (keyListeners != null && keyListeners.length > 0) {
      Object newValue = this[key];
      for (ScopeKeyChangeListener listener in keyListeners) {
        listener(key, newValue);
      }
    }
  }
}
