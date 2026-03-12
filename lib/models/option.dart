class OptionGroup {
  final String id;
  final String name;
  final bool required;
  final bool multiSelect;
  final List<Option> options;

  OptionGroup({
    required this.id,
    required this.name,
    required this.required,
    required this.multiSelect,
    required this.options,
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

  factory OptionEffect.fromJson(Map<String,dynamic> json) {
    return OptionEffect(
      optionId: json['option_id'],
      fieldAlias: json['field_alias'],
      modifier: (json['modifier'] as num).toDouble(),
    );
  }
}

class Option {
  final String id;
  final String name;
  final String description;

  final List<OptionEffect> effects;

  Option({
    required this.id,
    required this.name,
    required this.description,
    required this.effects,
  });

  factory Option.fromJson(
      Map<String,dynamic> json,
      List<OptionEffect> effects,
      ) {

    return Option(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? "",
      effects: effects,
    );
  }
}