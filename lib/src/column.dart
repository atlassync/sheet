import 'package:flutter/material.dart';

typedef SheetColumnBuilder = Widget Function(BuildContext context);

class SheetColumn {
  SheetColumn({
    required this.builder,
  });

  final SheetColumnBuilder builder;

  static SheetColumn empty =
      SheetColumn(builder: (_) => const SizedBox.shrink());
}
