import 'dart:async';

import 'package:flutter/foundation.dart';

enum SourceState { idle, loading, success, failure }

typedef SourceFetcher<T> = FutureOr<List<T>> Function(int page, int size);

class AsyncSheetSource<T> {
  final SourceFetcher<T> fetcher;
  final Map<int, List<T>> _pages = {};
  final ValueNotifier<List<T>> _activePage = ValueNotifier([]);
  final ValueNotifier<SourceState> _state = ValueNotifier(SourceState.idle);
  final ValueNotifier<int> _pageIndex = ValueNotifier(1);

  int pageSize = 10; // Default page size

  AsyncSheetSource({
    required this.fetcher,
    List<T>? initialData,
    this.pageSize = 10,
  }) {
    if (initialData != null) {
      // Slice the initialData into pages
      for (var i = 0; i < initialData.length; i += pageSize) {
        var end = (i + pageSize > initialData.length)
            ? initialData.length
            : i + pageSize;
        _pages.putIfAbsent((i ~/ pageSize) + 1, () => initialData.sublist(i, end));
      }

      _activePage.value = _pages.isNotEmpty ? _pages[1]! : [];
      return;
    }
    fetchNextPage();
  }

  FutureOr<void> _loadPage(int index) async {
    _state.value = SourceState.loading;
    if (_pages[index] != null) {
      _state.value = SourceState.success;
      return;
    }

    try {
      List<T> newData = await fetcher(index, pageSize);

      _pages.putIfAbsent(index, () => newData);
      _state.value = SourceState.success;
    } catch (e) {
      debugPrint('Error loading page $index: $e');
      _state.value = SourceState.failure;
    }
  }

  FutureOr<void> fetchNextPage() async {
    int nextPageIndex = _activePageIndex + 1;

    await _loadPage(nextPageIndex);
    _switchPage(nextPageIndex);
  }

  FutureOr<void> fetchPreviousPage() async {
    int previousPageIndex = _activePageIndex - 1;
    if (previousPageIndex < 1) return;

    await _loadPage(previousPageIndex);
    _switchPage(previousPageIndex);
  }

  ValueNotifier<int> get pageIndex => _pageIndex;
  ValueNotifier<List<T>> get activePage => _activePage;
  ValueNotifier<SourceState> get state => _state;

  void _switchPage(int index) {
    _pageIndex.value = index;
    _activePage.value = _pages[index]!;
  }

  int get _activePageIndex => _pageIndex.value;

  void dispose() {
    _state.dispose();
    _activePage.dispose();
    _pageIndex.dispose();
  }
}
