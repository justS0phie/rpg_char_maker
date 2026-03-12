class OptionGroup {
  final String id;
  final String name;
  final bool required;
  final bool multiSelect;
  final List<Option> options;
  final int row;
  final int column;

  OptionGroup({
    required this.id,
    required this.name,
    required this.required,
    required this.multiSelect,
    required this.options,
    required this.row,
    required this.column,
  });
}

class OptionEffect {
  final String optionId;
  final String fieldAlias;
  final double modifier;

  OptionEffect({
    required this.optionId,
    required this.fieldAlias,
    required this.modifier,
  });

  factory OptionEffect.fromJson(Map<String, dynamic> json) {
    return OptionEffect(
      optionId: json['option_id'],
      fieldAlias: json['field_alias'],
      modifier: (json['modifier'] as num).toDouble(),
    );
  }
}

class OptionAbility {
  final String id;
  final String name;
  final String optionId;
  final String description;
  final int levelRequired;
  final Map<String, dynamic> modifiers;

  OptionAbility({
    required this.id,
    required this.optionId,
    required this.name,
    required this.description,
    required this.levelRequired,
    required this.modifiers,
  });

  factory OptionAbility.fromJson(Map<String, dynamic> json) {
    return OptionAbility(
      id: json['id'],
      optionId: json['option_id'],
      name: json['name'],
      description: json['description'] ?? '',
      levelRequired: json['level_required'],
      modifiers: json['modifiers'],
    );
  }
}

class Option {
  final String id;
  final String name;
  final String description;

  final List<OptionEffect> effects;
  final List<OptionAbility> abilities;

  Option({
    required this.id,
    required this.name,
    required this.description,
    required this.effects,
    required this.abilities,
  });

  factory Option.fromJson(
    Map<String, dynamic> json,
    List<OptionEffect> effects,
    List<OptionAbility> abilities,
  ) {
    return Option(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? "",
      effects: effects,
      abilities: abilities,
    );
  }
}
