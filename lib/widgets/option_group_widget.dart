import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/option.dart';

class OptionGroupWidget extends StatelessWidget {
  final OptionGroup group;

  final Character character;

  final VoidCallback onChanged;

  const OptionGroupWidget({
    super.key,
    required this.group,
    required this.character,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selection = character.selectionFor(group.id);

    /// SINGLE SELECT (dropdown)
    if (!group.multiSelect) {
      final selected = selection.isEmpty
          ? null
          : selection.first;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.name),

          DropdownButton<String>(
            value: selected,
            hint: Text("Select ${group.name}"),

            items: group.options.map((option) {
              return DropdownMenuItem(
                value: option.id,
                child: Text(option.name),
              );
            }).toList(),

            onChanged: (value) {
              selection
                ..clear()
                ..add(value!);

              onChanged();
            },
          ),
        ],
      );
    }

    /// MULTI SELECT (checkbox list)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.name),

        ...group.options.map((option) {
          final isSelected = selection.contains(option.id);

          return CheckboxListTile(
            title: Text(option.name),

            value: isSelected,

            onChanged: (checked) {
              if (checked == true) {
                selection.add(option.id);
              } else {
                selection.remove(option.id);
              }

              onChanged();
            },
          );
        }),
      ],
    );
  }
}
