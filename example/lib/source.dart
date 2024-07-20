import 'dart:async';

import 'package:example/mock.dart';
import 'package:example/person.dart';
import 'package:sheet/sheet.dart';

class PersonAsyncSheetSource with PaginatedSheetSourceMixin<Person> {
  @override
  FutureOr<void> init() {
    pageSize = 10;
    insertAll(mockData);
  }

  @override
  FutureOr<Iterable<Person>> getNextPage(int page, int size) async {
    await Future.delayed(const Duration(seconds: 5));
    return [Person(firstName: 'firstName', lastName: 'lastName', age: 20)];
  }
}
