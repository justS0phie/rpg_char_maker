import 'package:char_sheet_maker/models/sheet_element.dart';
import 'package:char_sheet_maker/models/spell.dart';
import 'option.dart';

class Template {
  final String id;
  final String name;
  final String system;
  List<TemplatePage> pages;
  List<TemplateSpellSlot> slots;
  List<Spell> spells;
  Set<OptionGroup> optionGroups;
  Set<TemplateField> fields;

  Template({
    required this.id,
    required this.name,
    required this.system,
    required this.pages,
    required this.slots,
    required this.spells,
    required this.optionGroups,
    required this.fields,
  });

  factory Template.fromJson(Map<String,dynamic> json) {

    Template result = Template(

      id: json['id'],
      name: json['name'],
      system: json['system'],
      fields: {},

      optionGroups: {},

      slots: (json['template_spell_slots'] ?? [])
        .map<TemplateSpellSlot>((s) => TemplateSpellSlot(
          id: s['id'],
          level: s['level'],
          maxFormula: s['max_formula'],
          requiredFormula: s['required_formula'],
          srcLabel: s['src_label'],
        ))
        .toList(),

      spells: (json['spells'] ?? [])
          .map<Spell>((s) => Spell(
              id: s['id'],
              name: s['name'],
              description: s['description'],
              level: s['level'],
              requiredOptions: List.from((s['spell_requirements'] ?? []).map((sr) => sr["option_id"]))
          ))
          .toList(),

      pages: [],

    );

    result.pages = (json['template_pages'] ?? [])
      .map<TemplatePage>((p) => TemplatePage(
      id: p['id'],
      name: p['name'],
      order: p['order_index'],
      sections: List.from(p["template_sections"].map((s) => TemplateSection(
        id: s["id"],
        name: s['name'],
        order: s['display_order'],
        type: s['type'],
        elements: List<SheetElement>.from(s["template_fields"].map((f) => FieldElement(elem: TemplateField(
          id: f['id'],
          label: f['label'],
          type: f['field_type'],
          defaultValue: f['default_value'] ?? '',
          row: f['grid_row'] ?? 0,
          column: f['grid_column'] ?? 0,
          alias: f['alias'],
          formula: f['formula'],
          readonly: f['readonly'] ?? false,
        ))).toList() + s["option_groups"].map((o) => OptionGroupElement(elem: OptionGroup(
          id: o['id'],
          name: o['name'],
          alias: o['alias'],
          required: o['required'] ?? false,
          multiSelect: o['multi_select'] ?? false,
          options: List.from((o["options"] ?? []).map((opt) {
            final List<OptionEffect> effects = List.from(opt["option_effects"].map((oe) => OptionEffect.fromJson(oe)));
            final List<OptionAbility> abilities = List.from(opt["option_abilities"].map((oa) => OptionAbility.fromJson(oa)));
            return Option.fromJson(opt, effects, abilities);
          })),
          row: o['grid_row'] ?? 0,
          column: o['grid_column'] ?? 0,
        ))).toList()),
      ))),
      parent: result
    )).toList();

    for (var page in result.pages) {
      result.fields.addAll(page.sections.expand((s) => s.elements.where((el) => el.type == "field").map((el) => (el as FieldElement).elem)));
    }

    for (var page in result.pages) {
      result.optionGroups.addAll(page.sections.expand((s) => s.elements.where((el) => el.type == "option_group").map((el) => (el as OptionGroupElement).elem)));
    }

    return result;
  }
}

class TemplatePage {

  final String id;
  final String name;
  final int order;
  final Template parent;

  final List<TemplateSection> sections;

  TemplatePage({
    required this.id,
    required this.name,
    required this.order,
    required this.parent,
    required this.sections,
  });
}

class TemplateSection {
  final String id;
  final String name;
  final int order;
  final String type;
  final List<SheetElement> elements;

  TemplateSection({
    required this.id,
    required this.name,
    required this.order,
    required this.type,
    required this.elements,
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
    required this.alias,
    this.defaultValue,
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