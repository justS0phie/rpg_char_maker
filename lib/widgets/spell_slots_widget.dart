import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/spell.dart';
import '../models/template.dart';
import '../services/formula_engine.dart';

class SpellSlotsWidget extends StatelessWidget {
  final Character character;
  final Template template;
  final VoidCallback onChanged;
  final Map<String, TemplateField> aliasMap;

  const SpellSlotsWidget({
    super.key,
    required this.character,
    required this.template,
    required this.onChanged,
    required this.aliasMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Spell Slots",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ...template.slots.map((slot) {
          double maxSlots = FormulaEngine.evaluate(slot.maxFormula, character, aliasMap, template);

          var usage = character.spellSlotUsage.firstWhere(
            (u) => u.level == slot.level,
            orElse: () {
              final u = SpellSlotUsage(level: slot.level);
              character.spellSlotUsage.add(u);
              return u;
            },
          );

          return Row(
            children: [
              Text(slot.srcLabel.replaceAll("{level}", slot.level.toString())),
              ...List.generate(maxSlots as int, (i) {
                bool used = i < usage.used;

                return IconButton(
                  icon: Icon(
                    used
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onPressed: () {
                    if (used) {
                      usage.used--;
                    } else {
                      usage.used++;
                    }

                    if (usage.used < 0) usage.used = 0;
                    if (usage.used > maxSlots) usage.used = maxSlots as int;

                    onChanged();
                  },
                );
              }),
            ],
          );
        }),
      ],
    );
  }
}
