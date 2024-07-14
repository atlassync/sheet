import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

class PaginatedSheetScope<T> extends InheritedWidget {
  final PaginatedSheetSource<T> source;

  const PaginatedSheetScope({
    super.key,
    required super.child,
    required this.source,
  });

  static PaginatedSheetSource<T>? of<T>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PaginatedSheetScope<T>>()
        ?.source;
  }

  @override
  bool updateShouldNotify(covariant PaginatedSheetScope oldWidget) {
    return false;
  }
}
