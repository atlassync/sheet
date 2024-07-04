import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

class SheetColumn<T> {
  SheetColumn({
    required this.label,
    required this.builder,
  });

  final Widget label;
  final Widget Function(ChildVicinity vicinity, T? item, SourceState state) builder;
}
