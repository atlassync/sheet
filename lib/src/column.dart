import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';

abstract class SheetColumn<T> {
  const SheetColumn();

  Widget build(
      BuildContext context, ChildVicinity vicinity, T? item, SourceState state);
}