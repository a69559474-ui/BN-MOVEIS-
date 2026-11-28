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
    _autoFetchAll();
  }

  Future<void> _autoFetchAll() async {
    try {
      final tvHost = ['api', 'tvmaze', 'com'].join('.');
      final resTv = await http.get(Uri.https(tvHost, '/shows'));
      if (resTv.statusCode == 200) {
        final allShows = json.decode(resTv.body) as List;
        seriesList = allShows.take(20).toList();
      }

      final apiHost = ['api', 'jikan', 'moe'].join('.');
      final resMv = await http.get(Uri.https(apiHost, '/v4/top/anime', {'type': 'movie', 'limit': '20'}));
      if (resMv.statusCode == 200) moviesList = json.decode(resMv.body)['data'];

      final resAn = await http.get(Uri.https(apiHost, '/v4/seasons/now', {'limit': '20'}));
      if (resAn.statusCode == 200) animeList = json.decode(resAn.body)['data'];

      final iptvHost = ['iptv-org', 'github', 'io'].join('.');
      final resCh = await http.get(Uri.https(iptvHost, '/iptv/categories/sports.m3u'));
      if (resCh.statusCode == 200) {
        final lines = resCh.body.split('\n');
        for (int i = 0; i < lines.length && channels.length < 30; i++) {
          if (lines[i].startsWith('#EXTINF:') && i + 1 < lines.length && lines[i + 1].startsWith('http')) {
            channels.add({'name': lines[i].split(',').last.trim(), 'url': lines[i + 1].trim()});
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  void _playChannel(String title, String url) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: title, url: url)));
  }

  void _watchTitle(String title) {
    final q = Uri.encodeComponent('مشاهدة $title مترجم اون لاين');
    final gHost = ['www', 'google', 'com'].join('.');
    launchUrl(Uri.https(gHost, '/search', {'q': q}), mode: LaunchMode.externalApplication);
  }

  void _toggleFav(String title, String img) {
    setState(() {
      final exists = favorites.any((e) => e['title'] == title);
      if (exists) {
        favorites.removeWhere((e) => e['title'] == title);
      } else {
        favorites.add({'title': title, 'img': img});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('BN MOVEIS', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => loading = true);
              _autoFetchAll();
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : _buildCurrentTab(),
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

  Widget _buildCurrentTab() {
    if (_tab == 1) return _buildSearchTab();
    if (_tab == 2) return _buildFavTab();
    if (_tab == 3) {
      return const Center(child: Text('\u0644\u0627 \u062a\u0648\u062c\u062f \u062a\u0646\u0632\u064a\u0644\u0627\u062a \u062d\u0627\u0644\u064a\u0627\u064b', style: TextStyle(color: Colors.grey, fontSize: 16)));
    }

    final heroShow = seriesList.isNotEmpty ? seriesList.first : null;
    final heroImg = heroShow != null && heroShow['image'] != null ? heroShow['image']['original'] : '';
    final heroTitle = heroShow != null ? heroShow['name'] : 'BN MOVEIS LIVE';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (heroImg.isNotEmpty)
                Image.network(heroImg, height: 350, width: double.infinity, fit: BoxFit.cover)
              else
                Container(height: 250, width: double.infinity, color: const Color(0xFF1A1A1A), child: const Icon(Icons.movie, color: Colors.red, size: 80)),
              Container(height: 350, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black]))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(heroTitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                          onPressed: () => _watchTitle(heroTitle),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('\u0645\u0634\u0627\u0647\u062f\u0629 \u0627\u0644\u0622\u0646', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        if (heroImg.isNotEmpty)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                            onPressed: () => _toggleFav(heroTitle, heroImg),
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
          _title('\u0642\u0646\u0648\u0627\u062a \u0627\u0644\u0631\u064a\u0627\u0636\u0629 \u0627\u0644\u0645\u0628\u0627\u0634\u0631\u0629'),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: channels.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _playChannel(channels[i]['name']!, channels[i]['url']!),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1A1A1A), border: Border.all(color: const Color(0xFFE50914), width: 2)),
                        child: const Icon(Icons.sports_soccer, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(channels[i]['name']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _title('\u0623\u062d\u062f\u062b \u0627\u0644\u0645\u0633\u0644\u0633\u0644\u0627\u062a \u0627\u0644\u0639\u0627\u0644\u0645\u064a\u0629'),
          SizedBox(
            height: 185,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: seriesList.length,
              itemBuilder: (_, i) {
                final show = seriesList[i];
                final img = show['image'] != null ? show['image']['medium'] : '';
                if (img.isEmpty) return const SizedBox();
                return GestureDetector(
                  onTap: () => _watchTitle(show['name'] ?? ''),
                  onLongPress: () => _toggleFav(show['name'] ?? '', img),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(img, fit: BoxFit.cover)),
                  ),
                );
              },
            ),
          ),
          _title('\u0623\u062d\u062f\u062b \u0627\u0644\u0623\u0641\u0644\u0627\u0645'),
          SizedBox(
            height: 185,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,

