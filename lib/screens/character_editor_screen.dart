import 'package:char_sheet_maker/models/sheet_element.dart';
import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/template.dart';
import '../services/field_controller_store.dart';
import '../widgets/sheet_renderer.dart';

class CharacterEditorScreen extends StatefulWidget {
  final Character character;
  final Template template;

  const CharacterEditorScreen({
    super.key,
    required this.character,
    required this.template,
  });

  @override
  State<CharacterEditorScreen> createState() =>
      _CharacterEditorScreenState();
}

class _CharacterEditorScreenState
    extends State<CharacterEditorScreen> {

  late TextEditingController nameController;
  late FieldControllerStore controllerStore;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.character.name);

    controllerStore = FieldControllerStore();

    _initializeCharacterValues();
  }

  void _initializeCharacterValues() {

    for (var section in widget.template.sections) {

      for (var elem in section.elements.where((elem) {return elem.type == "field";})) {
        final field = (elem as FieldElement).elem;
        if (!widget.character.values.containsKey(field.id)) {

          if (field.defaultValue != null) {

            widget.character.values[field.id] =
                int.tryParse(field.defaultValue!) ?? field.defaultValue;

          } else {

            widget.character.values[field.id] = 0;

          }
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    controllerStore.disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final character = widget.character;
    final template = widget.template;

    void refreshSheet() {
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Character Editor"),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Character Name",
              ),
              onChanged: (value) {
                character.name = value;
              },
            ),
          ),

          const Divider(),

          Expanded(
            child: SheetRenderer(
              template: template,
              character: character,
              controllerStore: controllerStore,
              onValueChanged: refreshSheet
            ),
          ),
        ],
      ),
    );
  }
}