import 'package:char_sheet_maker/models/spell.dart';
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
        alias: group['alias'],
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
    final optionObj = Option.fromJson(option, [], []);
    await _loadOptionRelations(optionObj);
    options.add(
      optionObj,
    );
  }

  return options;
}

Future<void> _loadOptionRelations(Option option) async {
  final supabase = Supabase.instance.client;

  final effectsResponse = await supabase
      .from('option_effects')
      .select()
      .eq('option_id', option.id);

  final effects = effectsResponse
      .map<OptionEffect>((e) =>
      OptionEffect.fromJson(e))
      .toList();

  final abilitiesResponse = await supabase
      .from('option_abilities')
      .select()
      .eq('option_id', option.id);

  final abilities = abilitiesResponse
      .map<OptionAbility>((e) =>
      OptionAbility.fromJson(e))
      .toList();

  option.effects = effects;
  option.abilities = abilities;
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
          pages: [],
          optionGroups: {},
          fields: {},
          slots: [],
          spells: []
      );

      templates.add(template);
    }

    return templates;
  }

  Future<Template> loadTemplate(String templateId) async {

    final response = await supabase
        .from('templates')
        .select('''
        *,
        template_spell_slots (*),
        template_pages (
          *,
          template_sections (
            *,
            template_fields (*),
            option_groups (
              *,
              options (
                *,
                option_effects (*),
                option_abilities (*)
              )
            )
          )
        )
      ''')
        .eq('id', templateId)
        .single();

    Template result = Template.fromJson(response);
    await _loadOptionGroups(result, null);
    return result;
  }

  Future<List<Spell>> loadSpells(String templateId) async {
    final response = await supabase
        .from('spells')
        .select('''
        *,
        spell_requirements (*)
      ''')
        .eq('template_id', templateId);

    return response
        .map<Spell>((s) => Spell(
            id: s['id'],
            name: s['name'],
            description: s['description'],
            level: s['level'],
            requiredOptions: List.from((s['spell_requirements'] ?? []).map((sr) => sr["option_id"]))
        ))
        .toList();
  }
}