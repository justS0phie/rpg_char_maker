class Spell {

  String id;
  String name;

  String level;
  bool prepared;

  String description;

  Spell({
    required this.id,
    required this.name,
    this.level = "0",
    this.prepared = false,
    this.description = "",
  });
}

class SpellSlotUsage {
  int level;
  int used;

  SpellSlotUsage({
    required this.level,
    this.used = 0,
  });
}

class TemplateSpellSlot {
  final int level;
  final String maxFormula;
  final String srcLabel;

  TemplateSpellSlot({
    required this.level,
    required this.maxFormula,
    String? srcLabel
  }) : srcLabel = srcLabel ?? "LVL";
}
