import 'package:math_expressions/math_expressions.dart';

import '../models/option.dart';
import '../models/template.dart';
import '../models/character.dart';
import 'formula_functions.dart';
import 'modifier_engine.dart';

class FormulaEngine {

  static double evaluate(
      String? expression,
      Character character,
      Map<String, TemplateField> aliasMap,
      Template template
      ) {

    if (expression == null) {
      return 0;
    }

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
        final modifiers = ModifierEngine.computeModifiers(template, character, aliasMap);
        final bonus = modifiers[alias] ?? 0;
        final modifiedValue = value + bonus;

        context.bindVariable(
          Variable(alias),
          Number(modifiedValue.toDouble()),
        );
      });

      for (OptionGroup group in template.optionGroups) {
        Set<String> groupSelections = character.selectionFor(group.id);
        if (groupSelections.isEmpty) continue;

        for (Option option in group.options) {
          final variableName = "${(group.alias ?? group.name).toLowerCase()}_${(option.alias ?? option.name).toLowerCase()}";
          context.bindVariable(
            Variable(variableName),
            Number(groupSelections.contains(option.id) ? 1 : 0),
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

  static double safeEvaluate(
      String? expression,
      Character character,
      Map<String, TemplateField> aliasMap,
      Template template
      ) {

    if (expression == null) {
      return 0;
    }

    final parser = GrammarParser();

    try {
      expression = preprocess(expression);
      Expression exp = parser.parse(expression);

      ContextModel context = ContextModel();

      /// assign values for aliases
      aliasMap.forEach((alias, templateField) {

        final value =
            character.values[templateField.id] ?? 0;

        context.bindVariable(
          Variable(alias),
          Number(value),
        );
      });

      for (OptionGroup group in template.optionGroups) {
        Set<String> groupSelections = character.selectionFor(group.id);
        if (groupSelections.isEmpty) continue;

        for (Option option in group.options) {
          final variableName = "${group.name.toLowerCase()}_${option.name.toLowerCase()}";
          context.bindVariable(
            Variable(variableName),
            Number(groupSelections.contains(option.id) ? 1 : 0),
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