class OptionGroup {
  final String id;
  final String name;
  final String? alias;
  final bool required;
  final bool multiSelect;
  final List<Option> options;
  final int row;
  final int column;
  Option? parentOption;

  OptionGroup({
    required this.id,
    required this.name,
    required this.alias,
    required this.required,
    required this.multiSelect,
    required this.options,
    required this.row,
    required this.column,
    this.parentOption,
  });
}

class OptionEffect {
  final String optionId;
  final String fieldAlias;
  final String formula;

  OptionEffect({
    required this.optionId,
    required this.fieldAlias,
    required this.formula,
  });

  factory OptionEffect.fromJson(Map<String, dynamic> json) {
    return OptionEffect(
      optionId: json['option_id'],
      fieldAlias: json['field_alias'],
      formula: json['formula'],
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
  final String? optionGroupId;

  OptionAbility({
    required this.id,
    required this.optionId,
    required this.name,
    required this.description,
    required this.levelRequired,
    required this.modifiers,
    this.optionGroupId,
  });

  factory OptionAbility.fromJson(Map<String, dynamic> json) {
    return OptionAbility(
      id: json['id'],
      optionId: json['option_id'],
      name: json['name'],
      description: json['description'] ?? '',
      levelRequired: json['level_required'],
      modifiers: Map<String, dynamic>.from(json['modifiers']),
      optionGroupId: json['option_group_id'],
    );
  }
}

class Option {
  final String id;
  final String name;
  final String? alias;
  final String description;

  List<OptionEffect> effects;
  List<OptionAbility> abilities;

  Option({
    required this.id,
    required this.name,
    required this.description,
    required this.effects,
    required this.abilities,
    required this.alias,
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
      alias: json['alias'],
      effects: effects,
      abilities: abilities,
    );
  }
}
