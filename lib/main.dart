import 'package:flutter/material.dart';
import 'screens/language_selector_screen.dart';

// ─── Colour Palette ───────────────────────────────────────────────────────────
const Color kBg = Color(0xFF091413); // darkest – app background
const Color kSurface = Color(0xFF285A48); // cards, chips, nav bar
const Color kAccent = Color(0xFF408A71); // buttons, active icons, highlights
const Color kText = Color(0xFFB0E4CC); // all text and icons
const Color kInputBg = Color(0xFF0F1F1D); // text-field fill
const Color kCardBg = Color(0xFF1A2F2B); // translation output card

void main() {
  runApp(const TranslatorApp());
}

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unbound',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBg,
        fontFamily: 'Inter', // add Inter to pubspec.yaml (see Step 1)
        colorScheme: const ColorScheme.dark(
          background: kBg,
          surface: kSurface,
          primary: kAccent,
          onPrimary: kBg,
          onBackground: kText,
          onSurface: kText,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: kText, fontSize: 14),
          bodySmall: TextStyle(color: kText, fontSize: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kInputBg,
          hintStyle: TextStyle(color: kText.withOpacity(0.35), fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kSurface),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kSurface),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kAccent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// ─── Main screen with bottom nav ─────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Swap out placeholders as you build each page
  final List<Widget> _pages = const [
    HomePage(),
    HistoryPage(), // placeholder – build next
    SavedPage(), // placeholder – build next
    ProfilePage(), // placeholder – build next
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.history_rounded, 'label': 'History'},
      {'icon': Icons.favorite_rounded, 'label': 'Saved'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1C1A),
        border: Border(top: BorderSide(color: Color(0xFF1F3530))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = i == _currentIndex;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i]['icon'] as IconData,
                      color: active ? kAccent : kText.withOpacity(0.4),
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: active ? kAccent : kText.withOpacity(0.4),
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── HOME PAGE ────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Change this once you add auth/profile
  final String _userName = 'Yashasvi';

  String _fromLang = 'Select language';
  String _toLang = 'Select language';
  String _inputText = '';
  String _outputText = '';

  final TextEditingController _inputCtrl = TextEditingController();

  // Recent translations list
  final List<Map<String, String>> _recent = const [
    {'pair': 'EN → TA', 'text': 'Hello world'},
    {'pair': 'EN → HI', 'text': 'Good morning'},
    {'pair': 'FR → EN', 'text': 'Bonjour'},
  ];

  void _swapLanguages() {
    setState(() {
      final tmp = _fromLang;
      _fromLang = _toLang;
      _toLang = tmp;
      _inputCtrl.clear();
      _inputText = '';
      _outputText = '';
    });
  }

  void _onTranslate() {
    // TODO: Replace with real translation API call (Step 5)
    setState(() {
      _outputText = _inputText.isEmpty
          ? ''
          : '[ Translation of "$_inputText" from $_fromLang to $_toLang ]';
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTopBar(),
            const SizedBox(height: 16),
            _buildLanguageRow(),
            const SizedBox(height: 12),
            _buildInputBox(),
            const SizedBox(height: 10),
            _buildOutputBox(),
            const SizedBox(height: 14),
            _buildModeButtons(),
            const SizedBox(height: 18),
            _buildRecentSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────────────
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildTopBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: TextStyle(color: kText.withOpacity(0.5), fontSize: 12),
        ),
        Text(
          _userName,
          style: const TextStyle(
            color: kText,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Language row ─────────────────────────────────────────────────────────
  Future<void> _pickLanguage({required bool isFrom}) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageSelectorScreen(
          currentLanguage: isFrom ? _fromLang : _toLang,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        if (isFrom) {
          _fromLang = result;
        } else {
          _toLang = result;
        }
        _inputCtrl.clear();
        _inputText = '';
        _outputText = '';
      });
    }
  }

  Widget _buildLanguageRow() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickLanguage(isFrom: true),
            child: _langChip(_fromLang),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _swapLanguages,
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: kAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.swap_horiz_rounded, color: kBg, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickLanguage(isFrom: false),
            child: _langChip(_toLang),
          ),
        ),
      ],
    );
  }

  Widget _langChip(String label) {
    final isPlaceholder = label == 'Select language';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kAccent, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isPlaceholder ? kText.withOpacity(0.45) : kText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: kText, size: 16),
        ],
      ),
    );
  }

  // ── Input box ─────────────────────────────────────────────────────────────
  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kSurface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _inputCtrl,
            maxLines: 3,
            minLines: 3,
            style: const TextStyle(color: kText, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Type to translate...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => setState(() => _inputText = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _actionIcon(Icons.mic_none_rounded, onTap: () {}),
              const SizedBox(width: 14),
              _actionIcon(Icons.desktop_mac_outlined, onTap: () {}),
              const Spacer(),
              GestureDetector(
                onTap: _onTranslate,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: kBg, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Output box ────────────────────────────────────────────────────────────
  Widget _buildOutputBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kSurface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Text(
              _outputText.isEmpty ? 'Translation appears here' : _outputText,
              style: TextStyle(
                color: _outputText.isEmpty ? kText.withOpacity(0.35) : kText,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _actionIcon(Icons.copy_rounded, onTap: () {}),
              const SizedBox(width: 14),
              _actionIcon(Icons.volume_up_outlined, onTap: () {}),
              const SizedBox(width: 14),
              _actionIcon(Icons.favorite_border_rounded, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mode buttons ─────────────────────────────────────────────────────────
  Widget _buildModeButtons() {
    final modes = [
      {'icon': Icons.mic_rounded, 'label': 'Voice'},
      {'icon': Icons.camera_alt_rounded, 'label': 'Camera'},
      {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Chat'},
    ];
    return Row(
      children: modes.map((m) {
        return Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(m['icon'] as IconData, color: kText, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    m['label'] as String,
                    style: const TextStyle(color: kText, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Recent translations ───────────────────────────────────────────────────
  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent',
          style: TextStyle(
            color: kText.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _recent.map((item) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kSurface),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['pair']!,
                      style: TextStyle(
                        color: kText.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['text']!,
                      style: const TextStyle(
                        color: kText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _iconCircle(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: kSurface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: kText, size: 18),
      ),
    );
  }

  Widget _actionIcon(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: kAccent, size: 20),
    );
  }
}

// ─── PLACEHOLDER PAGES (build these next) ────────────────────────────────────
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderPage(title: 'History');
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(title: 'Saved');
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderPage(title: 'Profile');
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: kText,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
