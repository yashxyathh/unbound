import 'package:flutter/material.dart';

// ── Import your colours from main.dart ──────────────────────────────────────
// Once you move colours to constants/colors.dart (Step 3 of roadmap),
// replace this import with: import '../constants/colors.dart';
import '../main.dart';

// ── Full list of supported languages ────────────────────────────────────────
const List<Map<String, String>> kLanguages = [
  {'name': 'Afrikaans', 'code': 'AF'},
  {'name': 'Arabic', 'code': 'AR'},
  {'name': 'Bengali', 'code': 'BN'},
  {'name': 'Bulgarian', 'code': 'BG'},
  {'name': 'Chinese', 'code': 'ZH'},
  {'name': 'Croatian', 'code': 'HR'},
  {'name': 'Czech', 'code': 'CS'},
  {'name': 'Danish', 'code': 'DA'},
  {'name': 'Dutch', 'code': 'NL'},
  {'name': 'English', 'code': 'EN'},
  {'name': 'Finnish', 'code': 'FI'},
  {'name': 'French', 'code': 'FR'},
  {'name': 'German', 'code': 'DE'},
  {'name': 'Greek', 'code': 'EL'},
  {'name': 'Gujarati', 'code': 'GU'},
  {'name': 'Hebrew', 'code': 'HE'},
  {'name': 'Hindi', 'code': 'HI'},
  {'name': 'Hungarian', 'code': 'HU'},
  {'name': 'Indonesian', 'code': 'ID'},
  {'name': 'Italian', 'code': 'IT'},
  {'name': 'Japanese', 'code': 'JA'},
  {'name': 'Kannada', 'code': 'KN'},
  {'name': 'Korean', 'code': 'KO'},
  {'name': 'Malay', 'code': 'MS'},
  {'name': 'Malayalam', 'code': 'ML'},
  {'name': 'Marathi', 'code': 'MR'},
  {'name': 'Nepali', 'code': 'NE'},
  {'name': 'Norwegian', 'code': 'NO'},
  {'name': 'Odia', 'code': 'OR'},
  {'name': 'Persian', 'code': 'FA'},
  {'name': 'Polish', 'code': 'PL'},
  {'name': 'Portuguese', 'code': 'PT'},
  {'name': 'Punjabi', 'code': 'PA'},
  {'name': 'Romanian', 'code': 'RO'},
  {'name': 'Russian', 'code': 'RU'},
  {'name': 'Sanskrit', 'code': 'SA'},
  {'name': 'Serbian', 'code': 'SR'},
  {'name': 'Sinhala', 'code': 'SI'},
  {'name': 'Slovak', 'code': 'SK'},
  {'name': 'Spanish', 'code': 'ES'},
  {'name': 'Swahili', 'code': 'SW'},
  {'name': 'Swedish', 'code': 'SV'},
  {'name': 'Tamil', 'code': 'TA'},
  {'name': 'Telugu', 'code': 'TE'},
  {'name': 'Thai', 'code': 'TH'},
  {'name': 'Turkish', 'code': 'TR'},
  {'name': 'Ukrainian', 'code': 'UK'},
  {'name': 'Urdu', 'code': 'UR'},
  {'name': 'Vietnamese', 'code': 'VI'},
];

// ── Recently used languages (hardcoded for now, will come from storage later)
const List<Map<String, String>> kRecentLanguages = [
  {'name': 'English', 'code': 'EN'},
  {'name': 'Tamil', 'code': 'TA'},
  {'name': 'Hindi', 'code': 'HI'},
];

class LanguageSelectorScreen extends StatefulWidget {
  /// The language that is currently selected (so we can tick it in the list)
  final String currentLanguage;

  const LanguageSelectorScreen({super.key, required this.currentLanguage});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, String>> _filtered = kLanguages;

  // ── Filter list as user types ─────────────────────────────────────────────
  void _onSearch(String query) {
    setState(() {
      _filtered = kLanguages
          .where(
            (lang) => lang['name']!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            // Only show Recent section when search box is empty
            if (_searchCtrl.text.isEmpty) _buildRecentSection(context),
            _buildDivider(),
            if (_searchCtrl.text.isEmpty) _buildSectionLabel('ALL LANGUAGES'),
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildLanguageList(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: kSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: kText, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select language',
                style: TextStyle(color: kText.withOpacity(0.5), fontSize: 11),
              ),
              const Text(
                'All Languages',
                style: TextStyle(
                  color: kText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: kText, fontSize: 14),
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search language...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: kText.withOpacity(0.4),
            size: 18,
          ),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    _onSearch('');
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: kText.withOpacity(0.4),
                    size: 16,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // ── Recent section ────────────────────────────────────────────────────────
  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('RECENT'),
        ...kRecentLanguages.map((lang) => _buildLanguageTile(context, lang)),
      ],
    );
  }

  // ── All languages list ────────────────────────────────────────────────────
  Widget _buildLanguageList(BuildContext context) {
    return ListView.builder(
      itemCount: _filtered.length,
      itemBuilder: (context, index) =>
          _buildLanguageTile(context, _filtered[index]),
    );
  }

  // ── Single language row ───────────────────────────────────────────────────
  Widget _buildLanguageTile(BuildContext context, Map<String, String> lang) {
    final isSelected = lang['name'] == widget.currentLanguage;

    return GestureDetector(
      onTap: () {
        // Send selected language back to HomePage
        Navigator.pop(context, lang['name']);
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            // Language code badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? kAccent : kSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                lang['code']!,
                style: TextStyle(
                  color: isSelected ? kBg : kText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Language name
            Expanded(
              child: Text(
                lang['name']!,
                style: TextStyle(
                  color: isSelected ? kAccent : kText,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            // Tick if selected
            if (isSelected)
              const Icon(Icons.check_rounded, color: kAccent, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Text(
        label,
        style: TextStyle(
          color: kText.withOpacity(0.5),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(
    height: 1,
    color: const Color(0xFF1A2F2B),
    margin: const EdgeInsets.symmetric(vertical: 4),
  );

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: kText.withOpacity(0.3),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No language found',
            style: TextStyle(color: kText.withOpacity(0.4), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
