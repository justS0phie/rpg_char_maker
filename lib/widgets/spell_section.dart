import 'package:char_sheet_maker/widgets/spell_slots_widget.dart';
import 'package:flutter/material.dart';

import '../models/template.dart';
import '../models/character.dart';
import '../models/spell.dart';

class SpellSection extends StatefulWidget {
  final Template template;
  final Character character;
  final VoidCallback onChanged;
  final bool usePreparing;
  final Map<String, TemplateField> aliasMap;

  const SpellSection({
    super.key,
    required this.template,
    required this.character,
    required this.onChanged,
    required this.usePreparing,
    required this.aliasMap,
  });

  @override
  State<SpellSection> createState() => _SpellSectionState();
}

class _SpellSectionState extends State<SpellSection> {
  String? selectedSpellId;

  List<Spell> _getAvailableSpells() {
    final selectedOptions = widget.character.selections.values
        .expand((s) => s.optionIds)
        .toSet();

    return widget.template.spells.where((spell) {
      if (spell.requiredOptions.isEmpty) {
        return true;
      }

      return spell.requiredOptions.any((opt) => selectedOptions.contains(opt));
    }).toList();
  }

  Spell _getSpellById(String id) {
    return widget.template.spells.firstWhere((s) => s.id == id);
  }

  void _addSpell() {
    if (selectedSpellId == null) return;
    widget.character.spells.add(selectedSpellId!);
    selectedSpellId = null;
    widget.onChanged();
    setState(() {});
  }

  void _removeSpell(int index) {
    widget.character.spells.removeAt(index);
    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final availableSpells = _getAvailableSpells();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const Text(
          "Spells",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        SpellSlotsWidget(
          character: widget.character,
          template: widget.template,
          aliasMap: widget.aliasMap,
          onChanged: widget.onChanged,
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: selectedSpellId,
                hint: const Text("Select spell"),
                isExpanded: true,
                items: availableSpells.map((spell) {
                  return DropdownMenuItem(
                    value: spell.id,
                    child: Text("${spell.name} (Lv ${spell.level})"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSpellId = value;
                  });
                },
              ),
            ),

            const SizedBox(width: 10),

            ElevatedButton(onPressed: _addSpell, child: const Text("Add")),
          ],
        ),

        const SizedBox(height: 20),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.character.spells.length,
          itemBuilder: (context, index) {
            final charSpell = widget.character.spells[index];

            final spell = _getSpellById(charSpell);

            return Card(
              child: ListTile(
                title: Text(spell.name),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Level ${spell.level}"),
                    const SizedBox(height: 4),
                    Text(spell.description),
                  ],
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeSpell(index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
