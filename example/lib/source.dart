import 'package:example/person.dart';
import 'package:sheet/sheet.dart';

class PersonAsyncSheetSource extends AsyncSheetSource<Person> {
  PersonAsyncSheetSource()
      : super(
          fetchData,
          initialData: initialData,
          pageSize: 6,
          cache: true
        );

  static Future<List<Person>> fetchData(int index, int size) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock data for the page
    return List.generate(5, (i) { // You can use pageSize here if you prefer
      int personIndex = index * 10 + i; // Use pageSize instead of 10 if preferred
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
  10,
  (i) => Person(
    firstName: 'InitialFirst$i',
    lastName: 'InitialLast$i',
    age: 20 + (i % 10),
  ),
);
