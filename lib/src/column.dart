import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';

abstract class SheetColumn<T> {
  const SheetColumn();

  Widget label(BuildContext context, ChildVicinity vicinity);

  Widget cell(
      BuildContext context, ChildVicinity vicinity, T? data, SourceState state);
}
