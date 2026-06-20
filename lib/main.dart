import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'screens/language_selector_screen.dart';
import 'services/translation_service.dart';
import 'services/storage_service.dart';
import 'screens/history_screen.dart';
import 'screens/saved_screen.dart';

// ─── Colour Palette ───────────────────────────────────────────────────────────
const Color kBg        = Color(0xFF091413); // darkest – app background
const Color kSurface   = Color(0xFF285A48); // cards, chips, nav bar
const Color kAccent    = Color(0xFF408A71); // buttons, active icons, highlights
const Color kText      = Color(0xFFB0E4CC); // all text and icons
const Color kInputBg   = Color(0xFF0F1F1D); // text-field fill
const Color kCardBg    = Color(0xFF1A2F2B); // translation output card

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
        fontFamily: 'Inter',         // add Inter to pubspec.yaml (see Step 1)
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
          bodySmall:  TextStyle(color: kText, fontSize: 12),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    HistoryPage(),   // placeholder – build next
    SavedPage(),     // placeholder – build next
    ProfilePage(),   // placeholder – build next
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
      {'icon': Icons.home_rounded,          'label': 'Home'},
      {'icon': Icons.history_rounded,       'label': 'History'},
      {'icon': Icons.favorite_rounded,      'label': 'Saved'},
      {'icon': Icons.person_rounded,        'label': 'Profile'},
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
  // Change this once you add auth/profile (Step 8)
  final String _userName = 'Yashasvi';

  String _fromLang     = 'Auto Detect';  // always auto, user cannot change this
  String _toLang       = 'Select language';
  String _inputText    = '';
  String _outputText   = '';
  bool   _isLoading    = false;   // shows spinner while API call is running
  String _errorMessage = '';      // shows error if translation fails
  bool   _isSaved      = false;   // whether current output is in favourites

  final TextEditingController _inputCtrl = TextEditingController();

  // ── Voice input state ─────────────────────────────────────────────────────
  final stt.SpeechToText _speech     = stt.SpeechToText();
  bool _isListening                  = false;
  bool _speechAvailable              = false;

  // Recent translations — will be replaced with storage in Step 6
  final List<Map<String, String>> _recent = [
    {'pair': 'EN → TA', 'text': 'Hello world'},
    {'pair': 'EN → HI', 'text': 'Good morning'},
    {'pair': 'FR → EN', 'text': 'Bonjour'},
  ];

  void _clearAll() {
    setState(() {
      _toLang      = 'Select language';
      _inputCtrl.clear();
      _inputText   = '';
      _outputText  = '';
      _errorMessage = '';
    });
  }

  Future<void> _onTranslate() async {
    // Guard: nothing typed
    if (_inputText.trim().isEmpty) return;

    // Guard: output language not selected
    if (_toLang == 'Select language') {
      setState(() => _errorMessage = 'Please select a language to translate to.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading    = true;
      _errorMessage = '';
      _outputText   = '';
    });

    final result = await TranslationService.translate(
      text:     _inputText,
      fromLang: _fromLang,
      toLang:   _toLang,
    );

    if (!mounted) return; // widget was disposed while waiting

    setState(() {
      _isLoading = false;

      if (result.hasError) {
        _errorMessage = result.errorMessage!;
      } else {
        _outputText   = result.translatedText;
        _errorMessage = '';
        _isSaved      = false; // new translation, not yet favourited

        // Save to persistent history
        StorageService.saveToHistory(HistoryItem(
          inputText:  _inputText,
          outputText: result.translatedText,
          fromLang:   _fromLang,
          toLang:     _toLang,
          timestamp:  DateTime.now(),
        ));

        // Add to recent list (keep max 10, most recent first)
        final fromCode = _fromLang == 'Auto Detect' ? 'AUTO' : _fromLang.substring(0, 2).toUpperCase();
        final toCode   = _toLang.substring(0, 2).toUpperCase();
        _recent.insert(0, {'pair': '$fromCode → $toCode', 'text': _inputText});
        if (_recent.length > 10) _recent.removeLast();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // Initialize speech recognizer once when page loads
  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        setState(() => _isListening = false);
      },
    );
    setState(() {});
  }

  // Toggle listening on / off
  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      setState(() => _errorMessage = 'Microphone not available on this device.');
      return;
    }

    if (_isListening) {
      // ── Stop listening ───────────────────────────────────────────────────
      await _speech.stop();
      setState(() => _isListening = false);

      // Auto-translate what was captured
      if (_inputText.trim().isNotEmpty) {
        await _onTranslate();
      }
    } else {
      // ── Start listening ──────────────────────────────────────────────────
      setState(() {
        _isListening  = true;
        _errorMessage = '';
        _outputText   = '';
        _inputCtrl.clear();
        _inputText    = '';
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _inputText = result.recognizedWords;
            _inputCtrl.text = result.recognizedWords;
            // Move cursor to end of text
            _inputCtrl.selection = TextSelection.fromPosition(
              TextPosition(offset: _inputCtrl.text.length),
            );
          });
        },
        listenFor:    const Duration(seconds: 30),
        pauseFor:     const Duration(seconds: 3),
        localeId:     'en_US',
        listenMode:   stt.ListenMode.confirmation,
      );
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _speech.stop();
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
          style: const TextStyle(color: kText, fontSize: 22, fontWeight: FontWeight.w600),
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
        _inputText  = '';
        _outputText = '';
      });
    }
  }

  Widget _buildLanguageRow() {
    return Row(
      children: [
        // ── Left chip: Auto Detect (not tappable, just a display) ──────────
        Expanded(child: _autoDetectChip()),
        const SizedBox(width: 8),
        // ── Arrow icon (not a swap button anymore, just visual) ─────────────
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(color: kSurface, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_forward_rounded, color: kAccent, size: 18),
        ),
        const SizedBox(width: 8),
        // ── Right chip: tappable, user picks output language ─────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => _pickLanguage(isFrom: false),
            child: _langChip(_toLang),
          ),
        ),
      ],
    );
  }

  // Static auto-detect display chip (no arrow, no tap)
  Widget _autoDetectChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kSurface, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_fix_high_rounded, color: kAccent, size: 14),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Auto Detect',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: kAccent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
        border: Border.all(
          color: _isListening ? Colors.redAccent.withOpacity(0.6) : kSurface,
          width: _isListening ? 1.5 : 1.0,
        ),
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
              // ── Mic button — pulses red when listening ──────────────────
              GestureDetector(
                onTap: _toggleListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.redAccent.withOpacity(0.15) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: _isListening
                        ? Border.all(color: Colors.redAccent, width: 1.5)
                        : null,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListening ? Colors.redAccent : kAccent,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // ── Listening status text ────────────────────────────────────
              if (_isListening)
                Expanded(
                  child: Text(
                    'Listening...',
                    style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 12),
                  ),
                )
              else
                _actionIcon(Icons.desktop_mac_outlined, onTap: () {}),
              const Spacer(),
              // ── Send button — disabled while listening ───────────────────
              GestureDetector(
                onTap: _isListening ? null : _onTranslate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _isListening ? kSurface : kAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: _isListening ? kText.withOpacity(0.3) : kBg,
                    size: 16,
                  ),
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
        border: Border.all(
          color: _errorMessage.isNotEmpty ? Colors.redAccent.withOpacity(0.5) : kSurface,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: _isLoading
                // ── Loading state ──────────────────────────────────────────
                ? Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Translating...',
                        style: TextStyle(color: kText.withOpacity(0.5), fontSize: 14),
                      ),
                    ],
                  )
                : _errorMessage.isNotEmpty
                    // ── Error state ────────────────────────────────────────
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.redAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                        ],
                      )
                    // ── Normal / translated state ──────────────────────────
                    : Text(
                        _outputText.isEmpty ? 'Translation appears here' : _outputText,
                        style: TextStyle(
                          color: _outputText.isEmpty
                              ? kText.withOpacity(0.35)
                              : kText,
                          fontSize: 14,
                        ),
                      ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _actionIcon(Icons.copy_rounded,              onTap: () {}),
              const SizedBox(width: 14),
              _actionIcon(Icons.volume_up_outlined,        onTap: () {}),
              const SizedBox(width: 14),
              _actionIcon(Icons.favorite_border_rounded,   onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mode buttons ─────────────────────────────────────────────────────────
  Widget _buildModeButtons() {
    final modes = [
      {'icon': Icons.mic_rounded,      'label': 'Voice'},
      {'icon': Icons.camera_alt_rounded,'label': 'Camera'},
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
                  Text(m['label'] as String,
                      style: const TextStyle(color: kText, fontSize: 11)),
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
        Text('Recent',
            style: TextStyle(
              color: kText.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _recent.map((item) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kSurface),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['pair']!,
                        style: TextStyle(color: kText.withOpacity(0.5), fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(item['text']!,
                        style: const TextStyle(
                          color: kText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        )),
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
        decoration: const BoxDecoration(color: kSurface, shape: BoxShape.circle),
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
  Widget build(BuildContext context) => const _PlaceholderPage(title: 'History');
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(title: 'Saved');
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(title: 'Profile');
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(color: kText, fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }
}