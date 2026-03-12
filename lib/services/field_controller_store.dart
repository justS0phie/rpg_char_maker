import 'package:flutter/material.dart';

class FieldControllerStore {

  final Map<String, TextEditingController> _controllers = {};

  TextEditingController getController(
      String fieldId,
      String initialValue,
      ) {

    if (_controllers.containsKey(fieldId)) {
      return _controllers[fieldId]!;
    }

    final controller =
    TextEditingController(text: initialValue);

    _controllers[fieldId] = controller;

    return controller;
  }

  void disposeAll() {

    for (final controller in _controllers.values) {
      controller.dispose();
    }

    _controllers.clear();
  }
}