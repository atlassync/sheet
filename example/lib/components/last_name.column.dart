part of '../main.dart';

class _LastNameColumn extends SheetColumn<Person> {
  const _LastNameColumn();

  @override
  Widget cell(BuildContext context, ChildVicinity vicinity, Person? data,
      SourceState state) {
    return Skeletonizer.zone(
      enabled: state == SourceState.processing,
      child: Skeleton.shade(
        child: Text(data?.lastName ?? ''),
      ),
    );
  }

  @override
  Widget label(BuildContext context, ChildVicinity vicinity) {
    return TextButton(
      child: const Text('Last Name'),
      onPressed: () {
        PaginatedSheet.maybeOf<Person>(context)
            ?.sort((a, b) => a.lastName.compareTo(b.lastName));
      },
    );
  }
}