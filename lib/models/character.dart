import 'dart:convert';
import 'dart:io';
import 'package:char_sheet_maker/models/template.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'package:char_sheet_maker/models/item.dart';
import 'package:char_sheet_maker/models/spell.dart';
import 'package:uuid/v4.dart';

import 'equipment_item.dart';


class Character {
  final String id;
  String name;
  String templateId;
  Map<String,dynamic> values;
  Map<String, Set<String>> selections;

  List<EquipmentItem> equipment;
  List<InventoryItem> inventory;
  Set<String> spells;
  List<SpellSlotUsage> spellSlotUsage;

  Set<String> selectionFor(String groupId) {
    return selections.putIfAbsent(groupId, () => {});
  }

  Map<String, dynamic> toJson() {
    Map<String, List<String>> jsonSelections = {};
    for (var key in selections.keys) {
      jsonSelections[key] = selections[key]!.toList();
    }

    return {
      "id": id,
      "name": name,
      "templateId": templateId,
      "values": values,
      "selections": jsonSelections,
      "equipment": equipment.map((e) => e.toJson()).toList(),
      "inventory": inventory.map((i) => i.toJson()).toList(),
      "spells": spells.toList(),
    };
  }

  Character({
    required this.id,
    required this.name,
    required this.templateId,

    Map<String,dynamic>? values,
    Map<String, Set<String>>? selections,
    List<EquipmentItem>? equipment,
    List<InventoryItem>? inventory,
    Set<String>? spells,
    List<SpellSlotUsage>? spellSlotUsage

  })  : values = values ?? {},
        selections = selections ?? {},
        equipment = equipment ?? [],
        inventory = inventory ?? [],
        spellSlotUsage = spellSlotUsage ?? [],
        spells = spells ?? {};

  factory Character.fromJson(Map<String,dynamic> json) {

    final character = Character(
      id: json["id"] ?? UuidV4().generate(),
      name: json["name"],
      templateId: json["templateId"],
      spells: Set<String>.from(json["spells"])
    );

    character.values = Map<String,dynamic>.from(json["values"] ?? {});

    Map<String, Set<String>> jsonSelections = {};
    for (var key in (json["selections"] ?? {}).keys) {
      jsonSelections[key] = Set<String>.from(json["selections"][key]!);
    }

    character.selections = jsonSelections;

    character.equipment =
        (json["equipment"] ?? [])
            .map<EquipmentItem>((e) => EquipmentItem.fromJson(e))
            .toList();

    character.inventory =
        (json["inventory"] ?? [])
            .map<InventoryItem>((i) => InventoryItem.fromJson(i))
            .toList();

    return character;
  }

  Future<void> saveCharacter() async {
    final jsonData = jsonEncode(toJson());
    debugPrint(jsonData);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$id.json');

      file.writeAsString(jsonData);
    } catch (e) {
      print("Failed to save character: ${name}");
      print(e);
    }
  }

  Future<Character> loadCharacter(File file) async {
    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);

    return Character.fromJson(jsonData);
  }

  Future<void> exportCharacter() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/character_export.json');
    final jsonData = toJson();
    jsonData.remove("id");

    await file.writeAsString(jsonEncode(jsonData));
    await Share.shareXFiles([XFile(file.path)]);
  }

  static Future<Character?> importCharacter() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) return null;

    final jsonString = utf8.decode(result.files.single.bytes!);
    final jsonData = jsonDecode(jsonString);

    Character char = Character.fromJson(jsonData);
    await char.saveCharacter();
    return char;
  }

  void cleanInvalidSelections(Template template) {
    bool changed = true;

    while (changed) {
      changed = false;
      for (var group in template.optionGroups) {
        if (group.parentOption != null) {
          final parentSelected =
          selections.values.expand((s) => s).contains(group.parentOption!.id);

          if (!parentSelected) {
            if (selections.containsKey(group.id)) {
              selections.remove(group.id);
              changed = true;
            }
          }
        }
      }
    }
  }
}