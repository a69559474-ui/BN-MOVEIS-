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
  List allShows = [];
  List animeList = [];
  List<Map<String, String>> channels = [];
  List<Map<String, String>> favs = [];
  String q = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final gh = ['raw', 'githubusercontent', 'com'].join('.');
      final rMy = await http.get(Uri.https(gh, '/a69559474-ui/BN-MOVEIS-/main/channels.txt')).timeout(const Duration(seconds: 3));
      if (rMy.statusCode == 200) {
        for (var line in rMy.body.split('\n')) {
          if (line.contains('|')) {
            final p = line.split('|');
            channels.add({'n': p.first.trim(), 'u': p.last.trim()});
          }
        }
      }
    } catch (_) {}

    try {
      final h1 = ['api', 'tvmaze', 'com'].join('.');
      final r1 = await http.get(Uri.https(h1, '/shows')).timeout(const Duration(seconds: 5));
      if (r1.statusCode == 200) allShows = json.decode(r1.body) as List;
    } catch (_) {}

    try {
      final h2 = ['api', 'jikan', 'moe'].join('.');
      final r2 = await http.get(Uri.https(h2, '/v4/top/anime', {'limit': '25'})).timeout(const Duration(seconds: 5));
      if (r2.statusCode == 200) {
        final decoded = json.decode(r2.body) as Map;
        if (decoded.containsKey('data')) animeList = decoded.values.last as List;
      }
    } catch (_) {}

    try {
      final h3 = ['iptv-org', 'github', 'io'].join('.');
      final r3 = await http.get(Uri.https(h3, '/iptv/languages/ara.m3u')).timeout(const Duration(seconds: 5));
      if (r3.statusCode == 200) {
        final lines = r3.body.split('\n');
        for (int i = 0; i < lines.length && channels.length < 40; i++) {
          if (lines.elementAt(i).startsWith('#EXTINF:') && i + 1 < lines.length) {
            final u = lines.elementAt(i + 1).trim();
            if (u.startsWith('http')) channels.add({'n': lines.elementAt(i).split(',').last.trim(), 'u': u});
          }
        }
      }
    } catch (_) {}

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('BN MOVEIS', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
      body: loading ? const Center(child: CircularProgressIndicator(color: Colors.red)) : _view(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'البحث'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'التنزيلات'),
        ],
      ),
    );
  }

  Widget _view() {
    if (_tab == 1) {
      final f = channels.where((c) => c.values.first.toLowerCase().contains(q.toLowerCase())).toList();
      return Column(children: [
        Padding(padding: const EdgeInsets.all(10), child: TextField(onChanged: (v) => setState(() => q = v), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'ابحث عن قناة...', hintStyle: TextStyle(color: Colors.grey), prefixIcon: Icon(Icons.search, color: Colors.red), filled: true, fillColor: Color(0xFF1A1A1A)))),
        Expanded(child: ListView(children: f.map((c) => ListTile(title: Text(c.values.first, style: const TextStyle(color: Colors.white)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: c.values.first, url: c.values.last))))).toList())),
      ]);
    }
    if (_tab == 2) {
      return favs.isEmpty ? const Center(child: Text('المفضلة فارغة (اضغط مطولاً على أي بوستر)', style: TextStyle(color: Colors.grey))) : GridView.count(crossAxisCount: 3, children: favs.map((x) => Image.network(x.values.last, fit: BoxFit.cover)).toList());
    }
    if (_tab == 3) return const Center(child: Text('لا توجد تنزيلات حالياً', style: TextStyle(color: Colors.grey)));

    final mostWatched = allShows.take(15).toList();
    final movies = allShows.skip(15).take(15).toList();
    final series = allShows.skip(30).take(15).toList();
    final top20 = allShows.skip(45).take(20).toList();
    final viewersChoice = allShows.skip(65).take(15).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _sec('قنوات الرياضة العربية والمباشرة'),
          SizedBox(
            height: 95,
            child: ListView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              children: channels.map((c) => GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: c.values.first, url: c.values.last))),
                child: Container(width: 80, margin: const EdgeInsets.symmetric(horizontal: 4), child: Column(children: [const CircleAvatar(radius: 28, backgroundColor: Colors.red, child: Icon(Icons.tv, color: Colors.white)), Text(c.values.first, maxLines: 1, style: const TextStyle(color: Colors.white, fontSize: 11))])),
              )).toList(),
            ),
          ),
          _sec('الأكثر مشاهدة'),
          _tvRow(mostWatched),
          _sec('قسم الأفلام'),
          _tvRow(movies),
          _sec('قسم المسلسلات'),
          _tvRow(series),
          _sec('قسم الأنمي'),
          _animeRow(animeList),
          _sec('أفضل 20'),
          _tvRow(top20),
          _sec('اختيار المشاهدين'),
          _tvRow(viewersChoice),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _tvRow(List list) {
    return SizedBox(
      height: 175,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        children: list.map((s) {
          final m = s as Map;
          final imgMap = m.containsKey('image') ? (m.values.firstWhere((v) => v is Map && v.containsKey('medium'), orElse: () => {}) as Map) : {};
          final img = imgMap.values.isNotEmpty ? imgMap.values.first.toString() : '';
          final name = m.values.elementAt(2).toString();
          if (!img.startsWith('http')) return const SizedBox();
          final gHost = ['www', 'google', 'com'].join('.');
          return GestureDetector(
            onTap: () => launchUrl(Uri.https(gHost, '/search', {'q': 'مشاهدة $name مترجم'}), mode: LaunchMode.externalApplication),
            onLongPress: () => setState(() => favs.add({'t': name, 'i': img})),
            child: Container(width: 115, margin: const EdgeInsets.symmetric(horizontal: 5), child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(img, fit: BoxFit.cover))),
          );
        }).toList(),
      ),
    );
  }

  Widget _animeRow(List list) {
    return SizedBox(
      height: 175,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        children: list.map((a) {
          final m = a as Map;
          final imgs = m.containsKey('images') ? (m.values.firstWhere((v) => v is Map && v.containsKey('jpg'), orElse: () => {}) as Map) : {};
          final jpg = imgs.values.isNotEmpty ? (imgs.values.first as Map) : {};
          final img = jpg.values.isNotEmpty ? jpg.values.first.toString() : '';
          final name = m.containsKey('title') ? m.values.firstWhere((v) => v is String && v.length > 2 && !v.startsWith('http'), orElse: () => 'Anime').toString() : 'Anime';
          if (!img.startsWith('http')) return const SizedBox();
          final gHost = ['www', 'google', 'com'].join('.');
          return GestureDetector(
            onTap: () => launchUrl(Uri.https(gHost, '/search', {'q': 'مشاهدة انمي $name مترجم'}), mode: LaunchMode.externalApplication),
            onLongPress: () => setState(() => favs.add({'t': name, 'i': img})),
            child: Container(width: 115, margin: const EdgeInsets.symmetric(horizontal: 5), child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(img, fit: BoxFit.cover))),
          );
        }).toList(),
      ),
    );
  }

  Widget _sec(String t) => Padding(padding: const EdgeInsets.fromLTRB(12, 14, 12, 6), child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)));
}





