import 'package:example/person.dart';
import 'package:example/source.dart';
import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'components/age_column.dart';
part 'components/first_name_column.dart';
part 'components/index.column.dart';
part 'components/last_name.column.dart';
part 'components/search_column.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      home: const Sheet(),
    );
  }
}

class Sheet extends StatefulWidget {
  const Sheet({super.key});

  @override
  State<Sheet> createState() => _SheetState();
}

class _SheetState extends State<Sheet> {
  late final PaginatedSheetSource<Person> _source;

  @override
  void initState() {
    super.initState();
    _source = PersonAsyncSheetSource()..init();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PaginatedSheet<Person>(
        source: _source,
        columns: _columns,
        rowSpanBuilder: _defaultRowSpanBuilder,
        columnSpanBuilder: _defaultColumnSpanBuilder,
        defaultRowSpan: _defaultSpan,
        defaultColumnSpan: _defaultSpan,
      ),
    );
  }

  List<SheetColumn<Person>> get _columns => const [
        _IndexColumn(),
        _FirstNameColumn(),
        _LastNameColumn(),
        _AgeColumn(),
        _SearchColumn()
      ];

  SheetSpan? _defaultColumnSpanBuilder(int index, SourceState _) {
    return index == 0
        ? _defaultSpan.copyWith(
            extent: const FixedSpanExtent(
              48.0,
            ),
          )
        : null;
  }

  SheetSpan? _defaultRowSpanBuilder(int index, SourceState _) {
    return _defaultSpan.copyWith(
      extent: FixedSpanExtent(
        index == 0 ? 48.0 : 96.0,
      ),
    );
  }

  SheetSpan get _defaultSpan => const SheetSpan(
        extent: FixedSpanExtent(240.0),
        foregroundDecoration: SpanDecoration(
          border: SpanBorder(
            trailing: BorderSide(
              width: 2.0,
              color: Colors.grey,
            ),
          ),
        ),
      );
}