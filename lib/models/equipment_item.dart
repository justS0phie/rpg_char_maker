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

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "equipped": equipped,
      "modifiers": modifiers,
    };
  }

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json["id"],
      name: json["name"],
      equipped: json["equipped"],
      modifiers: json["modifiers"],
    );
  }
}
