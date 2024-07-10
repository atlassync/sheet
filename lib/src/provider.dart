import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

class SheetScope<T> extends InheritedWidget {
  final SheetSource<T> source;

  const SheetScope({
    super.key,
    required super.child,
    required this.source,
  });

  static SheetSource<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SheetScope<T>>()?.source;
  }

  @override
  bool updateShouldNotify(covariant SheetScope oldWidget) {
    return false;
  }
}
