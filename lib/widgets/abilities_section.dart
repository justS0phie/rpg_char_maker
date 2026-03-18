import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/option.dart';
import '../models/template.dart';
import '../models/character.dart';
import '../services/spell_formula_engine.dart';
import 'option_group_widget.dart';

class AbilitiesSection extends StatelessWidget {
  final Template template;
  final Character character;
  final VoidCallback onChanged;
  final Map<String, TemplateField> aliasMap;
  final TemplateSection section;

  const AbilitiesSection({
    super.key,
    required this.template,
    required this.character,
    required this.onChanged,
    required this.aliasMap,
    required this.section,
  });

  String getAbilityDescription(OptionAbility ability) {
    Map<String, String> translations = {};
    String finalMsg = ability.description;

    for (String level in ability.modifiers.keys) {
      if ((character.values[aliasMap["LVL"]?.id] ?? 0) < int.tryParse(level)!) {
        continue;
      }
      for (String transKey in ability.modifiers[level].keys) {
        translations[transKey] = ability.modifiers[level][transKey];
      }
    }

    for (String translation in translations.keys) {
      finalMsg = finalMsg.replaceAll(
        "{$translation}",
        translations[translation]!,
      );
    }
    return finalMsg;
  }

  @override
  Widget build(BuildContext context) {
    List<OptionAbility> abilities = [];
    final lvlField = template.fields.where((f) {
      return f.alias == "LVL";
    }).firstOrNull;
    final level = lvlField != null ? character.values[lvlField.id] ?? 0 : 0;

    for (OptionGroup group in template.optionGroups) {
      Set<String> groupSelections = character.selectionFor(group.id);
      if (groupSelections.isEmpty) continue;

      for (Option option in group.options) {
        if (groupSelections.contains(option.id)) {
          abilities.addAll(
            option.abilities.where((ability) {
              return level >= ability.levelRequired;
            }),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ...abilities.sorted((a, b) => a.levelRequired.compareTo(b.levelRequired)).map((ability) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ability.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                MarkdownBody(
                  data: parseDescription(
                    getAbilityDescription(ability),
                    character,
                    template,
                    aliasMap,
                  ),
                ),
                const SizedBox(height: 10),

                if (ability.optionGroupId != null)
                  OptionGroupWidget(
                    group: template.optionGroups.firstWhere((og) {
                      return og.id == ability.optionGroupId;
                    }),
                    character: character,
                    onChanged: onChanged,
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }
}
