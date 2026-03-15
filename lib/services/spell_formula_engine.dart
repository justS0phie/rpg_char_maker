import '../models/template.dart';
import '../models/character.dart';
import '../services/formula_engine.dart';

String parseDescription(
  String text,
  Character character,
  Template template,
  Map<String, TemplateField> aliasMap
) {
  final regex = RegExp(r'\{(.*?)\}');

  return text.replaceAllMapped(regex, (match) {
    final formula = match.group(1)!;

    try {
      final value = FormulaEngine.evaluate(
        formula,
        character,
        aliasMap,
        template,
      );

      return value.toStringAsFixed(0);
    } catch (_) {
      return "ERR";
    }
  });
}
