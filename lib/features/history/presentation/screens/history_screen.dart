import 'package:flutter/material.dart';
import 'package:tokam/core/constants/colors.dart';
import 'package:tokam/features/history/data/history_repository.dart';
import 'package:tokam/features/history/domain/models/history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryRepository _repository = HistoryRepository();
  List<HistoryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final items = await _repository.getItems();
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    await _repository.clearHistory();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Recent Scans'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _items.isEmpty ? null : _clearHistory,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No history found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  item.type == HistoryType.translation
                                      ? Icons.translate
                                      : Icons.auto_awesome,
                                  size: 16,
                                  color: AppColors.primaryAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.type == HistoryType.translation
                                      ? 'Translation'
                                      : 'Summary',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.originalText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.resultText,
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
