import 'package:flutter/material.dart';
import '../models/equipment_item.dart';
import '../models/template.dart';

class EquipmentEditorDialog extends StatefulWidget {
  final EquipmentItem item;
  final Template template;

  const EquipmentEditorDialog({
    super.key,
    required this.item,
    required this.template,
  });

  @override
  State<EquipmentEditorDialog> createState() => _EquipmentEditorDialogState();
}

class _EquipmentEditorDialogState extends State<EquipmentEditorDialog> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.item.name);
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.template.fields;

    return AlertDialog(
      title: const Text("Edit Equipment"),

      content: SingleChildScrollView(
        child: Column(
          children: [
            /// ITEM NAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Item Name"),
              onChanged: (v) {
                widget.item.name = v;
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Modifiers",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...widget.item.modifiers.entries.map((entry) {
              String fieldId = entry.key;
              int value = entry.value;

              final controller = TextEditingController(text: value.toString());

              return Row(
                children: [
                  /// FIELD SELECTOR
                  Expanded(
                    child: DropdownButton<String>(
                      value: fieldId,
                      isExpanded: true,
                      items: fields.where((f) {return f.alias != null;}).map((f) {
                        return DropdownMenuItem(
                          value: f.alias,
                          child: Text(f.label),
                        );
                      }).toList(),
                      onChanged: (newField) {
                        if (newField == null) return;

                        int currentValue = widget.item.modifiers[fieldId]!;
                        widget.item.modifiers.remove(fieldId);
                        widget.item.modifiers[newField] = currentValue;

                        setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// MODIFIER VALUE
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (v) {
                        widget.item.modifiers[fieldId] = int.tryParse(v) ?? 0;
                      },
                    ),
                  ),

                  /// REMOVE BUTTON
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      widget.item.modifiers.remove(fieldId);

                      setState(() {});
                    },
                  ),
                ],
              );
            }),

            const SizedBox(height: 10),

            /// ADD MODIFIER
            ElevatedButton(
              onPressed: () {
                if (fields.isEmpty) return;
                if (fields.first.alias == null) return;

                widget.item.modifiers[fields.first.alias!] = 0;

                setState(() {});
              },
              child: const Text("Add Modifier"),
            ),
          ],
        ),
      ),

      actions: [
        /// DELETE ITEM
        TextButton(
          onPressed: () {
            Navigator.pop(context, "delete");
          },
          child: const Text("Delete Item", style: TextStyle(color: Colors.red)),
        ),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
