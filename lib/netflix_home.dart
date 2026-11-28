import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'player.dart';

class NetflixHome extends StatefulWidget {
  const NetflixHome({super.key});
  @override
  State<NetflixHome> createState() => _NetflixHomeState();
}

class _NetflixHomeState extends State<NetflixHome> {
  int _tab = 0;
  List animeList = [];
  List seriesList = [];
  List moviesList = [];
  List<Map<String, String>> channels = [];
  List<Map<String, String>> favorites = [];
  String searchQuery = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final tv = ['api', 'tvmaze', 'com'].join('.');
      final r1 = await http.get(Uri.https(tv, '/shows'));
      if (r1.statusCode == 200) {
        seriesList = (json.decode(r1.body) as List).take(20).toList();
      }
      final jk = ['api', 'jikan', 'moe'].join('.');
      final r2 = await http.get(Uri.https(jk, '/v4/top/anime', {'type': 'movie', 'limit': '20'}));
      if (r2.statusCode == 200) moviesList = json.decode(r2.body)['data'];
      final r3 = await http.get(Uri.https(jk, '/v4/seasons/now', {'limit': '20'}));
      if (r3.statusCode == 200) animeList = json.decode(r3.body)['data'];
      final ip = ['iptv-org', 'github', 'io'].join('.');
      final r4 = await http.get(Uri.https(ip, '/iptv/categories/sports.m3u'));
      if (r4.statusCode == 200) {
        final lines = r4.body.split('\n');
        for (int i = 0; i < lines.length && channels.length < 30; i++) {
          if (lines[i].startsWith('#EXTINF:') && i + 1 < lines.length && lines[i + 1].startsWith('http')) {
            channels.add({'name': lines[i].split(',').last.trim(), 'url': lines[i + 1].trim()});
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  void _play(String t, String u) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: t, url: u)));
  }

  void _watch(String t) {
    final q = Uri.encodeComponent('مشاهدة $t مترجم');
    final g = ['www', 'google', 'com'].join('.');
    launchUrl(Uri.https(g, '/search', {'q': q}), mode: LaunchMode.externalApplication);
  }

  void _fav(String t, String img) {
    setState(() {
      if (favorites.any((e) => e['title'] == t)) {
        favorites.removeWhere((e) => e['title'] == t);
      } else {
        favorites.add({'title': t, 'img': img});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('BN MOVEIS', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => loading = true);
              _fetchData();
            },
          ),
        ],
      ),
      body: loading ? const Center(child: CircularProgressIndicator(color: Colors.red)) : _body(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: const Color(0xFFE50914),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '\u0627\u0644\u0631\u0626\u064a\u0633\u064a\u0629'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '\u0627\u0644\u0628\u062d\u062b'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '\u0627\u0644\u0645\u0641\u0636\u0644\u0629'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: '\u0627\u0644\u062a\u0646\u0632\u064a\u0644\u0627\u062a'),
        ],
      ),
    );
  }

  Widget _body() {
    if (_tab == 1) return _searchTab();
    if (_tab == 2) return _favTab();
    if (_tab == 3) return const Center(child: Text('\u0644\u0627 \u062a\u0648\u062c\u062f \u062a\u0646\u0632\u064a\u0644\u0627\u062a', style: TextStyle(color: Colors.grey)));

    final hero = seriesList.isNotEmpty ? seriesList.first : null;
    final hImg = (hero != null && hero['image'] != null) ? hero['image']['original'] : '';
    final hTitle = hero != null ? hero['name'] : 'BN MOVEIS';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (hImg.isNotEmpty) Image.network(hImg, height: 320, width: double.infinity, fit: BoxFit.cover)
              else Container(height: 220, color: const Color(0xFF1A1A1A), child: const Center(child: Icon(Icons.movie, color: Colors.red, size: 70))),
              Container(height: 320, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black]))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text(hTitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                          onPressed: () => _watch(hTitle),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('\u0645\u0634\u0627\u0647\u062f\u0629'),
                        ),
                        const SizedBox(width: 10),
                        if (hImg.isNotEmpty)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                            onPressed: () => _fav(hTitle, hImg),
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('\u0627\u0644\u0645\u0641\u0636\u0644\u0629'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          _sec('\u0642\u0646\u0648\u0627\u062a \u0627\u0644\u0631\u064a\u0627\u0636\u0629'),
          SizedBox(
            height: 105,
            child: ListView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              children: channels.map((c) => GestureDetector(
                onTap: () => _play(c['name']!, c['url']!),
                child: Container(
                  width: 85,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1A1A1A), border: Border.all(color: Colors.red, width: 2)),
                        child: const Icon(Icons.sports_soccer, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(c['name']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
          _sec('\u0627\u0644\u0645\u0633\u0644\u0633\u0644\u0627\u062a \u0627\u0644\u0639\u0627\u0644\u0645\u064a\u0629'),
          _posterRow(seriesList, true),
          _sec('\u0623\u062d\u062f\u062b \u0627\u0644\u0623\u0641\u0644\u0627\u0645'),
          _posterRow(moviesList, false),
          _sec('\u0627\u0644\u0623\u0646\u0645\u064a \u0627\u0644\u0645\u0648\u0633\u0645\u064a'),
          _posterRow(animeList, false),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _posterRow(List items, bool isTv) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        children: items.map((e) {
          final img = isTv ? (e['image'] != null ? e['image']['medium'] : '') : e['images']['jpg']['image_url'];
          final title = isTv ? (e['name'] ?? '') : (e['title'] ?? '');
          if (img.isEmpty) return const SizedBox();
          return GestureDetector(
            onTap: () => _watch(title),
            onLongPress: () => _fav(title, img),
            child: Container(
              width: 115,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(img, fit: BoxFit.cover)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _searchTab() {
    final res = channels.where((c) => c['name']!.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '\u0627\u0628\u062d\u062b \u0639\u0646 \u0642\u0646\u0627\u0629...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.red),
              filled: true,



