import 'package:math_expressions/math_expressions.dart';

import '../models/template.dart';
import '../models/character.dart';

class FormulaEngine {

  static double evaluate(
      TemplateField field,
      Character character,
      Map<String, TemplateField> aliasMap,
      ) {

    if (field.formula == null) {
      return 0;
    }

    String expression = field.formula!;

    final parser = Parser();

    try {

      Expression exp = parser.parse(expression);

      ContextModel context = ContextModel();

      /// assign values for aliases
      aliasMap.forEach((alias, templateField) {

        final value =
            character.values[templateField.id] ?? 0;

        context.bindVariable(
          Variable(alias),
          Number(value.toDouble()),
        );
      });

      final result = exp.evaluate(
        EvaluationType.REAL,
        context,
      );

      return result;

    } catch (e) {

      print("Formula error: $expression");
      print(e);

      return 0;
    }
  }
}