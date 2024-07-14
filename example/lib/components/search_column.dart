part of '../main.dart';

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
      onChanged: (value) => PaginatedSheet.maybeOf<Person>(context)?.filter(
        (e) => e.firstName.contains(value) || e.lastName.contains(value),
      ),
    );
  }
}