import 'package:char_sheet_maker/models/sheet_element.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/option.dart';
import '../models/template.dart';

Future<List<OptionGroup>> _loadOptionGroups(Template template, String? sectionId) async {
  final supabase = Supabase.instance.client;
  PostgrestList groupResponse;

  if (sectionId != null) {
    groupResponse = await supabase
        .from('option_groups')
        .select()
        .eq('section_id', sectionId)
        .order('display_order');
  } else {
    groupResponse = await supabase
        .from('option_groups')
        .select()
        .isFilter('section_id', null)
        .order('display_order');
  }

  List<OptionGroup> groups = [];

  for (final group in groupResponse) {
    final options = await _loadOptions(group["id"]);

    groups.add(
      OptionGroup(
        id: group['id'],
        name: group['name'],
        required: group['required'] ?? false,
        multiSelect: group['multi_select'] ?? false,
        options: options,
        row: group['grid_row'] ?? 0,
        column: group['grid_column'] ?? 0,
      ),
    );
  }

  template.optionGroups.addAll(groups);
  return groups;
}

Future<List<Option>> _loadOptions(String groupId) async {
  final supabase = Supabase.instance.client;

  final optionsResponse = await supabase
      .from('options')
      .select()
      .eq('group_id', groupId);

  List<Option> options = [];

  for (final option in optionsResponse) {

    final effectsResponse = await supabase
        .from('option_effects')
        .select()
        .eq('option_id', option['id']);

    final effects = effectsResponse
        .map<OptionEffect>((e) =>
        OptionEffect.fromJson(e))
        .toList();

    final abilitiesResponse = await supabase
        .from('option_abilities')
        .select()
        .eq('option_id', option['id']);

    final abilities = abilitiesResponse
        .map<OptionAbility>((e) =>
        OptionAbility.fromJson(e))
        .toList();

    options.add(
      Option.fromJson(option, effects, abilities),
    );
  }

  return options;
}

class TemplateService {
  final supabase = Supabase.instance.client;

  Future<List<Template>> fetchTemplates() async {
    final templateRows = await supabase
        .from('templates')
        .select()
        .order('name');

    List<Template> templates = [];

    for (final templateRow in templateRows) {
      final templateId = templateRow['id'];
      final Template template = Template(
          id: templateId,
          name: templateRow['name'],
          system: templateRow['system'],
          sections: [],
          optionGroups: {},
          fields: {}
      );

      final sections = await _fetchSections(template);
      template.sections = sections;
      await _loadOptionGroups(template, null);
      templates.add(template);
    }

    return templates;
  }

  Future<List<TemplateSection>> _fetchSections(Template template) async {
    final sectionRows = await supabase
        .from('template_sections')
        .select()
        .eq('template_id', template.id)
        .order('display_order', ascending: true);

    List<TemplateSection> sections = [];

    for (final sectionRow in sectionRows) {
      final sectionId = sectionRow['id'];

      final fields = await _fetchFields(template, sectionId);
      final optionGroups = await _loadOptionGroups(template, sectionId);

      List<SheetElement> elements = [];

      elements.addAll(fields.map((field) {return FieldElement(elem: field);}));
      elements.addAll(optionGroups.map((og) {return OptionGroupElement(elem: og);}));

      sections.add(
        TemplateSection(
          id: sectionId,
          name: sectionRow['name'],
          order: sectionRow['display_order'],
          type: sectionRow['type'],
          elements: elements,
        ),
      );
    }

    return sections;
  }

  Future<List<TemplateField>> _fetchFields(Template template, String sectionId) async {
    final fieldRows = await supabase
        .from('template_fields')
        .select()
        .eq('section_id', sectionId)
        .order('display_order');

    List<TemplateField> result = fieldRows.map<TemplateField>((row) {
      return TemplateField(
        id: row['id'],
        label: row['label'],
        type: row['field_type'],
        defaultValue: row['default_value'] ?? '',
        row: row['grid_row'] ?? 0,
        column: row['grid_column'] ?? 0,
        alias: row['alias'],
        formula: row['formula'],
        readonly: row['readonly'] ?? false,
      );
    }).toList();

    template.fields.addAll(result);
    return result;
  }
}