class EquipmentItem {

  String id;
  String name;

  bool equipped;

  Map<String, int> modifiers;

  EquipmentItem({
    required this.id,
    required this.name,
    this.equipped = false,
    Map<String, int>? modifiers,
  }) : modifiers = modifiers ?? {};
}