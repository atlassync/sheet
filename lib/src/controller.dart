import 'package:flutter/material.dart';

class SheetDataSource<T> {
  SheetDataSource({
    required this.fetchPage,
    this.pageSize = 10,
    List<T>? initialData,
  }) : _initialData = initialData ?? [] {
    _items.value = List.from(_initialData);
    _cachedPages[1] = _initialData;
  }

  final Future<List<T>> Function(int page, int pageSize) fetchPage;
  final int pageSize;

  final ValueNotifier<List<T>> _items = ValueNotifier([]);
  final ValueNotifier<int> _currentPage = ValueNotifier(1);
  final ValueNotifier<bool> _isFetching = ValueNotifier(false);
  final ValueNotifier<bool> _hasMoreData = ValueNotifier(true);
  final Map<int, List<T>> _cachedPages = {};

  final List<T> _initialData;

  ValueNotifier<List<T>> get items => _items;
  ValueNotifier<int> get currentPage => _currentPage;
  ValueNotifier<bool> get isFetching => _isFetching;
  ValueNotifier<bool> get hasMoreData => _hasMoreData;

  Future<void> fetchNextPage() async {
    if (_isFetching.value) return;

    _isFetching.value = true;

    final nextPage = _currentPage.value + 1;
    if (_cachedPages.containsKey(nextPage)) {
      _items.value = _cachedPages[nextPage]!;
      _currentPage.value = nextPage;
    } else {
      try {
        if (_hasMoreData.value) {
          final newItems = await fetchPage(nextPage, pageSize);
          if (newItems.isEmpty) {
            _hasMoreData.value = false;
          } else if (newItems.length < 10) {
            _hasMoreData.value = false;
            _cachedPages[nextPage] = newItems;
            _items.value = newItems;
            _currentPage.value = nextPage;
          } else {
            _cachedPages[nextPage] = newItems;
            _items.value = newItems;
            _currentPage.value = nextPage;
          }
        }
      } catch (e) {
        debugPrint('Failed to fetch data: $e');
      }
    }

    _isFetching.value = false;
  }

  Future<void> fetchPreviousPage() async {
    if (_isFetching.value || _currentPage.value <= 1) return;

    _isFetching.value = true;

    final previousPage = _currentPage.value - 1;
    if (_cachedPages.containsKey(previousPage)) {
      _items.value = _cachedPages[previousPage]!;
      _currentPage.value = previousPage;
    } else {
      try {
        final newItems = await fetchPage(previousPage, pageSize);
        _cachedPages[previousPage] = newItems;
        _items.value = newItems;
        _currentPage.value = previousPage;
      } catch (e) {
        debugPrint('Failed to fetch data: $e');
      }
    }

    _isFetching.value = false;
  }

  void reset() {
    _cachedPages.clear();
    _currentPage.value = 1;
    _items.value = List.from(_initialData);
    _cachedPages[1] = _initialData;
  }

  void clearData() {
    _items.value = [];
  }
}
