import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/spell.dart';
import '../models/template.dart';
import 'spell_slots_widget.dart';

class SpellSection extends StatelessWidget {
  final Character character;
  final VoidCallback onChanged;
  final bool usePreparing;
  final Template template;
  final Map<String, TemplateField> aliasMap;

  const SpellSection({
    super.key,
    required this.character,
    required this.onChanged,
    required this.template,
    required this.usePreparing,
    required this.aliasMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Spells",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        SpellSlotsWidget(
          character: character,
          template: template,
          aliasMap: aliasMap,
          onChanged: onChanged,
        ),

        const SizedBox(height: 20),

        ...character.spells.map((spell) {
          final nameController = TextEditingController(text: spell.name);

          final levelController = TextEditingController(text: spell.level);

          return ExpansionTile(
            title: Row(
              children: [
                usePreparing ? Checkbox(
                  value: spell.prepared,
                  onChanged: (v) {
                    spell.prepared = v ?? false;
                    onChanged();
                  },
                ) : Container(),

                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: "Spell name"),
                    onChanged: (v) {
                      spell.name = v;
                      onChanged();
                    },
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: levelController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: "Lvl"),
                    onChanged: (v) {
                      spell.level = v;
                      onChanged();
                    },
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    character.spells.remove(spell);
                    onChanged();
                  },
                ),
              ],
            ),

            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: TextEditingController(text: spell.description),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Spell description",
                  ),
                  onChanged: (v) {
                    spell.description = v;
                    onChanged();
                  },
                ),
              ),
            ],
          );
        }),

        const SizedBox(height: 10),

        ElevatedButton(
          onPressed: () {
            character.spells.add(
              Spell(id: DateTime.now().toString(), name: ""),
            );
            onChanged();
          },
          child: const Text("Add Spell"),
        ),
      ],
    );
  }
}
