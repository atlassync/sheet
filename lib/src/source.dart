import 'dart:async';
import 'package:flutter/foundation.dart';

enum SourceState { idle, loading, success, failure }

typedef SourceFetcher<T> = FutureOr<List<T>> Function(int page, int size);

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
      fetchNextPage();
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
    if (_state.value == SourceState.loading) return;
    _state.value = SourceState.loading;

    if (cache && !forceFetch && _pages.containsKey(index)) {
      _state.value = SourceState.success;
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
      _state.value = SourceState.success;
    } catch (e) {
      debugPrint('Error loading page $index: $e');
      _state.value = SourceState.failure;
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
