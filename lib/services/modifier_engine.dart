import '../models/template.dart';
import '../models/character.dart';
import 'formula_engine.dart';

class ModifierEngine {

  static Map<String,double> computeModifiers(
      Template template,
      Character character,
      Map<String, TemplateField> aliasMap,
      ) {
    Map<String,double> modifiers = {};

    for (final group in template.optionGroups) {
      final selection =
      character.selections[group.id];

      if (selection == null) continue;

      for (final optionId in selection.optionIds) {
        final option = group.options
            .firstWhere((o) => o.id == optionId);
        for (final effect in option.effects) {

          final modifier = FormulaEngine.evaluate(
            effect.formula,
            character,
            aliasMap,
            template,
          );

          modifiers.update(
            effect.fieldAlias,
                (value) => value + modifier,
            ifAbsent: () => modifier,
          );
        }
      }
    }

    for (var item in character.equipment) {
      if (!item.equipped) continue;
      item.modifiers.forEach((fieldId, value) {
        modifiers[fieldId] =
            (modifiers[fieldId] ?? 0) + value;
      });
    }

    return modifiers;
  }
}