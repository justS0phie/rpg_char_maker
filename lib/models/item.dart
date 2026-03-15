class InventoryItem {
  String id;
  String name;
  String amount;

  InventoryItem({
    required this.id,
    required this.name,
    this.amount = "1"
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "amount": amount,
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json["id"],
      name: json["name"],
      amount: json["amount"],
    );
  }
}