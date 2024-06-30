import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:sheet/src/column.dart';
import 'package:sheet/src/controller.dart';
import 'package:sheet/src/row.dart';

class Sheet<T> extends StatefulWidget {
  const Sheet({
    super.key,
    required this.source,
    required this.columns,
    required this.rows,
    required this.columnSpan,
    required this.rowSpan,
    this.primary,
    this.mainAxis = Axis.vertical,
    this.horizontalDetails = const ScrollableDetails.horizontal(),
    this.verticalDetails = const ScrollableDetails.vertical(),
    this.cacheExtent,
    this.diagonalDragBehavior = DiagonalDragBehavior.none,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.pinnedColumnCount = 0,
    this.pinnedRowCount = 0,
    this.pinnedExtent = const FixedSpanExtent(48.0),
  });

  final SheetDataSource<T> source;
  final List<SheetColumn> columns;
  final List<SheetRow<T>> rows;
  final TableSpanBuilder columnSpan;
  final TableSpanBuilder rowSpan;
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
  final SpanExtent pinnedExtent;

  @override
  State<Sheet<T>> createState() => _SheetState<T>();
}

class _SheetState<T> extends State<Sheet<T>> {
  late int _rowCount;
  late int _columnCount;
  @override
  void initState() {
    super.initState();
    for (var element in widget.rows) {
      if (widget.columns.length != element.builder(context, 0, null).length) {
        throw Exception(
            'Each row must contain exactly as many cells as there are columns.');
      }
    }
    _rowCount = widget.source.items.value.length + 1;
    _columnCount = widget.columns.length;

    widget.source.items.addListener(_handleItemsChanged);
  }

  @override
  void dispose() {
    widget.source.items.removeListener(_handleItemsChanged);
    super.dispose();
  }

  void _handleItemsChanged() {
    setState(() {
      _rowCount = widget.source.items.value.length + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.source.isFetching,
      builder: (context, isFetching, child) {
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
          columnBuilder: widget.columnSpan,
          rowBuilder: widget.rowSpan,
          rowCount: isFetching ? null : _rowCount,
          columnCount: _columnCount,
          cellBuilder: (_, vicinity) => TableViewCell(
            child: isFetching
                ? _buildLoadingCells(vicinity)
                : _buildCell(
                    vicinity,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildCell(ChildVicinity vicinity) {
    if (vicinity.yIndex == 0) {
      return widget.columns.elementAt(vicinity.xIndex).builder(context);
    }
    if (vicinity.yIndex == _rowCount) {
      return const SizedBox.shrink();
    }
    final itemIndex = vicinity.yIndex - 1;
    final item = widget.source.items.value[itemIndex];
    final cellWidgets =
        widget.rows[itemIndex].builder(context, vicinity.yIndex, item);
    return cellWidgets[vicinity.xIndex].builder(context);
  }

  Widget _buildLoadingCells(ChildVicinity vicinity) {
    if (vicinity.yIndex == 0) {
      return widget.columns.elementAt(vicinity.xIndex).builder(context);
    }

    return widget.rows.isEmpty
        ? const CircularProgressIndicator()
        : widget.rows.first
            .builder(context, vicinity.yIndex, null)
            .elementAt(vicinity.xIndex)
            .builder(context);
  }
}
