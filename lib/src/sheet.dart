import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';
import 'package:sheet/src/provider.dart';

typedef SheetSpanBuilder = SheetSpan? Function(int index, SourceState state);
final _defaultSpan = const SheetSpan().toSpan();

class Sheet<T> extends StatelessWidget {
  const Sheet({
    super.key,
    this.primary,
    this.mainAxis = Axis.vertical,
    this.horizontalDetails = const ScrollableDetails.horizontal(),
    this.verticalDetails = const ScrollableDetails.vertical(),
    this.cacheExtent,
    this.diagonalDragBehavior = DiagonalDragBehavior.none,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.pinnedColumnCount = 1,
    this.pinnedRowCount = 1,
    required this.source,
    required this.columns,
    this.columnSpanBuilder,
    this.rowSpanBuilder,
    this.defaultRowSpan,
    this.defaultColumnSpan,
  });

  final bool? primary;
  final Axis mainAxis;
  final ScrollableDetails horizontalDetails;
  final ScrollableDetails verticalDetails;
  final double? cacheExtent;
  final DiagonalDragBehavior diagonalDragBehavior;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;
  final int pinnedRowCount;
  final int pinnedColumnCount;
  final SheetSource<T> source;
  final List<SheetColumn<T>> columns;
  final SheetSpanBuilder? columnSpanBuilder;
  final SheetSpanBuilder? rowSpanBuilder;
  final SheetSpan? defaultRowSpan;
  final SheetSpan? defaultColumnSpan;

  static SheetSource<T> of<T>(BuildContext context) {
    return SheetScope.of<T>(context)!;
  }

  static SheetSource<T>? maybeOf<T>(BuildContext context) {
    return SheetScope.of<T>(context);
  }

  @override
  Widget build(BuildContext context) {
    return SheetScope<T>(
      source: source,
      child: _AsyncPaginatedSheet<T>(
        key: key,
        primary: primary,
        mainAxis: mainAxis,
        horizontalDetails: horizontalDetails,
        verticalDetails: verticalDetails,
        cacheExtent: cacheExtent,
        diagonalDragBehavior: diagonalDragBehavior,
        dragStartBehavior: dragStartBehavior,
        keyboardDismissBehavior: keyboardDismissBehavior,
        clipBehavior: clipBehavior,
        pinnedColumnCount: pinnedColumnCount,
        pinnedRowCount: pinnedRowCount,
        source: source,
        columns: columns,
        columnSpanBuilder: columnSpanBuilder,
        rowSpanBuilder: rowSpanBuilder,
        defaultRowSpan: defaultRowSpan,
        defaultColumnSpan: defaultColumnSpan,
      ),
    );
  }
}

class _AsyncPaginatedSheet<T> extends StatefulWidget {
  const _AsyncPaginatedSheet({
    super.key,
    this.primary,
    this.mainAxis = Axis.vertical,
    this.horizontalDetails = const ScrollableDetails.horizontal(),
    this.verticalDetails = const ScrollableDetails.vertical(),
    this.cacheExtent,
    this.diagonalDragBehavior = DiagonalDragBehavior.none,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.pinnedColumnCount = 1,
    this.pinnedRowCount = 1,
    required this.source,
    required this.columns,
    this.columnSpanBuilder,
    this.rowSpanBuilder,
    this.defaultRowSpan,
    this.defaultColumnSpan,
  });

  final bool? primary;
  final Axis mainAxis;
  final ScrollableDetails horizontalDetails;
  final ScrollableDetails verticalDetails;
  final double? cacheExtent;
  final DiagonalDragBehavior diagonalDragBehavior;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;
  final int pinnedRowCount;
  final int pinnedColumnCount;
  final SheetSource<T> source;
  final List<SheetColumn<T>> columns;
  final SheetSpanBuilder? columnSpanBuilder;
  final SheetSpanBuilder? rowSpanBuilder;
  final SheetSpan? defaultRowSpan;
  final SheetSpan? defaultColumnSpan;

  @override
  State<_AsyncPaginatedSheet<T>> createState() =>
      _AsyncPaginatedSheetState<T>();
}

class _AsyncPaginatedSheetState<T> extends State<_AsyncPaginatedSheet<T>> {
  late SourceState _state;
  @override
  void initState() {
    super.initState();
    _state = widget.source.state.value;
    widget.source.state.addListener(_onSourceStateChanged);
  }

  @override
  void dispose() {
    widget.source.state.removeListener(_onSourceStateChanged);
    super.dispose();
  }

  void _onSourceStateChanged() {
    setState(() {
      _state = widget.source.state.value;
    });
  }

  int? get _columnCount =>
      widget.columns.isEmpty ? null : widget.columns.length;

  int? get _rowCount => _state == SourceState.processing
      ? null
      : widget.source.activePage.value.length + 1;

  @override
  Widget build(BuildContext context) {
    return TableView.builder(
      primary: widget.primary,
      mainAxis: widget.mainAxis,
      horizontalDetails: widget.horizontalDetails,
      verticalDetails: widget.verticalDetails,
      cacheExtent: widget.cacheExtent,
      diagonalDragBehavior: widget.diagonalDragBehavior,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      clipBehavior: widget.clipBehavior,
      pinnedColumnCount: widget.pinnedColumnCount,
      pinnedRowCount: widget.pinnedRowCount,
      columnCount: _columnCount,
      rowCount: _rowCount,
      columnBuilder: _buildColumnSpan,
      rowBuilder: _buildRowSpan,
      cellBuilder: (_, vicinity) => TableViewCell(
        child: _buildCell(
          vicinity,
        ),
      ),
    );
  }

  Widget _buildCell(ChildVicinity vicinity) {
    if (vicinity.yIndex == 0) {
      return widget.columns
              .elementAtOrNull(vicinity.xIndex)
              ?.label(context, vicinity) ??
          const SizedBox.shrink();
    }

    final itemIndex = vicinity.yIndex - 1;
    final item = widget.source.activePage.value.elementAtOrNull(itemIndex);
    final column = widget.columns.elementAtOrNull(vicinity.xIndex);
    return column?.cell(context, vicinity, item, _state) ??
        const SizedBox.shrink();
  }

  Span? _buildRowSpan(int index) {
    return widget.rowSpanBuilder
            ?.call(index, widget.source.state.value)
            ?.toSpan() ??
        widget.defaultRowSpan?.toSpan() ??
        _defaultSpan;
  }

  Span? _buildColumnSpan(int index) {
    return widget.columnSpanBuilder
            ?.call(index, widget.source.state.value)
            ?.toSpan() ??
        widget.defaultColumnSpan?.toSpan() ??
        _defaultSpan;
  }
}
