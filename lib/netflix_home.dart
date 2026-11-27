import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'player.dart';

class NetflixHome extends StatefulWidget {
  const NetflixHome({super.key});
  @override
  State<NetflixHome> createState() => _NetflixHomeState();
}

class _NetflixHomeState extends State<NetflixHome> {
  List animeList = [];
  List<Map<String, String>> channels = [];
  bool loading = true;

  final List<Map<String, String>> movies = const [
    {'title': 'Big Buck Bunny 4K', 'img': 'https://wikimedia.org', 'url': 'https://googleapis.com'},
    {'title': 'Sintel Fantasy', 'img': 'https://wikimedia.org', 'url': 'https://googleapis.com'},
    {'title': 'Tears of Steel', 'img': 'https://wikimedia.org', 'url': 'https://googleapis.com'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final resAn = await http.get(Uri.parse('https://jikan.moe'));
      if (resAn.statusCode == 200) animeList = json.decode(resAn.body)['data'];
      final resCh = await http.get(Uri.parse('https://github.io'));
      if (resCh.statusCode == 200) {
        final lines = resCh.body.split('\n');
        for (int i = 0; i < lines.length && channels.length < 25; i++) {
          if (lines[i].startsWith('#EXTINF:') && i + 1 < lines.length && lines[i + 1].startsWith('http')) {
            channels.add({'name': lines[i].split(',').last.trim(), 'url': lines[i + 1].trim()});
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  void _play(String title, String url) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: title, url: url)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('BN MOVEIS', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.network(movies['img']!, height: 350, width: double.infinity, fit: BoxFit.cover),
                      Container(height: 350, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black]))),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                          onPressed: () => _play(movies['title']!, movies['url']!),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('\u062a\u0634\u063a\u064a\u0644 \u0627\u0644\u0639\u0631\u0636 \u0627\u0644\u0645\u0645\u064a\u0632', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  _title('\u0642\u0646\u0648\u0627\u062a \u0631\u064a\u0627\u0636\u064a\u0629 \u0648\u0645\u0628\u0627\u0634\u0631\u0629'),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      itemCount: channels.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => _play(channels[i]['name']!, channels[i]['url']!),
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1A1A1A), border: Border.all(color: const Color(0xFFE50914), width: 2)),
                                child: const Icon(Icons.live_tv, color: Colors.white),
                              ),
                              const SizedBox(height: 5),
                              Text(channels[i]['name']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _title('\u0623\u0641\u0644\u0627\u0645 \u0648\u0645\u0633\u0644\u0633\u0644\u0627\u062a'),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      itemCount: movies.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => _play(movies[i]['title']!, movies[i]['url']!),
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(movies[i]['img']!, fit: BoxFit.cover)),
                        ),
                      ),
                    ),
                  ),
                  _title('\u0623\u0646\u0645\u064a \u0645\u062a\u062c\u062f\u062f'),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      itemCount: animeList.length,
                      itemBuilder: (_, i) {
                        final item = animeList[i];
                        return GestureDetector(
                          onTap: () => _play(item['title'] ?? 'Anime', movies['url']!),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(item['images']['jpg']['image_url'], fit: BoxFit.cover)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      );
}

