import 'package:flutter/material.dart';
import 'package:sheet/src/cell.dart';

typedef SheetRowBuilder<T> = List<SheetCell> Function(BuildContext context, int index, T? item);

class SheetRow<T> {
  SheetRow({
    required this.builder,
  });

  final SheetRowBuilder<T> builder;
}
