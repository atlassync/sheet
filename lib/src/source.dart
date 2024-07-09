import 'dart:async';
import 'package:flutter/foundation.dart';

enum SourceState { idle, processing, complete }

typedef SourceFetcher<T> = FutureOr<List<T>> Function(int page, int size);
typedef SourceFilter<T> = bool Function(T);
typedef SourceComparator<T> = int Function(T a, T b);
typedef SourceSearch<T> = FutureOr<List<T>> Function();

class AsyncSheetSource<T> {
  final SourceFetcher<T> fetcher;
  final bool cache;
  final Map<int, List<T>> _pages = {};
  final ValueNotifier<List<T>> _activePage = ValueNotifier([]);
  final ValueNotifier<SourceState> _state = ValueNotifier(SourceState.idle);
  final ValueNotifier<int> _pageIndex = ValueNotifier(1);
  final ValueNotifier<bool> _hasMoreData = ValueNotifier(true);

  int pageSize = 10; // Default page size

  AsyncSheetSource(
    this.fetcher, {
    List<T>? initialData,
    this.pageSize = 10,
    this.cache = true,
  }) {
    _activePage.addListener(_updateHasMoreDataFlag);
    if (initialData != null) {
      _initializeWithInitialData(initialData);
    } else {
      _loadPage(1);
    }
  }

  void _initializeWithInitialData(List<T> initialData) {
    for (var i = 0; i < initialData.length; i += pageSize) {
      var end = (i + pageSize > initialData.length)
          ? initialData.length
          : i + pageSize;
      _pages.putIfAbsent(
          (i ~/ pageSize) + 1, () => initialData.sublist(i, end));
    }
    _activePage.value = _pages.isNotEmpty ? _pages[1]! : [];
  }

  FutureOr<void> _loadPage(int index, {bool forceFetch = false}) async {
    if (_state.value == SourceState.processing) return;
    _state.value = SourceState.processing;

    if (cache && !forceFetch && _pages.containsKey(index)) {
      _state.value = SourceState.complete;
      _switchPage(index);
      return;
    }

    await _fetchAndUpdatePage(index);
    _switchPage(index);
  }

  Future<void> _fetchAndUpdatePage(int index) async {
    try {
      List<T> newData = await fetcher(index, pageSize);
      _pages.update(index, (_) => newData, ifAbsent: () => newData);
      _state.value = SourceState.complete;
    } catch (e) {
      debugPrint('Error loading page $index: $e');
      _state.value = SourceState.complete;
    }
  }

  FutureOr<void> fetchNextPage() async {
    int nextPageIndex = _activePageIndex + 1;
    await _loadPage(nextPageIndex);
  }

  FutureOr<void> refreshPage({int? index}) async {
    if (index != null && (index < 1 || index > _activePageIndex)) return;
    int pageIndexToRefresh = index ?? _activePageIndex;
    await _loadPage(pageIndexToRefresh, forceFetch: true);
  }

  FutureOr<void> fetchPreviousPage() async {
    int previousPageIndex = _activePageIndex - 1;
    if (previousPageIndex < 1) return;
    await _loadPage(previousPageIndex);
  }

  FutureOr<void> search(SourceSearch<T> delegate) async {
    _state.value = SourceState.processing;
    var result = await delegate.call();
    _activePage.value = result;
    _state.value = SourceState.complete;
  }

  void filter(SourceFilter<T> filter) {
    _state.value = SourceState.processing;
    List<T> filteredData = [];

    _pages.forEach((page, data) {
      filteredData.addAll(data.where(filter));
    });

    _activePage.value = filteredData;
    _state.value = SourceState.complete;
  }

  void sort(SourceComparator<T> comparator) {
    _state.value = SourceState.processing;
    List<T> sortedData = _activePage.value;
    sortedData.sort(comparator);

    _activePage.value = sortedData;
    _state.value = SourceState.complete;
  }

  void add(T item, {int? pageIndex}) {
    var index = pageIndex ?? _activePageIndex;
    _state.value = SourceState.processing;

    bool alreadyExists =
        _pages.values.any((pageItems) => pageItems.contains(item));
    if (!alreadyExists) {
      _pages.putIfAbsent(index, () => []);
      _pages[index]!.add(item);
    }

    if (_activePageIndex == index) {
      _activePage.value = _pages[index]!;
    }
    _state.value = SourceState.complete;
  }

  void addAll(List<T> items, {int? pageIndex}) {
    var index = pageIndex ?? _activePageIndex;
    _state.value = SourceState.processing;

    for (var item in items) {
      bool alreadyExists =
          _pages.values.any((pageItems) => pageItems.contains(item));
      if (!alreadyExists) {
        _pages.putIfAbsent(index, () => []);
        _pages[index]!.add(item);
      }
    }

    if (_activePageIndex == index) {
      _activePage.value = _pages[index]!;
    }
    _state.value = SourceState.complete;
  }

  void remove(T item, {int? pageIndex}) {
    var index = pageIndex ?? _activePageIndex;
    _state.value = SourceState.processing;
    _pages[index]?.remove(item);
    if (_activePageIndex == index) {
      _activePage.value = _pages[index]!;
    }
    _state.value = SourceState.complete;
  }

  void removeAll({int? pageIndex}) {
    var index = pageIndex ?? _activePageIndex;
    _state.value = SourceState.processing;
    _pages.remove(index);
    if (_activePageIndex == index) {
      _activePage.value = [];
    }
    _state.value = SourceState.complete;
  }

  ValueNotifier<int> get pageIndex => _pageIndex;
  ValueNotifier<List<T>> get activePage => _activePage;
  ValueNotifier<SourceState> get state => _state;
  ValueNotifier<bool> get hasMoreData => _hasMoreData;

  void _switchPage(int index) {
    _pageIndex.value = index;
    _activePage.value = _pages[index]!;
  }

  void _updateHasMoreDataFlag() {
    int highestCachedPage = _pages.keys.reduce((a, b) => a > b ? a : b);

    _hasMoreData.value = _activePage.value.length >= pageSize ||
        _activePageIndex < highestCachedPage;
  }

  int get _activePageIndex => _pageIndex.value;

  void dispose() {
    _activePage.removeListener(_updateHasMoreDataFlag);
    _state.dispose();
    _activePage.dispose();
    _pageIndex.dispose();
  }
}
