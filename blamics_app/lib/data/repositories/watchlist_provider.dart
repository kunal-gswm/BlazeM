import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WatchlistItem {
  final String id; // e.g. "IPO:Swiggy" or "STOCK:TCS"
  final String title;
  final String type; // "IPO" or "STOCK"
  final String? subtitle;

  WatchlistItem({
    required this.id,
    required this.title,
    required this.type,
    this.subtitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'subtitle': subtitle,
    };
  }

  factory WatchlistItem.fromMap(Map<String, dynamic> map) {
    return WatchlistItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      subtitle: map['subtitle'],
    );
  }
}

class WatchlistNotifier extends Notifier<List<WatchlistItem>> {
  static const _boxName = 'blamics_watchlist';
  late Box _box;

  @override
  List<WatchlistItem> build() {
    _box = Hive.box(_boxName);
    return _loadFromBox();
  }

  List<WatchlistItem> _loadFromBox() {
    final List<dynamic> items = _box.get('items', defaultValue: <dynamic>[]);
    return items.map((e) => WatchlistItem.fromMap(jsonDecode(e.toString()))).toList();
  }

  void toggleItem(WatchlistItem item) {
    final current = state;
    final exists = current.any((e) => e.id == item.id);
    
    if (exists) {
      state = current.where((e) => e.id != item.id).toList();
    } else {
      state = [...current, item];
    }
    
    _box.put('items', state.map((e) => jsonEncode(e.toMap())).toList());
  }
  
  bool isSaved(String id) {
    return state.any((e) => e.id == id);
  }
}

final watchlistProvider = NotifierProvider<WatchlistNotifier, List<WatchlistItem>>(() {
  return WatchlistNotifier();
});
