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
