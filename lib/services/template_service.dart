import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/option.dart';
import '../models/template.dart';

Future<List<OptionGroup>> _loadOptionGroups(String templateId) async {
  final supabase = Supabase.instance.client;

  final groupResponse = await supabase
      .from('option_groups')
      .select()
      .eq('template_id', templateId)
      .order('display_order');

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
      ),
    );
  }

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

    options.add(
      Option.fromJson(option, effects),
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

      final sections = await _fetchSections(templateId);
      final optionGroups = await _loadOptionGroups(templateRow['id']);

      templates.add(
        Template(
          id: templateId,
          name: templateRow['name'],
          system: templateRow['system'],
          sections: sections,
          optionGroups: optionGroups,
        ),
      );
    }

    return templates;
  }

  Future<List<TemplateSection>> _fetchSections(String templateId) async {
    final sectionRows = await supabase
        .from('template_sections')
        .select()
        .eq('template_id', templateId)
        .order('display_order');

    List<TemplateSection> sections = [];

    for (final sectionRow in sectionRows) {
      final sectionId = sectionRow['id'];

      final fields = await _fetchFields(sectionId);

      sections.add(
        TemplateSection(
          id: sectionId,
          name: sectionRow['name'],
          order: sectionRow['display_order'],
          fields: fields,
        ),
      );
    }

    return sections;
  }

  Future<List<TemplateField>> _fetchFields(String sectionId) async {
    final fieldRows = await supabase
        .from('template_fields')
        .select()
        .eq('section_id', sectionId)
        .order('display_order');

    return fieldRows.map<TemplateField>((row) {
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
  }
}