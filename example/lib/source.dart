import 'package:example/mock.dart';
import 'package:example/person.dart';
import 'package:sheet/sheet.dart';

class PersonAsyncSheetSource extends SheetSource<Person> {
  PersonAsyncSheetSource()
      : super(fetchData, pageSize: 10, initialData: mockData);

  static Future<List<Person>> fetchData(int index, int size) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 5));

    // Generate mock data for the page
    return List.generate(5, (i) {
      // You can use pageSize here if you prefer
      int personIndex =
          index * 10 + i; // Use pageSize instead of 10 if preferred
      return Person(
        firstName: 'First$personIndex',
        lastName: 'Last$personIndex',
        age: 20 + (personIndex % 10),
      );
    });
  }
}
