import 'package:flutter/material.dart';

import '../models/template.dart';
import '../models/character.dart';
import '../services/field_controller_store.dart';
import '../services/formula_engine.dart';
import '../services/modifier_engine.dart';

class FieldRenderer extends StatelessWidget {

  final TemplateField field;
  final Character character;
  final FieldControllerStore controllerStore;
  final Map<String, TemplateField> aliasMap;
  final VoidCallback onValueChanged;
  final Template template;

  const FieldRenderer({
    super.key,
    required this.field,
    required this.character,
    required this.controllerStore,
    required this.aliasMap,
    required this.onValueChanged,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {

    switch (field.type) {

      case "number":
        return _buildNumberField();

      case "text":
        return _buildTextField();

      case "checkbox":
        return _buildCheckbox();

      default:
        return const SizedBox();
    }
  }

  Widget _buildNumberField() {

    /// Computed field
    if (field.formula != null) {
      return _buildFormulaField();
    }

    /// Editable field (base value)
    final controller = controllerStore.getController(
      field.id,
      character.values[field.id]?.toString() ??
          field.defaultValue ??
          "0",
    );

    // Compute modifier bonus for display
    final modifiers = ModifierEngine.computeModifiers(template, character);
    final bonus = modifiers[field.id] ?? 0;
    final displayValue = (character.values[field.id] ?? 0) + bonus;

    // Update controller text to show base + bonus
    controller.text = displayValue.toString();

    return Column(
      children: [
        Text(field.label),
        SizedBox(
          width: 60,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (value) {
              // Only update base value
              character.values[field.id] = int.tryParse(value) ?? 0;
              onValueChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaField() {

    // Formula already calculates a value
    double value = FormulaEngine.evaluate(
      field,
      character,
      aliasMap,
    );

    // Add option effects modifiers
    final modifiers = ModifierEngine.computeModifiers(template, character);
    final bonus = modifiers[field.id] ?? 0;
    final displayValue = value + bonus;

    return Column(
      children: [
        Text(field.label),
        SizedBox(
          width: 60,
          child: TextField(
            controller: TextEditingController(
              text: displayValue.toStringAsFixed(0),
            ),
            enabled: !field.readonly,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField() {

    final controller = controllerStore.getController(
      field.id,
      character.values[field.id] ??
          field.defaultValue ??
          "",
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(field.label),

        TextField(
          controller: controller,
          onChanged: (value) {
            character.values[field.id] = value;
            onValueChanged();
          },
        ),
      ],
    );
  }

  Widget _buildCheckbox() {

    bool value = character.values[field.id] == true;

    return Row(
      children: [

        Checkbox(
          value: value,
          onChanged: (v) {
            character.values[field.id] = v;
            onValueChanged();
          },
        ),

        Text(field.label)
      ],
    );
  }
}