import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/option.dart';
import '../models/template.dart';
import '../models/character.dart';
import 'option_group_widget.dart';

class AbilitiesSection extends StatelessWidget {
  final Template template;
  final Character character;
  final VoidCallback onChanged;

  const AbilitiesSection({
    super.key,
    required this.template,
    required this.character,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    List<OptionAbility> abilities = [];
    final lvlField = template.fields.where((f) {return f.alias == "LVL";}).firstOrNull;
    final level = lvlField != null ? character.values[lvlField.id] ?? 0 : 0;

    for (OptionGroup group in template.optionGroups) {
      Set<String> groupSelections = character.selectionFor(group.id);
      if (groupSelections.isEmpty) continue;

      for (Option option in group.options) {
        if (groupSelections.contains(option.id)){
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

                MarkdownBody(data: ability.description),

                if (ability.optionGroupId != null)
                  OptionGroupWidget(
                    group: template.optionGroups.firstWhere((og) {return og.id == ability.optionGroupId;}),
                    character: character,
                    onChanged: onChanged,
                  )
              ],
            )
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }
}
