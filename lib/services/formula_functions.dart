String preprocess(String expression) {
  /// clamp(a,b,c) → min(max(a,b),c)
  expression = expression.replaceAllMapped(
    RegExp(r'clamp\(([^,]+),([^,]+),([^)]+)\)'),
    (m) => 'min(max(${m[1]},${m[2]}),${m[3]})',
  );

  /// min(a,b)
  expression = expression.replaceAllMapped(
    RegExp(r'min\(([^,]+),([^)]+)\)'),
    (m) => '((${m[1]}) + (${m[2]}) - abs((${m[1]}) - (${m[2]}))) / 2',
  );

  /// max(a,b)
  expression = expression.replaceAllMapped(
    RegExp(r'max\(([^,]+),([^)]+)\)'),
    (m) => '((${m[1]}) + (${m[2]}) + abs((${m[1]}) - (${m[2]}))) / 2',
  );

  /// step(x,t) → floor(x/t)
  expression = expression.replaceAllMapped(
    RegExp(r'step\(([^,]+),([^)]+)\)'),
        (m) => 'floor(${m[1]}/${m[2]})',
  );

  return expression;
}
