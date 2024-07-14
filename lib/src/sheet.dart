import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';
import 'package:sheet/src/scope.dart';

typedef SheetSpanBuilder = SheetSpan? Function(int index, SourceState state);
final _defaultSpan = const SheetSpan().toSpan();

class PaginatedSheet<T> extends StatelessWidget {
  const PaginatedSheet({
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
  final PaginatedSheetSource<T> source;
  final List<SheetColumn<T>> columns;
  final SheetSpanBuilder? columnSpanBuilder;
  final SheetSpanBuilder? rowSpanBuilder;
  final SheetSpan? defaultRowSpan;
  final SheetSpan? defaultColumnSpan;

  static PaginatedSheetSource<T> of<T>(BuildContext context) {
    return PaginatedSheetScope.of<T>(context)!;
  }

  static PaginatedSheetSource<T>? maybeOf<T>(BuildContext context) {
    return PaginatedSheetScope.of<T>(context);
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedSheetScope<T>(
      source: source,
      child: _PaginatedSheet<T>(
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

class _PaginatedSheet<T> extends StatefulWidget {
  const _PaginatedSheet({
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
  final PaginatedSheetSource<T> source;
  final List<SheetColumn<T>> columns;
  final SheetSpanBuilder? columnSpanBuilder;
  final SheetSpanBuilder? rowSpanBuilder;
  final SheetSpan? defaultRowSpan;
  final SheetSpan? defaultColumnSpan;

  @override
  State<_PaginatedSheet<T>> createState() => _PaginatedSheetState<T>();
}

class _PaginatedSheetState<T> extends State<_PaginatedSheet<T>> {
  late final ValueNotifier<SourceState> _state;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _state = widget.source.state;
    _state.addListener(_onSourceStateChanged);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _state.removeListener(_onSourceStateChanged);
    _state.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSourceStateChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      widget.source.load();
    }
  }

  int? get _columnCount =>
      widget.columns.isEmpty ? null : widget.columns.length;

  int? get _rowCount => _state.value == SourceState.processing
      ? widget.source.dataLength > 0
          ? widget.source.dataLength
          : widget.source.dataLength + 2
      : widget.source.dataLength + 1;

  @override
  Widget build(BuildContext context) {
    return TableView.builder(
      primary: widget.primary,
      mainAxis: widget.mainAxis,
      horizontalDetails: widget.horizontalDetails,
      verticalDetails:
          widget.verticalDetails.copyWith(controller: _scrollController),
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
    final item = widget.source.elementAt(itemIndex);
    final column = widget.columns.elementAtOrNull(vicinity.xIndex);
    return column?.cell(context, vicinity, item, _state.value) ??
        const SizedBox.shrink();
  }

  Span? _buildRowSpan(int index) {
    return widget.rowSpanBuilder?.call(index, _state.value)?.toSpan() ??
        widget.defaultRowSpan?.toSpan() ??
        _defaultSpan;
  }

  Span? _buildColumnSpan(int index) {
    return widget.columnSpanBuilder?.call(index, _state.value)?.toSpan() ??
        widget.defaultColumnSpan?.toSpan() ??
        _defaultSpan;
  }
}
