import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sheet/sheet.dart';

/// Defines the extent, visual appearance, and gesture handling of a row or column.
/// A span refers to either a column or a row.
@immutable
class SheetSpan {
  const SheetSpan({
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.foregroundDecoration,
    this.backgroundDecoration,
    this.padding,
    this.extent = const FixedSpanExtent(96.0),
    this.cursor = MouseCursor.defer,
    this.onEnter,
    this.onExit,
  });

  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final SpanDecoration? foregroundDecoration;
  final SpanDecoration? backgroundDecoration;
  final SpanPadding? padding;
  final SpanExtent extent;
  final MouseCursor cursor;
  final PointerEnterEventListener? onEnter;
  final PointerExitEventListener? onExit;

  SheetSpan copyWith({
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    VoidCallback? onLongPress,
    SpanDecoration? foregroundDecoration,
    SpanDecoration? backgroundDecoration,
    SpanPadding? padding,
    SpanExtent? extent,
    MouseCursor? cursor,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
  }) {
    return SheetSpan(
      onTap: onTap ?? this.onTap,
      onDoubleTap: onDoubleTap ?? this.onDoubleTap,
      onLongPress: onLongPress ?? this.onLongPress,
      foregroundDecoration: foregroundDecoration ?? this.foregroundDecoration,
      backgroundDecoration: backgroundDecoration ?? this.backgroundDecoration,
      padding: padding ?? this.padding,
      extent: extent ?? this.extent,
      onEnter: onEnter ?? this.onEnter,
      onExit: onExit ?? this.onExit,
      cursor: cursor ?? this.cursor,
    );
  }
}

extension SheetSpanExtensions on SheetSpan {
  Map<Type, GestureRecognizerFactory> getRecognizerFactories() {
    final factories = <Type, GestureRecognizerFactory>{};

    if (onTap != null) {
      factories[TapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(),
        (TapGestureRecognizer instance) {
          instance.onTap = onTap;
        },
      );
    }

    if (onDoubleTap != null) {
      factories[DoubleTapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
        () => DoubleTapGestureRecognizer(),
        (DoubleTapGestureRecognizer instance) {
          instance.onDoubleTap = onDoubleTap;
        },
      );
    }

    if (onLongPress != null) {
      factories[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(),
        (LongPressGestureRecognizer instance) {
          instance.onLongPress = onLongPress;
        },
      );
    }
    return factories;
  }

  Span toSpan() => TableSpan(
        recognizerFactories: getRecognizerFactories(),
        foregroundDecoration: foregroundDecoration,
        backgroundDecoration: backgroundDecoration,
        padding: padding,
        extent: extent,
        cursor: cursor,
        onEnter: onEnter,
        onExit: onExit,
      );
}
