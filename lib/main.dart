import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateNotifier()),
        ChangeNotifierProvider(create: (_) => AudioPlayerStateNotifier()),
      ],
      child: const NibanGyanApp(),
    ),
  );
}

// ==========================================
// THEME & CONSTANTS
// ==========================================
class SpiritualTheme {
  static const Color saffronPrimary = Color(0xE65100);
  static const Color saffronLight = Color(0xFFF3E0);
  static const Color deepGold = Color(0xFF8F00);
  static const Color darkCharcoal = Color(0x212121);
  static const Color sepiaBg = Color(0xFBF0D9);
  static const Color darkBg = Color(0x121212);
}

enum ReadingMode { light, sepia, dark }

// ==========================================
// STATE MANAGEMENT (PROVIDER)
// ==========================================
class AppStateNotifier extends ChangeNotifier {
  double _fontSize = 20.0;
  ReadingMode _readingMode = ReadingMode.light;
  final Set<int> _bookmarkedIds = {1, 3};

  double get fontSize => _fontSize;
  ReadingMode get readingMode => _readingMode;
  Set<int> get bookmarkedIds => _bookmarkedIds;

  void increaseFontSize() {
    if (_fontSize < 36.0) {
      _fontSize += 2.0;
      notifyListeners();
    }
  }

  void decreaseFontSize() {
    if (_fontSize > 14.0) {
      _fontSize -= 2.0;
      notifyListeners();
    }
  }

  void setReadingMode(ReadingMode mode) {
    _readingMode = mode;
    notifyListeners();
  }

  void toggleBookmark(int shlokaId) {
    if (_bookmarkedIds.contains(shlokaId)) {
      _bookmarkedIds.remove(shlokaId);
    } else {
      _bookmarkedIds.add(shlokaId);
    }
    notifyListeners();
  }

  bool isBookmarked(int shlokaId) => _bookmarkedIds.contains(shlokaId);
}

class AudioPlayerStateNotifier extends ChangeNotifier {
  bool _isPlaying = false;
  String _currentTrack = "सत्तनाम सुमिरन एवं पाठ";

  bool get isPlaying => _isPlaying;
  String get currentTrack => _currentTrack;

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }
}

// ==========================================
// MAIN APPLICATION ENTRY
// ==========================================
class NibanGyanApp extends StatelessWidget {
  const NibanGyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'निर्वाण ग्यान',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SpiritualTheme.saffronPrimary,
          primary: SpiritualTheme.saffronPrimary,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.tiroDevanagariHindiTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const MainLayoutScreen(),
    );
  }
}

// ==========================================
// MAIN LAYOUT & NAVIGATION
// ==========================================
class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BookSectionsScreen(),
    CalendarEventsScreen(),
    AboutSangatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PersistentAudioPlayerBar(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: SpiritualTheme.saffronPrimary,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'गृह',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'पोथी',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'कैलेंडर',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'साध संगति',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HOME SCREEN (मुख्य पृष्ठ)
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const dailyQuote =
        "कड़ी मेहनत और ईमानदारी से शुद्ध धन्धे की कमाई करके शुद्ध भोजन करना और शुद्ध कपड़े पहिनना। एकाग्रता से सत्त का ध्यान, सत्य बोलना और सच्ची करतूत करना।\n\n- उदादास बाबा";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'निर्वाण ग्यान',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: HindiSearchDelegate(),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            color: SpiritualTheme.saffronLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: SpiritualTheme.deepGold.withOpacity(0.4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.format_quote, color: SpiritualTheme.saffronPrimary),
                      SizedBox(width: 8),
                      Text(
                        'दैनिक उपदेश',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: SpiritualTheme.saffronPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    dailyQuote,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Share.share(dailyQuote);
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('WhatsApp पर शेयर करें'),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SpiritualTheme.saffronPrimary, SpiritualTheme.deepGold],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: const [
                Text(
                  'आगामी विशेष वार्षिक भंडारा',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'फागुन सुदी 13 भंडारा',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'स्थान: ऊँची बैठक चौकी (फर्रुखाबाद-दिल्ली)',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildNavCard(
                context,
                title: 'भूमिका एवं महिमा',
                icon: Icons.menu_book,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookSectionsScreen()),
                ),
              ),
              _buildNavCard(
                context,
                title: 'ज्ञान के उपदेश',
                icon: Icons.lightbulb_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReaderScreen(sectionTitle: 'ज्ञान के उपदेश')),
                ),
              ),
              _buildNavCard(
                context,
                title: 'सामाजिक नियम',
                icon: Icons.gavel,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SocialRulesScreen()),
                ),
              ),
              _buildNavCard(
                context,
                title: 'वार्षिक कैलेंडर',
                icon: Icons.calendar_month,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarEventsScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: SpiritualTheme.saffronPrimary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// BOOK SECTIONS / CHAPTER LIST SCREEN
// ==========================================
class BookSectionsScreen extends StatelessWidget {
  const BookSectionsScreen({super.key});

  final List<String> chapters = const [
    "भूमिका एवं सत्तनाम महिमा",
    "कड़ा १: अवगत आसन रहे समाई",
    "कड़ा २: धंधा कोई बताया नाही",
    "कड़ा ३: आप कहै मांड फेर बसावा",
    "कड़ा ४: बारह पुरुषा के मन पड़ा भिरांता",
    "कड़ा ५: पंडौ करी जहानसै चरचा",
    "कड़ा ६: ईसफ मोयां मता उपाया",
    "अश्लोक संग्रह (१ - ११)",
    "मात्रा संग्रह एवं बंदगी",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ग्रंथ की अनुक्रमणिका')),
      body: ListView.separated(
        itemCount: chapters.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: SpiritualTheme.saffronLight,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: SpiritualTheme.saffronPrimary),
              ),
            ),
            title: Text(
              chapters[index],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReaderScreen(sectionTitle: chapters[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// BOOK READER SCREEN (पाठ्य स्क्रीन)
// ==========================================
class ReaderScreen extends StatelessWidget {
  final String sectionTitle;
  const ReaderScreen({super.key, required this.sectionTitle});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateNotifier>(context);

    Color bgColor;
    Color textColor;

    switch (state.readingMode) {
      case ReadingMode.sepia:
        bgColor = SpiritualTheme.sepiaBg;
        textColor = const Color(0xFF3E2723);
        break;
      case ReadingMode.dark:
        bgColor = SpiritualTheme.darkBg;
        textColor = const Color(0xFFE0E0E0);
        break;
      case ReadingMode.light:
      default:
        bgColor = Colors.white;
        textColor = SpiritualTheme.darkCharcoal;
        break;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(sectionTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => state.increaseFontSize(),
            tooltip: 'अक्षर बढ़ाएं (A+)',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => state.decreaseFontSize(),
            tooltip: 'अक्षर घटाएं (A-)',
          ),
          PopupMenuButton<ReadingMode>(
            icon: const Icon(Icons.palette_outlined),
            onSelected: (mode) => state.setReadingMode(mode),
            itemBuilder: (context) => const [
              PopupMenuItem(value: ReadingMode.light, child: Text('Light Mode')),
              PopupMenuItem(value: ReadingMode.sepia, child: Text('Sepia Mode')),
              PopupMenuItem(value: ReadingMode.dark, child: Text('Dark Mode')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 80),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '॥ सत्त अवगत ॥',
                    style: TextStyle(
                      fontSize: state.fontSize * 0.9,
                      fontWeight: FontWeight.bold,
                      color: SpiritualTheme.saffronPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      state.isBookmarked(1) ? Icons.bookmark : Icons.bookmark_border,
                      color: SpiritualTheme.saffronPrimary,
                    ),
                    onPressed: () => state.toggleBookmark(1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "अवगत आशन रहे समाई ॥ ओंकार भी होता नाही ॥१॥\n"
                "छाया माया होती नाही ॥ आप रहे निरंतर माही ॥२॥\n"
                "धरन अकास पवन और पानी ॥ ये तो ना होते सहदानी ॥३॥\n"
                "धरन अकास की इच्छा आनी ॥ रसना सै चेला किया बिनानी ॥४॥\n"
                "आप रहे निरंतर धारी ॥ सौंप करी चेला कौ सारी ॥५॥",
                style: TextStyle(
                  fontSize: state.fontSize,
                  height: 1.8,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SOCIAL RULES SCREEN (साध संगति नियम)
// ==========================================
class SocialRulesScreen extends StatelessWidget {
  const SocialRulesScreen({super.key});

  final List<String> rules = const [
    "१. एक मालिक या उसके नाम पर झुकना, किसी को सलाम नहीं करना।",
    "२. पत्थर पूजा निषेध है।",
    "३. कोई भी मादक वस्तु नहीं खाना, पान, भांग, सिगरेट और सब प्रकार के नशे का त्याग।",
    "४. सादे वस्त्र, सादे भोजन, सादगी से जीवन व्यतीत करना।",
    "५. एक स्त्री का एक विवाह और एक पुरुष का एक विवाह (समानता का दर्जा)।",
    "६. पूर्णमासी के दिन संगत का इकट्ठा होना, ज्ञान का विचार करना, प्रसाद का काम होना।",
    "७. साल में एक बार भंडारे का होना (फागुन सुदी १३ में)।",
    "८. चोरी, जारी, जुआं, नशा करने वाले का चढ़ावा नहीं लगता।"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('साध संगति के सामाजिक नियम')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rules.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                rules[index],
                style: const TextStyle(fontSize: 17, height: 1.5),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// EVENTS & CALENDAR SCREEN
// ==========================================
class CalendarEventsScreen extends StatelessWidget {
  const CalendarEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('कैलेंडर व सूचनाएं')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'वार्षिक भंडारा एवं प्रमुख तिथियां',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            color: SpiritualTheme.saffronLight,
            child: const ListTile(
              leading: Icon(Icons.star, color: SpiritualTheme.saffronPrimary),
              title: Text('फागुन सुदी १३ भंडारा', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('स्थान: ऊँची बैठक चौकी (फर्रुखाबाद-दिल्ली)\nसब साध संगति का इकट्ठा होना एवं ज्ञान विचार।'),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'मासिक पूर्णमासी संगति तिथियां',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDateTile('भाद्रपद पूर्णमासी', 'संगत एकत्रित ज्ञान चर्चा'),
          _buildDateTile('आश्विन पूर्णमासी', 'संगत एकत्रित ज्ञान चर्चा'),
          _buildDateTile('कार्तिक पूर्णमासी', 'विशेष सत्संग एवं ज्ञान विचार'),
        ],
      ),
    );
  }

  Widget _buildDateTile(String title, String subtitle) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event, color: SpiritualTheme.saffronPrimary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

// ==========================================
// ABOUT SADH SANGAT SCREEN
// ==========================================
class AboutSangatsScreen extends StatelessWidget {
  const AboutSangatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('साध संगति परिचय')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ऊँची बैठक चौकी (फर्रुखाबाद-दिल्ली)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SpiritualTheme.saffronPrimary),
              ),
              SizedBox(height: 12),
              Text(
                'इस धर्म ग्रन्थ (पोथी) का नाम निर्वाण ग्यान है यानी मोक्ष (मुक्त) होने का ज्ञान। ज्ञान का अनुभव होने के लिए इस ग्रन्थ में सत्तनाम की भक्ति बताई है और सत्तनाम परखने के लिए सन्तों के शब्द आए हैं।\n\nजो समाज इस ज्ञान को मानती है, उनको सतनामी साध कहते हैं।',
                style: TextStyle(fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MINI AUDIO PLAYER WIDGET
// ==========================================
class PersistentAudioPlayerBar extends StatelessWidget {
  const PersistentAudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final playerState = Provider.of<AudioPlayerStateNotifier>(context);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: SpiritualTheme.darkCharcoal,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.audiotrack, color: SpiritualTheme.deepGold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              playerState.currentTrack,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              playerState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: SpiritualTheme.saffronPrimary,
              size: 36,
            ),
            onPressed: () => playerState.togglePlayPause(),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HINDI SEARCH DELEGATE
// ==========================================
class HindiSearchDelegate extends SearchDelegate {
  final List<String> searchDatabase = const [
    "सत्तनाम महिमा",
    "उदादास बाबा के उपदेश",
    "फागुन सुदी १३ भंडारा",
    "सामाजिक नियम",
    "अवगत आसन रहे समाई",
    "पूर्णमासी संगति"
  ];

  @override
  String get searchFieldLabel => 'खोजें (जैसे: सत्तनाम, नियम)...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('परिणाम: "$query"'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = searchDatabase.where((item) => item.contains(query)).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}
