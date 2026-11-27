import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() => runApp(const BNMoveisApp());

class BNMoveisApp extends StatelessWidget {
  const BNMoveisApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BN MOVEIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFE50914),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF141414), elevation: 0),
      ),
      home: const ActivationScreen(),
    );
  }
}

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});
  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final String _secretCode = "BN2026";
  final String _whatsappNumber = "967737344714";

  void _verifyCode() {
    if (_codeController.text.trim() == _secretCode) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u0643\u0648\u062f \u0627\u0644\u062a\u0641\u0639\u064a\u0644 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d'), backgroundColor: Color(0xFFE50914)),
      );
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri url = Uri.https('wa.me', '/$_whatsappNumber', {'text': 'BN MOVEIS Subscription'});
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.play_circle_filled, size: 90, color: Color(0xFFE50914)),
              const SizedBox(height: 12),
              const Text('BN MOVEIS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const Text('\u0623\u0641\u0644\u0627\u0645 \u2022 \u0645\u0633\u0644\u0633\u0644\u0627\u062a \u2022 \u0623\u0646\u0645\u064a \u2022 \u0631\u064a\u0627\u0636\u0629', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 30),
              TextField(
                controller: _codeController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '\u0623\u062f\u062e\u0644 \u0643\u0648\u062f \u0627\u0644\u062a\u0641\u0639\u064a\u0644 \u0647\u0646\u0627',
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                  child: const Text('\u062f\u062e\u0648\u0644 \u0648\u062a\u0641\u0639\u064a\u0644 \u0627\u0644\u062d\u0633\u0627\u0628', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Text('\u0637\u0631\u0642 \u0627\u0644\u062f\u0641\u0639 \u0641\u064a \u0627\u0644\u064a\u0645\u0646', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
                    const SizedBox(height: 8),
                    const Text(
                      '\u062d\u0648\u0644 \u0642\u064a\u0645\u0629 \u0627\u0644\u0627\u0634\u062a\u0631\u0627\u0643 \u0639\u0628\u0631 \u0627\u0644\u0643\u0631\u064a\u0645\u064a \u0623\u0648 \u0627\u0644\u0646\u062c\u0645 \u0623\u0648 \u0627\u0644\u0639\u0645\u0642\u064a \u0623\u0648 \u0645\u062d\u0641\u0638\u0629 \u0643\u0627\u0634 \u062b\u0645 \u0623\u0631\u0633\u0644 \u0627\u0644\u0633\u0646\u062f \u0644\u0627\u0633\u062a\u0644\u0627\u0645 \u0627\u0644\u0643\u0648\u062f',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _openWhatsApp,
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text('\u0627\u0637\u0644\u0628 \u0627\u0644\u0643\u0648\u062f \u0639\u0628\u0631 \u0627\u0644\u0648\u0627\u062a\u0633\u0627\u0628', style: TextStyle(fontSize: 16, color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BN MOVEIS', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE50914),
          tabs: const [
            Tab(icon: Icon(Icons.live_tv), text: '\u0642\u0646\u0648\u0627\u062a \u0631\u064a\u0627\u0636\u064a\u0629'),
            Tab(icon: Icon(Icons.animation), text: '\u0623\u0646\u0645\u064a \u0645\u062a\u062c\u062f\u062f'),
            Tab(icon: Icon(Icons.movie), text: '\u0623\u0641\u0644\u0627\u0645 \u0648\u0645\u0633\u0644\u0633\u0644\u0627\u062a'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [LiveChannelsTab(), AnimeAutoTab(), MoviesGridTab()],
      ),
    );
  }
}

class LiveChannelsTab extends StatefulWidget {
  const LiveChannelsTab({super.key});
  @override
  State<LiveChannelsTab> createState() => _LiveChannelsTabState();
}

class _LiveChannelsTabState extends State<LiveChannelsTab> {
  List<Map<String, String>> channels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    try {
      final res = await http.get(Uri.parse('https://github.io'));
      if (res.statusCode == 200) {
        final lines = res.body.split('\n');
        List<Map<String, String>> loaded = [];
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('#EXTINF:') && i + 1 < lines.length && lines[i + 1].startsWith('http')) {
            loaded.add({'name': lines[i].split(',').last.trim(), 'url': lines[i + 1].trim()});
          }
        }
        setState(() { channels = loaded; isLoading = false; });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.4, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: channels.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(title: channels[index]['name']!, videoUrl: channels[index]['url']!))),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tv, size: 40, color: Color(0xFFE50914)),
              const SizedBox(height: 8),
              Text(channels[index]['name']!, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimeAutoTab extends StatefulWidget {
  const AnimeAutoTab({super.key});
  @override
  State<AnimeAutoTab> createState() => _AnimeAutoTabState();
}

class _AnimeAutoTabState extends State<AnimeAutoTab> {
  List animeList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnime();
  }

  Future<void> fetchAnime() async {
    try {
      final res = await http.get(Uri.parse('https://jikan.moe'));
      if (res.statusCode == 200) {
        setState(() { animeList = json.decode(res.body)['data']; isLoading = false; });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {




