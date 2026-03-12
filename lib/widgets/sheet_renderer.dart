import 'package:flutter/material.dart';

import '../models/template.dart';
import '../models/character.dart';
import '../services/field_controller_store.dart';
import 'section_renderer.dart';

class SheetRenderer extends StatelessWidget {

  final Template template;
  final Character character;
  final FieldControllerStore controllerStore;
  final VoidCallback onValueChanged;

  const SheetRenderer({
    super.key,
    required this.template,
    required this.character,
    required this.controllerStore,
    required this.onValueChanged
  });

  Map<String, TemplateField> _buildAliasMap() {

    final map = <String, TemplateField>{};

    for (var section in template.sections) {
      for (var field in section.fields) {

        if (field.alias != null) {
          map[field.alias!] = field;
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

      children: template.sections.map((section) {

        return SectionRenderer(
          section: section,
          character: character,
          controllerStore: controllerStore,
          aliasMap: aliasMap,
          onValueChanged: onValueChanged,
          template: template,
        );

      }).toList(),
    );
  }
}