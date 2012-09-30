#library('interpolation_test');

#import('package:sunrise/sunrise.dart');
#import('package:unittest/unittest.dart');

TestInterpolation() {
  group('Interpolation', () {
    test('stringHasExpressionsToInterpolate', () {
      void expectHasExpressionsToInterpolate(String string, bool expectHasExpressions) {
        expect(stringHasExpressionsToInterpolate(string), expectHasExpressions,
               reason: 'expected "${string}" to ${expectHasExpressions ? "" : "not "}'
                       'have expressions to interpolate');
      }

      expectHasExpressionsToInterpolate('{{ name }}', true);
      expectHasExpressionsToInterpolate('Hello, {{name}}!', true);
      expectHasExpressionsToInterpolate('{{{name}}}', true);
      expectHasExpressionsToInterpolate("{{name\n}}", true);

      expectHasExpressionsToInterpolate('{name}', false);
      expectHasExpressionsToInterpolate('{{name', false);
      expectHasExpressionsToInterpolate('{ {name}}', false);
      expectHasExpressionsToInterpolate('{{name} }', false);
      expectHasExpressionsToInterpolate('name', false);
    });

    test('interpolationExpressions', () {
        expect(interpolationExpressions(''), new Set());
        expect(interpolationExpressions('abc'), new Set());
        expect(interpolationExpressions('{{ a }} {{b}} {{c.d}} z'), new Set.from(['a', 'b', 'c.d']));
    });

    test('interpolateString', () {
      Scope s = new Scope({'color': 'red', 'size': 10, 'nested': '{{size}}'});
      expect(interpolateString('', s), '');
      expect(interpolateString('a', s), 'a');
      expect(interpolateString('{{ color }}', s), 'red');
      expect(interpolateString('{{size}}', s), '10');
      expect(interpolateString('a {{size}} a', s), 'a 10 a');
      expect(interpolateString('{{ color }} {{size}}', s), 'red 10');
      expect(interpolateString('{{ color  }} {{  color }}', s), 'red red');
      expect(interpolateString(' {{color}}{{size}} ', s), ' red10 ');
      expect(interpolateString('{{doesnotexist}} {{size}}', s), ' 10');
      expect(interpolateString('{{nested}}', s), '{{size}}');
    });
  });
}
