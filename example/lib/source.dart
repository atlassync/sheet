// Concrete implementation for Person
import 'package:example/person.dart';
import 'package:sheet/sheet.dart';

class PersonAsyncSheetSource extends AsyncSheetSource<Person> {
  PersonAsyncSheetSource({
    super.initialData,
    super.pageSize = 10,
  });

  @override
  Future<List<Person>> fetchData(int index) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock data for the page
    return List.generate(pageSize, (i) {
      int personIndex = index * pageSize + i;
      return Person(
        firstName: 'First$personIndex',
        lastName: 'Last$personIndex',
        age: 20 + (personIndex % 10),
      );
    });
  }
}

// Example usage
// Initial data to populate the first few pages
List<Person> initialData = List.generate(
    25,
    (i) => Person(
          firstName: 'InitialFirst$i',
          lastName: 'InitialLast$i',
          age: 20 + (i % 10),
        ));
