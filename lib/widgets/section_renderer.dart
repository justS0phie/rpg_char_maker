import 'package:flutter/material.dart';

import '../models/template.dart';
import '../models/character.dart';
import '../services/field_controller_store.dart';
import 'field_renderer.dart';

class SectionRenderer extends StatelessWidget {

  final TemplateSection section;
  final Character character;
  final FieldControllerStore controllerStore;
  final Map<String, TemplateField> aliasMap;
  final VoidCallback onValueChanged;
  final Template template;

  const SectionRenderer({
    super.key,
    required this.section,
    required this.character,
    required this.controllerStore,
    required this.aliasMap,
    required this.onValueChanged,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {

    int maxRow = 0;
    int maxCol = 0;

    for (var field in section.fields) {
      if (field.row > maxRow) maxRow = field.row;
      if (field.column > maxCol) maxCol = field.column;
    }

    List<TableRow> rows = [];

    for (int r = 0; r <= maxRow; r++) {

      List<Widget> cells = [];

      for (int c = 0; c <= maxCol; c++) {

        TemplateField? field;

        for (var f in section.fields) {
          if (f.row == r && f.column == c) {
            field = f;
            break;
          }
        }

        cells.add(
          Padding(
            padding: const EdgeInsets.all(8),
            child: field != null
                ? FieldRenderer(
              field: field,
              character: character,
              controllerStore: controllerStore,
              aliasMap: aliasMap,
              onValueChanged: onValueChanged,
              template: template,
            )
                : const SizedBox(),
          ),
        );
      }

      rows.add(TableRow(children: cells));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 20),

        Text(
          section.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Table(children: rows),
      ],
    );
  }
}