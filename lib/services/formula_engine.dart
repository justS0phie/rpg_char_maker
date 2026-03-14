import 'package:math_expressions/math_expressions.dart';

import '../models/option.dart';
import '../models/template.dart';
import '../models/character.dart';
import 'formula_functions.dart';
import 'modifier_engine.dart';

class FormulaEngine {

  static double evaluate(
      TemplateField field,
      Character character,
      Map<String, TemplateField> aliasMap,
      Template template
      ) {

    if (field.formula == null) {
      return 0;
    }

    String expression = field.formula!;

    final parser = GrammarParser();

    try {
      expression = preprocess(expression);
      Expression exp = parser.parse(expression);

      ContextModel context = ContextModel();

      /// assign values for aliases
      aliasMap.forEach((alias, templateField) {

        final value =
            character.values[templateField.id] ?? 0;

        // Add option effects modifiers
        final modifiers = ModifierEngine.computeModifiers(template, character);
        final bonus = modifiers[alias] ?? 0;
        final modifiedValue = value + bonus;

        context.bindVariable(
          Variable(alias),
          Number(modifiedValue.toDouble()),
        );
      });

      for (OptionGroup group in template.optionGroups) {
        CharacterSelection? groupSelections = character.selections.values.where((s) {return s.groupId == group.id;}).firstOrNull;
        if (groupSelections == null) continue;

        for (Option option in group.options) {
          final variableName = "${group.name.toLowerCase()}_${option.name.toLowerCase()}";
          context.bindVariable(
            Variable(variableName),
            Number(groupSelections.optionIds.contains(option.id) ? 1 : 0),
          );
        }
      }

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