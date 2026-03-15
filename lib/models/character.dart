import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'package:char_sheet_maker/models/item.dart';
import 'package:char_sheet_maker/models/spell.dart';

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
    return {
      "name": name,
      "templateId": templateId,
      "values": values,
      "selections": selections,
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
      id: json["id"],
      name: json["name"],
      templateId: json["templateId"],
      spells: json["spells"]
    );

    character.values = Map<String,dynamic>.from(json["values"] ?? {});
    character.selections = Map<String, Set<String>>.from(json["selections"] ?? {});

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

  Future<File> saveCharacter() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/characters/$name.json');
    final jsonData = jsonEncode(toJson());

    return file.writeAsString(jsonData);
  }

  Future<Character> loadCharacter(File file) async {
    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);

    return Character.fromJson(jsonData);
  }

  Future<void> exportCharacter(Character character) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/character_export.json');

    await file.writeAsString(
        jsonEncode(character.toJson())
    );

    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<Character?> importCharacter() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) return null;

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);

    return Character.fromJson(jsonData);
  }
}