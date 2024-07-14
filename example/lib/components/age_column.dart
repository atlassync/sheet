part of '../main.dart';

class _AgeColumn extends SheetColumn<Person> {
  const _AgeColumn();

  @override
  Widget cell(BuildContext context, ChildVicinity vicinity, Person? data,
      SourceState state) {
    return Skeletonizer.zone(
      enabled: state == SourceState.processing,
      child: Skeleton.shade(
        child: Text(data?.age.toString() ?? ''),
      ),
    );
  }

  @override
  Widget label(BuildContext context, ChildVicinity vicinity) {
    return TextButton(
      child: const Text('Age'),
      onPressed: () {
        PaginatedSheet.maybeOf<Person>(context)
            ?.sort((a, b) => a.age.compareTo(b.age));
      },
    );
  }
}
