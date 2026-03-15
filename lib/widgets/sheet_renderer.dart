import 'package:collection/collection.dart';
import 'package:char_sheet_maker/models/sheet_element.dart';
import 'package:flutter/material.dart';

import '../models/template.dart';
import '../models/character.dart';
import '../services/field_controller_store.dart';
import 'section_renderer.dart';

class SheetRenderer extends StatelessWidget {

  final TemplatePage page;
  final Template template;
  final Character character;
  final FieldControllerStore controllerStore;
  final VoidCallback onValueChanged;

  const SheetRenderer({
    super.key,
    required this.page,
    required this.template,
    required this.character,
    required this.controllerStore,
    required this.onValueChanged
  });

  Map<String, TemplateField> _buildAliasMap() {

    final map = <String, TemplateField>{};

    for (var eachPage in template.pages) {
      for (var section in eachPage.sections) {
        for (var elem in section.elements.where((elem) {return elem.type == "field";})) {
          final field = (elem as FieldElement).elem;

          if (field.alias != null) {
            map[field.alias!] = field;
          }
        }
      }
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    final aliasMap = _buildAliasMap();

    return ListView(
      padding: const EdgeInsets.all(16),

      children: page.sections.sorted((a, b) => a.order.compareTo(b.order)).map((section) {

        return SectionRenderer(
          section: section,
          character: character,
          controllerStore: controllerStore,
          aliasMap: aliasMap,
          onValueChanged: onValueChanged,
          template: page.parent,
        );

      }).toList(),
    );
  }
}