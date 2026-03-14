import 'package:char_sheet_maker/models/character.dart';
import 'package:char_sheet_maker/models/template.dart';

import '../services/formula_engine.dart';

class Spell {

  String id;
  String name;

  int level;
  bool prepared;

  String description;
  final List<String> requiredOptions;

  Spell({
    required this.id,
    required this.name,
    this.level = 0,
    this.prepared = false,
    this.description = "",
    required this.requiredOptions,
  });
}

class SpellSlotUsage {
  String id;
  int used;

  SpellSlotUsage({
    required this.id,
    this.used = 0,
  });
}

class TemplateSpellSlot {
  final String id;
  final int level;
  final String maxFormula;
  final String srcLabel;
  final String? requiredFormula;

  TemplateSpellSlot({
    required this.id,
    required this.level,
    required this.maxFormula,
    required this.requiredFormula,
    String? srcLabel
  }) : srcLabel = srcLabel ?? "LVL";
}

List<TemplateSpellSlot> getAvailableSlotsForChar(Template template, Character character, Map<String, TemplateField> aliasMap) {
  return template.slots.where((slot) {
    if (slot.requiredFormula != null) {
      if (FormulaEngine.evaluate(slot.requiredFormula, character, aliasMap, template) == 0) {
        return false;
      }
    }
    return FormulaEngine.evaluate(slot.maxFormula, character, aliasMap, template) > 0;
  }).toList();
}
