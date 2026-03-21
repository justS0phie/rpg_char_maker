import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/template.dart';
import '../models/character.dart';
import '../models/spell.dart';
import '../services/spell_formula_engine.dart';
import '../services/template_service.dart';

class SpellSection extends StatefulWidget {
  final Template template;
  final Character character;
  final VoidCallback onChanged;
  final bool usePreparing;
  final TemplateSection section;
  final Map<String, TemplateField> aliasMap;

  const SpellSection({
    super.key,
    required this.template,
    required this.character,
    required this.onChanged,
    required this.usePreparing,
    required this.section,
    required this.aliasMap,
  });

  @override
  State<SpellSection> createState() => _SpellSectionState();
}

class _SpellSectionState extends State<SpellSection> {
  String? selectedSpellId;
  Map<String, bool> expandedSpells = {};
  bool spellsLoaded = false;

  List<TemplateSpellSlot> _getAvailableSlots() {
    return getAvailableSlotsForChar(
      widget.template,
      widget.character,
      widget.aliasMap,
    );
  }

  List<Spell> _getAvailableSpells() {
    final selectedOptions = widget.character.selections.values
        .expand((s) => s)
        .toSet();

    final TemplateSpellSlot? lastSlot = _getAvailableSlots().lastOrNull;
    num maxSlot = lastSlot != null ? lastSlot.level : 0;

    List<Spell> filtered = widget.template.spells.where((spell) {
      if (spell.level > maxSlot) {
        return false;
      }
      if (spell.requiredOptions.isEmpty) {
        return true;
      }

      return spell.requiredOptions.any((opt) => selectedOptions.contains(opt));
    }).toList();
    filtered.sort((a, b) {
      int lvlCmp = a.level.compareTo(b.level);
      if (lvlCmp != 0) {
        return lvlCmp;
      }
      return a.name.compareTo(b.name);
    });
    return filtered;
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

  Future<void> ensureOptionsLoaded() async {

    if (widget.template.spells.isNotEmpty) {
      if (!spellsLoaded) {
        setState(() {
          spellsLoaded = true;
        });
      }
      return;
    }

    final spells =
    await TemplateService()
        .loadSpells(widget.template.id);

    setState(() {
      spellsLoaded = true;
      widget.template.spells = spells;
    });
  }

  @override
  Widget build(BuildContext context) {
    ensureOptionsLoaded();

    if (!spellsLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    final availableSpells = _getAvailableSpells();
    final List<Spell> sortedSpells =
        widget.character.spells.map((cs) => _getSpellById(cs)).toList()
          ..sort((a, b) {
            final levelCompare = a.level.compareTo(b.level);

            if (levelCompare != 0) {
              return levelCompare;
            }

            return a.name.compareTo(b.name);
          });

    final Map<String, List<Spell>> spellsByLevel = {};
    final Map<int, TemplateSpellSlot> slotsByLevel = {};

    for (var slot in _getAvailableSlots()) {
      slotsByLevel[slot.level] = slot;
      for (int index in Iterable.generate(slot.level)) {
        slotsByLevel.putIfAbsent(index, () => slot);
      }
    }

    for (var spell in sortedSpells) {
      TemplateSpellSlot currSlot = slotsByLevel[spell.level]!;
      final srcLevel = currSlot.srcLabel.replaceAll(
        "{level}",
        currSlot.level.toString(),
      );
      spellsByLevel.putIfAbsent(srcLevel, () => []);
      spellsByLevel[srcLevel]!.add(spell);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.section.name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

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

        Column(
          children: spellsByLevel.entries.map((entry) {
            final level = entry.key;
            final spells = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Text(
                  level,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                ...spells.map((spell) {
                  return Card(
                    key: Key(spell.id),
                    child: ExpansionTile(
                      initiallyExpanded: expandedSpells[spell.id] ?? false,
                      onExpansionChanged: (value) {
                        expandedSpells[spell.id] = value;
                      },
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              spell.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "Level ${spell.level}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          widget.character.spells.removeWhere(
                            (s) => s == spell.id,
                          );
                          widget.onChanged();
                          setState(() {});
                        },
                      ),

                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              MarkdownBody(
                                data: parseDescription(
                                  spell.description,
                                  widget.character,
                                  widget.template,
                                  widget.aliasMap,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
