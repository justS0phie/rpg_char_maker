class InventoryItem {
  String id;
  String name;
  String amount;

  InventoryItem({
    required this.id,
    required this.name,
    this.amount = "1"
  });
}