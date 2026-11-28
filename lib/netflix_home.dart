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
  List<Map<String, String>> channels = [];
  String q = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final h1 = ['api', 'tvmaze', 'com'].join('.');
      final r1 = await http.get(Uri.https(h1, '/shows')).timeout(const Duration(seconds: 5));
      if (r1.statusCode == 200) shows = (json.decode(r1.body) as List).take(60).toList();
    } catch (_) {}
    try {
      final h2 = ['iptv-org', 'github', 'io'].join('.');
      final r2 = await http.get(Uri.https(h2, '/iptv/languages/ara.m3u')).timeout(const Duration(seconds: 5));
      if (r2.statusCode == 200) {
        final lines = r2.body.split('\n');
        for (int i = 0; i < lines.length && channels.length < 30; i++) {
          if (lines.elementAt(i).startsWith('#EXTINF:') && i + 1 < lines.length) {
            final u = lines.elementAt(i + 1).trim();
            if (u.startsWith('http')) channels.add({'n': lines.elementAt(i).split(',').last.trim(), 'u': u});
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  void _open(String title) {
    final vid = ['://googleapis.com', 'gtv-videos-bucket', 'sample', 'BigBuckBunny.mp4'].join('/');
    Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: title, url: 'https://$vid')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: loading ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))) : _body(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF141414),
        selectedItemColor: const Color(0xFFE50914),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'البحث'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'المكتبة'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_download), label: 'التنزيلات'),
        ],
      ),
    );
  }

  Widget _body() {
    if (_tab == 1) {
      final f = channels.where((c) => c.values.first.toLowerCase().contains(q.toLowerCase())).toList();
      return SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v) => setState(() => q = v), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'ابحث عن قناة...', hintStyle: TextStyle(color: Colors.grey), prefixIcon: Icon(Icons.search, color: Colors.red), filled: true, fillColor: Color(0xFF1A1A1A)))),
        Expanded(child: ListView(children: f.map((c) => ListTile(title: Text(c.values.first, style: const TextStyle(color: Colors.white)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: c.values.first, url: c.values.last))))).toList())),
      ]));
    }
    if (_tab != 0) return const Center(child: Text('القسم فارغ حالياً', style: TextStyle(color: Colors.grey)));

    final hero = shows.isNotEmpty ? (shows.first as Map) : {};
    final hImg = hero.containsKey('image') && hero.values.any((v) => v is Map && v.containsKey('original')) ? (hero.values.firstWhere((v) => v is Map && v.containsKey('original')) as Map).values.last.toString() : '';
    final hName = hero.isNotEmpty ? hero.values.elementAt(2).toString() : 'BN MOVEIS';

    return SingleChildScrollView(child: Column(children: [
      Stack(children: [
        if (hImg.startsWith('http')) Image.network(hImg, height: 360, width: double.infinity, fit: BoxFit.cover) else Container(height: 360, color: const Color(0xFF151515)),
        Container(height: 360, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black45, Color(0xFF0A0A0A)]))),
        SafeArea(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFE50914), borderRadius: BorderRadius.circular(4)), child: const Text('BN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
          const SizedBox(height: 30),
          Text(hName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Column(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFF5C518), borderRadius: BorderRadius.circular(5)), child: const Text('9.0 • 2026', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
              const SizedBox(height: 10),
              ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), foregroundColor: Colors.white), onPressed: () => _open(hName), icon: const Icon(Icons.play_arrow), label: const Text('شاهد الآن')),
            ]),
            if (hImg.startsWith('http')) ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(hImg, width: 100, height: 145, fit: BoxFit.cover)),
          ]),
        ]))),
      ]),
      _sec('مباريات اليوم'),
      SizedBox(height: 85, child: ListView(scrollDirection: Axis.horizontal, reverse: true, children: [_match('ريال مدريد', 'برشلونة', '22:00'), _match('إلتشي', 'أتلتيكو', '20:30')])),
      _sec('قنوات البث المباشر'),
      SizedBox(height: 90, child: ListView(scrollDirection: Axis.horizontal, reverse: true, children: channels.map((c) => GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: c.values.first, url: c.values.last))), child: Container(width: 80, margin: const EdgeInsets.symmetric(horizontal: 4), child: Column(children: [Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF151515), border: Border.all(color: Colors.red, width: 2)), child: const Icon(Icons.live_tv, color: Colors.white)), Text(c.values.first, maxLines: 1, style: const TextStyle(color: Colors.white, fontSize: 11))])))).toList())),
      _sec('أفلام عربية وأجنبية'),
      _row(shows.take(15).toList(), '1080p'),
      _sec('مسلسلات عربية وتركية'),
      _row(shows.skip(15).take(15).toList(), 'يعرض الآن'),
      _sec('أفضل الإنمي المترجم'),
      _row(shows.skip(30).take(15).toList(), 'مترجم'),
      const SizedBox(height: 20),
    ]));
  }

  Widget _sec(String t) => Padding(padding: const EdgeInsets.fromLTRB(14, 16, 14, 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('عرض الكل', style: TextStyle(color: Colors.red, fontSize: 12)), Row(children: [Text(t, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Container(width: 4, height: 18, color: Colors.red)])]));

  Widget _match(String t1, String t2, String time) => GestureDetector(onTap: () => _open('$t1 - $t2'), child: Container(width: 195, margin: const EdgeInsets.symmetric(horizontal: 6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red)), child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Align(alignment: Alignment.centerLeft, child: Text('▶ مشاهدة', style: TextStyle(color: Colors.red, fontSize: 10))), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text(t2, style: const TextStyle(color: Colors.white, fontSize: 12)), Text(time, style: const TextStyle(color: Color(0xFFF5C518), fontWeight: FontWeight.bold)), Text(t1, style: const TextStyle(color: Colors.white, fontSize: 12))])])));

  Widget _row(List list, String b) => SizedBox(height: 175, child: ListView(scrollDirection: Axis.horizontal, reverse: true, children: list.map((s) {
    final m = s as Map;
    final im = m.containsKey('image') ? (m.values.firstWhere((v) => v is Map && v.containsKey('medium'), orElse: () => {}) as Map) : {};
    final img = im.values.isNotEmpty ? im.values.first.toString() : '';
    final name = m.values.elementAt(2).toString();
    if (!img.startsWith('http')) return const SizedBox();
    return GestureDetector(onTap: () => _open(name), child: Container(width: 115, margin: const EdgeInsets.symmetric(horizontal: 5), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(img, width: 115, height: 175, fit: BoxFit.cover)), Positioned(top: 5, right: 5, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: Text(b, style: const TextStyle(color: Colors.white, fontSize: 9))))])));
  }).toList()));
}






