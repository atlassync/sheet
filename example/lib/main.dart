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
      home: Sheet(),
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
      body: AsyncPaginatedSheet<Person>(
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

  List<SheetColumn<Person>> get _columns => [
        SheetColumn<Person>(
          label: const Text('#'),
          builder: (vicinity, item, state) => Text(
            vicinity.yIndex.toString(),
          ),
        ),
        SheetColumn<Person>(
          label: _BuildFirstName(_source),
          builder: (vicinity, item, state) => state != SourceState.processing
              ? Text(item?.firstName ?? '')
              : const _LoadingIndicator(),
        ),
        SheetColumn<Person>(
          label: _BuildLastName(_source),
          builder: (vicinity, item, state) => state != SourceState.processing
              ? Text(item?.lastName ?? '')
              : const _LoadingIndicator(),
        ),
        SheetColumn<Person>(
          label: _BuildAge(_source),
          builder: (vicinity, item, state) => state != SourceState.processing
              ? Text(item?.age.toString() ?? '')
              : const _LoadingIndicator(),
        ),
        SheetColumn<Person>(
          label: _BuildSearchField(_source),
          builder: (vicinity, item, state) => const SizedBox.shrink(),
        ),
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

class _BuildSearchField extends StatelessWidget {
  const _BuildSearchField(this._source);

  final AsyncSheetSource<Person> _source;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Search...',
      ),
      onChanged: (value) => _source.filter(
        (e) => e.firstName.contains(value) || e.lastName.contains(value),
      ),
    );
  }
}

class _BuildFirstName extends StatelessWidget {
  const _BuildFirstName(this._source);

  final AsyncSheetSource<Person> _source;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('First Name'),
      onPressed: () {
        _source.sort((a, b) => a.firstName.compareTo(b.firstName));
      },
    );
  }
}

class _BuildLastName extends StatelessWidget {
  const _BuildLastName(this._source);

  final AsyncSheetSource<Person> _source;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Last Name'),
      onPressed: () {
        _source.sort((a, b) => a.lastName.compareTo(b.lastName));
      },
    );
  }
}

class _BuildAge extends StatelessWidget {
  const _BuildAge(this._source);

  final AsyncSheetSource<Person> _source;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Age'),
      onPressed: () {
        _source.sort((a, b) => a.age.compareTo(b.age));
      },
    );
  }
}
