import 'package:example/person.dart';
import 'package:example/source.dart';
import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Sheet(),
      ),
    );
  }
}

class Sheet extends StatefulWidget {
  const Sheet({super.key});

  @override
  State<Sheet> createState() => _SheetState();
}

class _SheetState extends State<Sheet> {
  late final AsyncSheetSource<Person> _source;
  
  @override
  void initState() {
    super.initState();
    _source = PersonAsyncSheetSource(initialData: initialData);
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncPaginatedSheet<Person>(
      source: _source,
      columns: _columns,
      rowSpanBuilder: _rowBuilder,
      columnSpanBuilder: _columnBuilder,
    );
  }

  List<SheetColumn<Person>> get _columns => [
        SheetColumn<Person>(
          label: const Text('#'),
          builder: (vicinity, item, state) => Text(vicinity.yIndex.toString()),
        ),
        SheetColumn<Person>(
          label: const Text('First Name'),
          builder: (vicinity, item, state) => Text(item!.firstName),
        ),
        SheetColumn<Person>(
          label: const Text('Last Name'),
          builder: (vicinity, item, state) => Text(item!.lastName),
        ),
        SheetColumn<Person>(
          label: const Text('Age'),
          builder: (vicinity, item, state) => Text(item!.age.toString()),
        ),
      ];

  SheetSpan _rowBuilder(int index, SourceState _) {
    return SheetSpan(
      extent: index == 0
          ? const FixedSpanExtent(48.0)
          : const FixedSpanExtent(96.0),
      foregroundDecoration: const SpanDecoration(
        border: SpanBorder(
          trailing: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      onTap: () => debugPrint('$index'),
      onDoubleTap: () => debugPrint('double-tap'),
    );
  }

  SheetSpan _columnBuilder(int index, SourceState _) {
    return SheetSpan(
      extent: index == 0
          ? const FixedSpanExtent(48.0)
          : const FixedSpanExtent(96.0),
      foregroundDecoration: const SpanDecoration(
        border: SpanBorder(
          trailing: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
