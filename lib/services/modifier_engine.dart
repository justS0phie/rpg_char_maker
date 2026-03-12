import '../models/template.dart';
import '../models/character.dart';

class ModifierEngine {

  static Map<String,double> computeModifiers(
      Template template,
      Character character,
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

          modifiers.update(
            effect.fieldId,
                (value) => value + effect.modifier,
            ifAbsent: () => effect.modifier,
          );
        }
      }
    }

    return modifiers;
  }
}