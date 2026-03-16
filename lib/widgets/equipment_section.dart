import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/equipment_item.dart';
import '../models/template.dart';
import 'equipment_editor_dialog.dart';

class EquipmentSection extends StatelessWidget {
  final Character character;
  final Template template;
  final VoidCallback onChanged;
  final TemplateSection section;

  const EquipmentSection({
    super.key,
    required this.character,
    required this.template,
    required this.onChanged,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ...character.equipment.map((item) {
          return ListTile(
            leading: Checkbox(
              value: item.equipped,
              onChanged: (v) {
                item.equipped = v ?? false;
                onChanged();
              },
            ),

            title: Text(item.name),

            onTap: () async {
              final result = await showDialog(
                context: context,
                builder: (_) => EquipmentEditorDialog(
                  item: item,
                  template: template,
                ),
              );

              if (result == "delete") {
                character.equipment.remove(item);
              }

              onChanged();
            },
          );
        }),

        const SizedBox(height: 10),

        ElevatedButton(
          onPressed: () {
            character.equipment.add(
              EquipmentItem(id: DateTime.now().toString(), name: "New Item"),
            );

            onChanged();
          },
          child: const Text("Add Item"),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
