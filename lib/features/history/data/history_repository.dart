import 'package:shared_preferences/shared_preferences.dart';
import 'package:tokam/features/history/domain/models/history_item.dart';

class HistoryRepository {
  static const String _key = 'tokam_history_items';

  Future<void> saveItem(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getItems();
    items.insert(0, item); // Latest first
    
    // Keep only last 50 items to prevent bloat
    if (items.length > 50) {
      items.removeLast();
    }
    
    final jsonList = items.map((e) => e.toJson()).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Future<List<HistoryItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((e) => HistoryItem.fromJson(e)).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
