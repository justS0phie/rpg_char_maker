import 'package:char_sheet_maker/models/template.dart';
import 'option.dart';

abstract class SheetElement {
  final String id;
  final String type;
  final int row;
  final int column;

  SheetElement({
    required this.id,
    required this.type,
    required this.row,
    required this.column
  });
}

class FieldElement extends SheetElement {
  final TemplateField elem;

  FieldElement({
    required this.elem,
  }) : super(id: elem.id, type: "field", row: elem.row, column: elem.column);
}

class OptionGroupElement extends SheetElement {
  final OptionGroup elem;

  OptionGroupElement({
    required this.elem,
  }) : super(id: elem.id, type: "option_group", row: elem.row, column: elem.column);
}