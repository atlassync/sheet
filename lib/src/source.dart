import 'dart:async';

import 'package:flutter/material.dart';

enum SourceState { idle, processing, complete, intercepted }

abstract interface class PaginatedSheetSource<T> {
  FutureOr<void> init();
  FutureOr<void> load();
  FutureOr<void> refresh();
  void filter(bool Function(T) test);
  void sort([int Function(T a, T b)? compare]);
  T? elementAt(int index);
  void replaceWhere(bool Function(T) test, T Function(T) copyFunction);
  void put(T item, bool Function(T) test);
  void putAll(Iterable<T> items, bool Function(T, T) test);
  void insert(T item, [int? index]);
  void insertAll(Iterable<T> items, [int? index]);
  void remove(T item);
  void removeAt(int index);
  void removeAll();
  void clear();
  void reset();
  void dispose();
  void notify(SourceState state);
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
  FutureOr<void> init() {}

  @override
  FutureOr<void> load() async {
    if (_state.value == SourceState.processing || !_hasMoreData) return;
    notify(SourceState.processing);

    var newPage = _page + 1;
    try {
      final nextPageData = await getNextPage(newPage, _pageSize);
      _originalData.addAll(nextPageData);
      _filteredData = List.from(_originalData);
      _page = newPage;
      _hasMoreData = nextPageData.length >= _pageSize;
      notify(SourceState.complete);
    } catch (e) {
      notify(SourceState.intercepted);
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
    notify(SourceState.processing);
    _filteredData = _originalData.where(test).toList();
    notify(SourceState.complete);
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    notify(SourceState.processing);
    _filteredData.sort(compare);
    notify(SourceState.complete);
  }

  @override
  T? elementAt(int index) {
    return _filteredData.elementAtOrNull(index);
  }

  @override
  void replaceWhere(bool Function(T) test, T Function(T) copyFunction) {
    notify(SourceState.processing);
    for (int i = 0; i < _originalData.length; i++) {
      T? item = elementAt(i);
      if (item == null || !test(item)) continue;
      T newItem = copyFunction(item);
      _originalData[i] = newItem;
      break;
    }
    _filteredData = List.from(_originalData);
    notify(SourceState.complete);
  }

  @override
  void put(T item, bool Function(T) test) {
    notify(SourceState.processing);
    var index = _originalData.indexWhere(test);
    if (index < 0) {
      _originalData.add(item);
    } else {
      _originalData[index] = item;
    }
    _filteredData = List.from(_originalData);
    notify(SourceState.complete);
  }

  @override
  void putAll(Iterable<T> items, bool Function(T, T) test) {
    notify(SourceState.processing);
    for (T newItem in items) {
      var index = _originalData
          .indexWhere((existingItem) => test(existingItem, newItem));
      if (index < 0) {
        _originalData.add(newItem);
      } else {
        _originalData[index] = newItem;
      }
    }
    _filteredData = List.from(_originalData);
    notify(SourceState.complete);
  }

  @override
  void insert(T item, [int? index]) {
    notify(SourceState.processing);
    if (index != null && index >= 0 && index < _originalData.length) {
      _originalData.insert(index, item);
    } else {
      _originalData.add(item);
    }
    _filteredData = List.from(_originalData);
    notify(SourceState.complete);
  }

  @override
  void insertAll(Iterable<T> items, [int? index]) {
    notify(SourceState.processing);
    if (index != null && index >= 0 && index < _originalData.length) {
      _originalData.insertAll(index, items);
    } else {
      _originalData.addAll(items);
    }
    _filteredData = List.from(_originalData);
    notify(SourceState.complete);
  }

  @override
  void remove(T item) {
    notify(SourceState.processing);
    _originalData.remove(item);
    _filteredData.remove(item);
    notify(SourceState.complete);
  }

  @override
  void removeAt(int index) {
    notify(SourceState.processing);
    T item = _originalData.removeAt(index);
    _filteredData.remove(item);
    notify(SourceState.complete);
  }

  @override
  void removeAll() {
    notify(SourceState.processing);
    _originalData.clear();
    _filteredData.clear();
    notify(SourceState.complete);
  }

  @override
  void clear() {
    notify(SourceState.processing);
    _filteredData = List.from(_originalData);
    notify(SourceState.complete);
  }

  @override
  void reset() {
    _originalData.clear();
    _filteredData.clear();
    _page = 0;
    _hasMoreData = true;
    notify(SourceState.idle);
  }

  @override
  void dispose() {
    reset();
    _state.dispose();
  }

  @override
  void notify(SourceState state) {
    _state.value = state;
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