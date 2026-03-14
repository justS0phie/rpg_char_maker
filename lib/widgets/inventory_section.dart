import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/item.dart';

class InventorySection extends StatelessWidget {
  final Character character;
  final VoidCallback onChanged;

  const InventorySection({
    super.key,
    required this.character,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Inventory",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ...character.inventory.map((item) {
          final amountController = TextEditingController(text: item.amount);

          return Row(
            children: [
              /// ITEM NAME
              Expanded(
                child: TextFormField(
                  initialValue: item.name,
                  onChanged: (v) {
                    item.name = v;
                    onChanged();
                  },
                )
              ),

              const SizedBox(width: 10),

              /// AMOUNT
              SizedBox(
                width: 60,
                child: TextField(
                  controller: amountController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: "Qty"),
                  onChanged: (v) {
                    item.amount = v;
                    onChanged();
                  },
                ),
              ),

              /// DELETE BUTTON
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  character.inventory.remove(item);
                  onChanged();
                },
              ),
            ],
          );
        }),

        const SizedBox(height: 10),

        /// ADD ITEM
        ElevatedButton(
          onPressed: () {
            character.inventory.add(
              InventoryItem(
                id: DateTime.now().toString(),
                name: "",
                amount: "1",
              ),
            );

            onChanged();
          },
          child: const Text("Add Item"),
        ),
      ],
    );
  }
}
