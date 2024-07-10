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
      home: PaginatedSheet(),
    );
  }
}

class PaginatedSheet extends StatefulWidget {
  const PaginatedSheet({super.key});

  @override
  State<PaginatedSheet> createState() => _PaginatedSheetState();
}

class _PaginatedSheetState extends State<PaginatedSheet> {
  late final SheetSource<Person> _source;

  @override
  void initState() {
    super.initState();
    _source = PersonAsyncSheetSource();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Sheet<Person>(
        source: _source,
        columns: _columns,
        rowSpanBuilder: _defaultRowSpanBuilder,
        columnSpanBuilder: _defaultColumnSpanBuilder,
        defaultRowSpan: _defaultSpan,
        defaultColumnSpan: _defaultSpan,
      ),
      persistentFooterButtons: [
        TextButton(
          onPressed: () async {
            await _source.refreshPage();
          },
          child: const Text('Refresh'),
        ),
        ValueListenableBuilder(
            valueListenable: _source.pageIndex,
            builder: (context, page, _) {
              return TextButton(
                onPressed: page > 1
                    ? () async {
                        await _source.fetchPreviousPage();
                      }
                    : null,
                child: const Text('Previous'),
              );
            }),
        const VerticalDivider(width: 2.0),
        ValueListenableBuilder(
          valueListenable: _source.pageIndex,
          builder: (context, index, _) {
            return Text('Page $index');
          },
        ),
        const VerticalDivider(width: 2.0),
        ValueListenableBuilder(
            valueListenable: _source.hasMoreData,
            builder: (context, hasMoreData, _) {
              return TextButton(
                onPressed: hasMoreData
                    ? () async {
                        await _source.fetchNextPage();
                      }
                    : null,
                child: const Text('Next'),
              );
            }),
      ],
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

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  static const double _factor = 0.5;

  @override
  Widget build(BuildContext context) {
    return const Center(
      widthFactor: _factor,
      heightFactor: _factor,
      child: CircularProgressIndicator(),
    );
  }
}

class _IndexColumn extends SheetColumn<Person> {
  const _IndexColumn();

  @override
  Widget cell(BuildContext context, ChildVicinity vicinity, Person? data,
      SourceState state) {
    return Text(
      vicinity.yIndex.toString(),
    );
  }

  @override
  Widget label(BuildContext context, ChildVicinity vicinity) {
    return const Text('#');
  }
}

class _SearchColumn extends SheetColumn<Person> {
  const _SearchColumn();

  @override
  Widget cell(BuildContext context, ChildVicinity vicinity, Person? data,
      SourceState state) {
    return const SizedBox.shrink();
  }

  @override
  Widget label(BuildContext context, ChildVicinity vicinity) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Search...',
      ),
      onChanged: (value) => Sheet.maybeOf<Person>(context)?.filter(
        (e) => e.firstName.contains(value) || e.lastName.contains(value),
      ),
    );
  }
}

class _FirstNameColumn extends SheetColumn<Person> {
  const _FirstNameColumn();

  @override
  Widget cell(BuildContext context, ChildVicinity vicinity, Person? data,
      SourceState state) {
    return state == SourceState.processing
        ? const _LoadingIndicator()
        : Text(data?.firstName ?? '');
  }

  @override
  Widget label(BuildContext context, ChildVicinity vicinity) {
    return TextButton(
      child: const Text('First Name'),
      onPressed: () {
        Sheet.maybeOf<Person>(context)
            ?.sort((a, b) => a.firstName.compareTo(b.firstName));
      },
    );
  }
}

class _LastNameColumn extends SheetColumn<Person> {
  const _LastNameColumn();

  @override
  Widget cell(BuildContext context, ChildVicinity vicinity, Person? data,
      SourceState state) {
    return state == SourceState.processing
        ? const _LoadingIndicator()
        : Text(data?.lastName ?? '');
  }

  @override
  Widget label(BuildContext context, ChildVicinity vicinity) {
    return TextButton(
      child: const Text('Last Name'),
      onPressed: () {
        Sheet.maybeOf<Person>(context)
            ?.sort((a, b) => a.lastName.compareTo(b.lastName));
      },
    );
  }
}

class _AgeColumn extends SheetColumn<Person> {
  const _AgeColumn();

  @override
  Widget cell(BuildContext context, ChildVicinity vicinity, Person? data,
      SourceState state) {
    return state == SourceState.processing
        ? const _LoadingIndicator()
        : Text(data?.age.toString() ?? '');
  }

  @override
  Widget label(BuildContext context, ChildVicinity vicinity) {
    return TextButton(
      child: const Text('Age'),
      onPressed: () {
        Sheet.maybeOf<Person>(context)?.sort((a, b) => a.age.compareTo(b.age));
      },
    );
  }
}