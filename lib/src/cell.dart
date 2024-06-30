import 'package:flutter/material.dart';

typedef SheetCellBuilder = Widget Function(BuildContext context);
typedef SheetLoadingIndicatorBuilder = Widget Function(BuildContext context);

class SheetCell {
  SheetCell({
    required this.builder,
    this.loadingIndicator,
  });

  final SheetCellBuilder builder;
  final SheetLoadingIndicatorBuilder? loadingIndicator;

  static SheetCell empty = SheetCell(
    builder: (_) => const SizedBox.shrink(),
  );
}
