import 'package:char_sheet_maker/models/item.dart';
import 'package:char_sheet_maker/models/spell.dart';

import 'equipment_item.dart';

class CharacterSelection {
  final String groupId;
  final Set<String> optionIds;

  CharacterSelection({
    required this.groupId,
    Set<String>? optionIds,
  }) : optionIds = optionIds ?? {};
}

class Character {
  final String id;
  String name;
  String templateId;
  Map<String,dynamic> values;
  Map<String, CharacterSelection> selections;

  List<EquipmentItem> equipment;
  List<InventoryItem> inventory;
  Set<String> spells;
  List<SpellSlotUsage> spellSlotUsage;

  CharacterSelection selectionFor(String groupId) {
    return selections.putIfAbsent(
      groupId,
          () => CharacterSelection(groupId: groupId),
    );
  }

  Character({
    required this.id,
    required this.name,
    required this.templateId,

    Map<String,dynamic>? values,
    Map<String, CharacterSelection>? selections,
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
}