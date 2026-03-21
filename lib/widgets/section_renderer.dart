import 'package:char_sheet_maker/models/sheet_element.dart';
import 'package:char_sheet_maker/widgets/spell_section.dart';
import 'package:char_sheet_maker/widgets/spell_slots_widget.dart';
import 'package:flutter/material.dart';

import '../models/template.dart';
import '../models/character.dart';
import '../services/field_controller_store.dart';
import 'abilities_section.dart';
import 'field_renderer.dart';
import 'inventory_section.dart';
import 'option_group_widget.dart';
import 'equipment_section.dart';

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

    if (section.type == "equip") {
      return EquipmentSection(
        character: character,
        section: section,
        onChanged: onValueChanged,
        template: template,
      );
    } else if (section.type == "abilities") {
      return AbilitiesSection(
        template: template,
        section: section,
        character: character,
        aliasMap: aliasMap,
        onChanged: onValueChanged,
      );
    } else if (section.type == "inventory") {
      return InventorySection(
        character: character,
        section: section,
        onChanged: onValueChanged,
      );
    } else if (section.type == "spells" || section.type == "spells_simple") {
      return SpellSection(
        section: section,
        character: character,
        template: template,
        aliasMap: aliasMap,
        onChanged: onValueChanged,
        usePreparing: section.type == "spells",
      );
    } else if (section.type == "spell_slots") {
      return SpellSlotsWidget(
        character: character,
        template: template,
        aliasMap: aliasMap,
        onChanged: onValueChanged,
        section: section,
      );
    }

    int maxRow = 0;
    int maxCol = 0;

    for (var element in section.elements) {
      if (element.row > maxRow) maxRow = element.row;
      if (element.column > maxCol) maxCol = element.column;
    }

    List<TableRow> rows = [];

    for (int r = 0; r <= maxRow; r++) {
      List<Widget> cells = [];

      for (int c = 0; c <= maxCol; c++) {
        SheetElement? element;

        for (var e in section.elements) {
          if (e.row == r && e.column == c) {
            element = e;
            break;
          }
        }

        Widget child = const SizedBox();

        if (element != null) {
          if (element.type == "field") {
            final field = (element as FieldElement).elem;

            child = FieldRenderer(
              field: field,
              character: character,
              controllerStore: controllerStore,
              aliasMap: aliasMap,
              onValueChanged: onValueChanged,
              template: template,
            );
          }
          else if (element.type == "option_group") {
            final group = (element as OptionGroupElement).elem;

            child = OptionGroupWidget(
              group: group,
              character: character,
              onChanged: onValueChanged,
            );
          }
        }

        cells.add(Padding(padding: const EdgeInsets.all(8), child: child));
      }

      rows.add(TableRow(children: cells));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Table(children: rows),
      ],
    );
  }
}
