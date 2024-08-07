import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';

abstract class SheetColumn<T> {
  const SheetColumn();

  Widget label(BuildContext context, ChildVicinity vicinity);

  Widget cell(
      BuildContext context, ChildVicinity vicinity, T? data, SourceState state);
}

final class EmptySheetColumn<T> extends SheetColumn<T> {
  const EmptySheetColumn();

  @override
  Widget cell(BuildContext context, ChildVicinity vicinity, T? data,
      SourceState state) {
    return const SizedBox.shrink();
  }

  @override
  Widget label(BuildContext context, ChildVicinity vicinity) {
    return const SizedBox.shrink();
  }
}
