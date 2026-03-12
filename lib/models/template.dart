import 'option.dart';

class Template {
  final String id;
  final String name;
  final String system;
  final List<TemplateSection> sections;
  final List<OptionGroup> optionGroups;

  Template({
    required this.id,
    required this.name,
    required this.system,
    required this.sections,
    required this.optionGroups,
  });
}

class TemplateSection {
  final String id;
  final String name;
  final int order;
  final List<TemplateField> fields;

  TemplateSection({
    required this.id,
    required this.name,
    required this.order,
    required this.fields,
  });
}

class TemplateField {

  final String id;
  final String label;
  final String type;

  final int row;
  final int column;

  final String? defaultValue;

  final String? alias;
  final String? formula;
  final bool readonly;

  TemplateField({
    required this.id,
    required this.label,
    required this.type,
    required this.row,
    required this.column,
    this.defaultValue,
    this.alias,
    this.formula,
    this.readonly = false,
  });

  factory TemplateField.fromJson(Map<String,dynamic> json){

    return TemplateField(
      id: json['id'],
      label: json['label'],
      type: json['type'],
      row: json['row'],
      column: json['column'],
      defaultValue: json['default_value'],
      alias: json['alias'],
      formula: json['formula'],
      readonly: json['readonly'] ?? false,
    );
  }
}