import 'dart:convert';

enum HistoryType { translation, summary, askAi }

class HistoryItem {
  final String id;
  final String originalText;
  final String resultText;
  final HistoryType type;
  final DateTime timestamp;

  HistoryItem({
    required this.id,
    required this.originalText,
    required this.resultText,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalText': originalText,
      'resultText': resultText,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'] ?? '',
      originalText: map['originalText'] ?? '',
      resultText: map['resultText'] ?? '',
      type: HistoryType.values.firstWhere((e) => e.name == map['type'],
          orElse: () => HistoryType.translation),
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryItem.fromJson(String source) =>
      HistoryItem.fromMap(json.decode(source));
}
