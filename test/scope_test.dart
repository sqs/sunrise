#library('scope_test');

#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');

TestScope() {
  group('Scope', () {
    test('sets and gets', () {
      Scope s = new Scope();
      s['a'] = 1;
      expect(s['a'], 1);
      s.remove('a');
      expect(s['a'], null);
    });

    test('calls listeners on key changes', () {
      Scope s = new Scope();

      int listener1_calls = 0;
      var listener1 = expectAsync2((key, newVal) {
        expect(key, 'color');
        expect(newVal, listener1_calls == 0 ? 'red' : 'blue');
        listener1_calls++;
      }, count: 2);
      
      int listener2_calls = 0;
      var listener2 = expectAsync2((key, newVal) {
        expect(key, listener2_calls == 0 ? 'color' : 'shape');
        listener2_calls++;
        }, count: 2);

      s.addListener('color', listener1);
      s['color'] = 'red';
      s.addListener('color', listener2);
      s['color'] = 'blue';
      s.addListener('shape', listener2);
      s['shape'] = 'circle';
    });
  });
}
