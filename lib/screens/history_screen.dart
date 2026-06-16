import 'package:flutter/material.dart';
import '../main.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _allItems    = [];
  List<HistoryItem> _filtered    = [];
  String            _activeFilter = 'All';
  bool              _isLoading   = true;

  final List<String> _filters = ['All', 'Today', 'Yesterday', 'Older'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await StorageService.getHistory();
    setState(() {
      _allItems  = items;
      _filtered  = items;
      _isLoading = false;
    });
  }

  // ── Filter by date ────────────────────────────────────────────────────────
  void _applyFilter(String filter) {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    setState(() {
      _activeFilter = filter;
      _filtered = _allItems.where((item) {
        final itemDate = DateTime(
          item.timestamp.year,
          item.timestamp.month,
          item.timestamp.day,
        );
        switch (filter) {
          case 'Today':
            return itemDate == today;
          case 'Yesterday':
            return itemDate == yesterday;
          case 'Older':
            return itemDate.isBefore(yesterday);
          default:
            return true; // All
        }
      }).toList();
    });
  }

  // ── Delete with confirmation ──────────────────────────────────────────────
  Future<void> _deleteItem(int filteredIndex) async {
    final item      = _filtered[filteredIndex];
    final realIndex = _allItems.indexOf(item);

    await StorageService.deleteHistoryItem(realIndex);

    setState(() {
      _allItems.removeAt(realIndex);
      _filtered.removeAt(filteredIndex);
    });
  }

  // ── Clear all ─────────────────────────────────────────────────────────────
  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear history',
            style: TextStyle(color: kText, fontSize: 16)),
        content: const Text('This will delete all your translation history.',
            style: TextStyle(color: kText, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: kText.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearHistory();
      setState(() {
        _allItems.clear();
        _filtered.clear();
      });
    }
  }

  // ── Format timestamp ──────────────────────────────────────────────────────
  String _formatTime(DateTime dt) {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final itemDate  = DateTime(dt.year, dt.month, dt.day);
    final diffDays  = today.difference(itemDate).inDays;

    final hour   = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final time   = '$hour:$minute';

    if (diffDays == 0) return 'Today, $time';
    if (diffDays == 1) return 'Yesterday, $time';
    return '${dt.day}/${dt.month}/${dt.year}, $time';
  }

  // ── Group items by date label ─────────────────────────────────────────────
  Map<String, List<MapEntry<int, HistoryItem>>> _grouped() {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final grouped   = <String, List<MapEntry<int, HistoryItem>>>{};

    for (var i = 0; i < _filtered.length; i++) {
      final item     = _filtered[i];
      final itemDate = DateTime(
          item.timestamp.year, item.timestamp.month, item.timestamp.day);
      final String label;

      if (itemDate == today) {
        label = 'Today';
      } else if (itemDate == yesterday) {
        label = 'Yesterday';
      } else {
        label =
            '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year}';
      }

      grouped.putIfAbsent(label, () => []).add(MapEntry(i, item));
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kAccent))
                : _filtered.isEmpty
                    ? _buildEmptyState()
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your past',
                style:
                    TextStyle(color: kText.withOpacity(0.5), fontSize: 12)),
            const Text('History',
                style: TextStyle(
                    color: kText,
                    fontSize: 22,
                    fontWeight: FontWeight.w600)),
          ]),
          if (_allItems.isNotEmpty)
            GestureDetector(
              onTap: _clearAll,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    color: kSurface, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded,
                    color: kText, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────
  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filters.map((f) {
          final active = f == _activeFilter;
          return GestureDetector(
            onTap: () => _applyFilter(f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? kAccent : kSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: active ? kBg : kText,
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Grouped list ──────────────────────────────────────────────────────────
  Widget _buildList() {
    final groups = _grouped();
    return RefreshIndicator(
      color: kAccent,
      backgroundColor: kCardBg,
      onRefresh: _loadHistory,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: groups.entries.map((group) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date label
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  group.key.toUpperCase(),
                  style: TextStyle(
                    color: kText.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              // Items in this group
              ...group.value.map((entry) =>
                  _buildCard(entry.value, entry.key)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Single history card ───────────────────────────────────────────────────
  Widget _buildCard(HistoryItem item, int index) {
    final fromCode = item.fromLang == 'Auto Detect'
        ? 'AUTO'
        : item.fromLang.substring(0, 2).toUpperCase();
    final toCode = item.toLang.substring(0, 2).toUpperCase();

    return Dismissible(
      key: Key('${item.timestamp.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteItem(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded,
            color: Colors.redAccent, size: 20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kSurface),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row — lang pair + time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$fromCode → $toCode',
                      style: const TextStyle(
                          color: kAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
                Text(
                  _formatTime(item.timestamp),
                  style: TextStyle(
                      color: kText.withOpacity(0.4), fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Input text
            Text(item.inputText,
                style: const TextStyle(color: kText, fontSize: 13)),
            const SizedBox(height: 4),
            // Output text
            Text(item.outputText,
                style: const TextStyle(
                    color: kAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              color: kText.withOpacity(0.2), size: 56),
          const SizedBox(height: 16),
          Text('No history yet',
              style: TextStyle(
                  color: kText.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Your translations will appear here',
              style: TextStyle(
                  color: kText.withOpacity(0.3), fontSize: 13)),
        ],
      ),
    );
  }
}