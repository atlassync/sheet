import 'dart:async';

import 'package:flutter/material.dart';

enum SourceState { idle, processing, complete, intercepted }

abstract interface class PaginatedSheetSource<T> {
  void init();
  FutureOr<void> load();
  FutureOr<void> refresh();
  void filter(bool Function(T) test);
  void sort([int Function(T a, T b)? compare]);
  T? elementAt(int index);
  void insert(T item, [int? index]);
  void insertAll(Iterable<T> items, [int? index]);
  void remove(T item);
  void removeAt(int index);
  void removeAll();
  void clear();
  void reset();
  void dispose();
  int get page;
  int get pageSize;
  Iterable<T> get data;
  bool get hasMoreData;
  int get dataLength;
  ValueNotifier<SourceState> get state;
}

mixin PaginatedSheetSourceMixin<T> implements PaginatedSheetSource<T> {
  int _page = 0;
  int _pageSize = 20;
  final List<T> _originalData = [];
  List<T> _filteredData = [];
  bool _hasMoreData = true;
  final ValueNotifier<SourceState> _state = ValueNotifier(SourceState.idle);

  @override
  FutureOr<void> load() async {
    if (_state.value == SourceState.processing || !_hasMoreData) return;
    _state.value = SourceState.processing;

    var newPage = _page + 1;
    try {
      final nextPageData = await getNextPage(newPage, _pageSize);
      if (nextPageData.isEmpty || nextPageData.length < _pageSize) {
        _hasMoreData = false;
      } else {
        _originalData.addAll(nextPageData);
        _filteredData = List.from(_originalData);
        _page++;
        _hasMoreData = nextPageData.length >= _pageSize;
      }
      _state.value = SourceState.complete;
    } catch (e) {
      _state.value = SourceState.intercepted;
      rethrow;
    }
  }

  FutureOr<Iterable<T>> getNextPage(int page, int size);

  @override
  FutureOr<void> refresh() async {
    reset();
    await load();
  }

  set pageSize(int size) {
    if (size <= 0) return;
    _pageSize = size;
  }

  @override
  void filter(bool Function(T) test) {
    _state.value = SourceState.processing;
    _filteredData = _originalData.where(test).toList();
    _state.value = SourceState.complete;
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    _state.value = SourceState.processing;
    _filteredData.sort(compare);
    _state.value = SourceState.complete;
  }

  @override
  T? elementAt(int index) {
    return _filteredData.elementAtOrNull(index);
  }

  @override
  void insert(T item, [int? index]) {
    _state.value = SourceState.processing;
    if (index != null && index >= 0 && index < _originalData.length) {
      _originalData.insert(index, item);
    } else {
      _originalData.add(item);
    }
    _filteredData = List.from(_originalData);
    _state.value = SourceState.complete;
  }

  @override
  void insertAll(Iterable<T> items, [int? index]) {
    _state.value = SourceState.processing;
    if (index != null && index >= 0 && index < _originalData.length) {
      _originalData.insertAll(index, items);
    } else {
      _originalData.addAll(items);
    }
    _filteredData = List.from(_originalData);
    _state.value = SourceState.complete;
  }

  @override
  void remove(T item) {
    _state.value = SourceState.processing;
    _originalData.remove(item);
    _filteredData.remove(item);
    _state.value = SourceState.complete;
  }

  @override
  void removeAt(int index) {
    _state.value = SourceState.processing;
    T item = _originalData.removeAt(index);
    _filteredData.remove(item);
    _state.value = SourceState.complete;
  }

  @override
  void removeAll() {
    _state.value = SourceState.processing;
    _originalData.clear();
    _filteredData.clear();
    _state.value = SourceState.complete;
  }

  @override
  void clear() {
    _state.value = SourceState.processing;
    _filteredData = List.from(_originalData);
    _state.value = SourceState.complete;
  }

  @override
  void reset() {
    _originalData.clear();
    _filteredData.clear();
    _page = 0;
    _hasMoreData = true;
    _state.value = SourceState.idle;
  }

  @override
  void dispose() {
    reset();
    _state.dispose();
  }

  @override
  int get page => _page;

  @override
  int get pageSize => _pageSize;

  @override
  Iterable<T> get data => _filteredData;

  @override
  bool get hasMoreData => _hasMoreData;

  @override
  int get dataLength => _filteredData.length;

  @override
  ValueNotifier<SourceState> get state => _state;
}
