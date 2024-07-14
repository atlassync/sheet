part of '../main.dart';

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