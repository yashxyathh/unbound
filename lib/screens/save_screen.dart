import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../main.dart';
import '../services/storage_service.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<SavedItem> _items     = [];
  bool            _isLoading = true;
  final FlutterTts _tts      = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final items = await StorageService.getFavorites();
    setState(() {
      _items     = items;
      _isLoading = false;
    });
  }

  Future<void> _remove(SavedItem item) async {
    await StorageService.removeFavorite(item.uniqueKey);
    setState(() => _items.removeWhere((e) => e.uniqueKey == item.uniqueKey));
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kAccent))
                : _items.isEmpty
                    ? _buildEmptyState()
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your collection',
              style: TextStyle(color: kText.withOpacity(0.5), fontSize: 12)),
          const Text('Saved',
              style: TextStyle(
                  color: kText, fontSize: 22, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: kAccent,
      backgroundColor: kCardBg,
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: _items.length,
        itemBuilder: (context, index) => _buildCard(_items[index]),
      ),
    );
  }

  Widget _buildCard(SavedItem item) {
    final fromCode = item.fromLang == 'Auto Detect'
        ? 'AUTO'
        : item.fromLang.substring(0, 2).toUpperCase();
    final toCode = item.toLang.substring(0, 2).toUpperCase();

    return Dismissible(
      key: Key(item.uniqueKey),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _remove(item),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                Icon(Icons.favorite_rounded, color: kAccent, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.inputText,
                style: const TextStyle(color: kText, fontSize: 13)),
            const SizedBox(height: 4),
            Text(item.outputText,
                style: const TextStyle(
                    color: kAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _speak(item.outputText),
                  child: Icon(Icons.volume_up_outlined,
                      color: kText.withOpacity(0.6), size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded,
              color: kText.withOpacity(0.2), size: 56),
          const SizedBox(height: 16),
          Text('Nothing saved yet',
              style: TextStyle(
                  color: kText.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Tap the heart on a translation to save it',
              style: TextStyle(
                  color: kText.withOpacity(0.3), fontSize: 13)),
        ],
      ),
    );
  }
}