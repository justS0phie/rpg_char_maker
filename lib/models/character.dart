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
}