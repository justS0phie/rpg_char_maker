import 'package:flutter/material.dart';

import '../models/option.dart';
import '../models/template.dart';
import '../models/character.dart';

class AbilitiesSection extends StatelessWidget {
  final Template template;
  final Character character;

  const AbilitiesSection({
    super.key,
    required this.template,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    List<OptionAbility> abilities = [];
    final LvlField = template.fields.where((f) {return f.alias == "LVL";}).firstOrNull;
    final level = LvlField != null ? character.values[LvlField.id] ?? 0 : 0;

    for (OptionGroup group in template.optionGroups) {
      CharacterSelection? groupSelections = character.selections.values.where((s) {return s.groupId == group.id;}).firstOrNull;
      if (groupSelections == null) continue;

      for (Option option in group.options) {
        if (groupSelections.optionIds.contains(option.id)){
          abilities.addAll(option.abilities.where((ability) {return level >= ability.levelRequired;}));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Abilities",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ...abilities.map((ability) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ability.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(ability.description),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }
}
