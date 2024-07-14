part of '../main.dart';

class _FirstNameColumn extends SheetColumn<Person> {
  const _FirstNameColumn();

  @override
  Widget cell(BuildContext context, ChildVicinity vicinity, Person? data,
      SourceState state) {
    return Skeletonizer.zone(
      enabled: state == SourceState.processing,
      child: Skeleton.shade(
        child: Text(data?.firstName ?? ''),
      ),
    );
  }

  @override
  Widget label(BuildContext context, ChildVicinity vicinity) {
    return TextButton(
      child: const Text('First Name'),
      onPressed: () {
        PaginatedSheet.maybeOf<Person>(context)
            ?.sort((a, b) => a.firstName.compareTo(b.firstName));
      },
    );
  }
}
