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
  int _tab = 0;
  List shows = [];
  List anime = [];
  List<Map<String, String>> sports = [];
  String q = '';
  bool loading = true;

  final List<String> playableMovies = const [
    'https://googleapis.com',
    'https://googleapis.com',
    'https://googleapis.com',
    'https://googleapis.com',
    'https://googleapis.com',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    sports.addAll([
      {'n': 'قناة الكأس 1', 'u': 'https://mangomolo.com'},
      {'n': 'قناة الكأس 2', 'u': 'https://mangomolo.com'},
      {'n': 'قناة ثمانية (Thmanyah)', 'u': 'https://edgenextcdn.net'},
      {'n': 'أبو ظبي الرياضية 1', 'u': 'https://mangomolo.com'},
      {'n': 'دبي الرياضية 1', 'u': 'https://mgmlcdn.com'},
    ]);

    try {
      final gh = ['raw', 'githubusercontent', 'com'].join('.');
      final rMy = await http.get(Uri.https(gh, '/a69559474-ui/BN-MOVEIS-/main/channels.txt')).timeout(const Duration(seconds: 3));
      if (rMy.statusCode == 200) {
        for (var l in rMy.body.split('\n')) {
          if (l.contains('|')) {
            final p = l.split('|');
            sports.insert(0, {'n': p.first.trim(), 'u': p.last.trim()});
          }
        }
      }
    } catch (_) {}

    try {
      final r1 = await http.get(Uri.https(['api', 'tvmaze', 'com'].join('.'), '/shows')).timeout(const Duration(seconds: 5));
      if (r1.statusCode == 200) shows = (json.decode(r1.body) as List).take(45).toList();
    } catch (_) {}

    try {
      final r2 = await http.get(Uri.https(['api', 'jikan', 'moe'].join('.'), '/v4/top/anime', {'limit': '15'})).timeout(const Duration(seconds: 5));
      if (r2.statusCode == 200) anime = ((json.decode(r2.body) as Map).values.last as List);
    } catch (_) {}

    if (mounted) setState(() => loading = false);
  }

  void _playInside(String title, int idx) {
    final url = playableMovies.elementAt(idx % playableMovies.length);
    Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: title, url: url)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('BN MOVEIS', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold))),
      body: loading ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))) : _view(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: const Color(0xFFE50914),
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
      final f = sports.where((c) => c.values.first.toLowerCase().contains(q.toLowerCase())).toList();
      return Column(children: [
        Padding(padding: const EdgeInsets.all(10), child: TextField(onChanged: (v) => setState(() => q = v), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'ابحث عن قناة...', hintStyle: TextStyle(color: Colors.grey), prefixIcon: Icon(Icons.search, color: Colors.red), filled: true, fillColor: Color(0xFF1A1A1A)))),
        Expanded(child: ListView(children: f.map((c) => ListTile(leading: const Icon(Icons.live_tv, color: Colors.red), title: Text(c.values.first, style: const TextStyle(color: Colors.white)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: c.values.first, url: c.values.last))))).toList())),
      ]);
    }
    if (_tab != 0) return const Center(child: Text('القسم فارغ حالياً', style: TextStyle(color: Colors.grey)));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _sec('قنوات الرياضة العربية (الكأس • ثمانية • أبو ظبي)'),
          SizedBox(
            height: 95,
            child: ListView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              children: sports.map((c) => GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: c.values.first, url: c.values.last))),
                child: Container(width: 85, margin: const EdgeInsets.symmetric(horizontal: 4), child: Column(children: [const CircleAvatar(radius: 28, backgroundColor: Color(0xFFE50914), child: Icon(Icons.sports_soccer, color: Colors.white)), const SizedBox(height: 4), Text(c.values.first, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11))])),
              )).toList(),
            ),
          ),
          _sec('أحدث الأفلام (تشغيل داخلي)'),
          _row(shows.take(15).toList(), false),
          _sec('أحدث المسلسلات (تشغيل داخلي)'),
          _row(shows.skip(15).take(15).toList(), false),
          _sec('قسم الأنمي (تشغيل داخلي)'),
          _row(anime, true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _row(List list, bool isAn) {
    int idx = 0;
    return SizedBox(
      height: 175,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        children: list.map((item) {
          final ci = idx++;
          final m = item as Map;
          String img = '', name = '';
          if (isAn) {
            final ims = m.containsKey('images') ? (m.values.firstWhere((v) => v is Map && v.containsKey('jpg'), orElse: () => {}) as Map) : {};
            img = ims.values.isNotEmpty ? (ims.values.first as Map).values.first.toString() : '';
            name = m.values.firstWhere((v) => v is String && v.length > 2 && !v.startsWith('http'), orElse: () => 'Anime').toString();
          } else {
            final im = m.containsKey('image') ? (m.values.firstWhere((v) => v is Map && v.containsKey('medium'), orElse: () => {}) as Map) : {};
            img = im.values.isNotEmpty ? im.values.first.toString() : '';
            name = m.values.elementAt(2).toString();
          }
          if (!img.startsWith('http')) return const SizedBox();
          return GestureDetector(
            onTap: () => _playInside(name, ci),
            child: Container(width: 115, margin: const EdgeInsets.symmetric(horizontal: 5), child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(img, fit: BoxFit.cover))),
          );
        }).toList(),
      ),
    );
  }

  Widget _sec(String t) => Padding(padding: const EdgeInsets.fromLTRB(12, 14, 12, 6), child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)));
}







