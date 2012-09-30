RegExp _TextBindingPattern = const RegExp(r"\{\{([^\}]+)\}\}");

bool stringHasExpressionsToInterpolate(String string) {
  return _TextBindingPattern.hasMatch(string);
}

Set<String> interpolationExpressions(String string) {
  return new Set.from(_TextBindingPattern.allMatches(string).map((m) => m.group(1).trim()));
}

String interpolateString(String string, Scope scope) {
  int netCharactersAdded = 0;
  for (Match m in _TextBindingPattern.allMatches(string)) {
    String fullBinding = m.group(0);
    String bindExpr = m.group(1).trim();

    var anyVal = scope[bindExpr];
    if (anyVal == null) { anyVal = ""; }
    String val = anyVal.toString();

    int startPos = m.start();
    string = '${string.substring(0, startPos + netCharactersAdded)}'
             '${val}'
             '${string.substring(startPos + fullBinding.length + netCharactersAdded)}';
    netCharactersAdded += (val.length - fullBinding.length);
  }
  return string;
}
