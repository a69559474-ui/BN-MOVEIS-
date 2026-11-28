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
  List shows = [];
  List<Map<String, String>> channels = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r1 = await http.get(Uri.https('://tvmaze.com', '/shows'));
      if (r1.statusCode == 200) shows = (json.decode(r1.body) as List).take(25).toList();
      final r2 = await http.get(Uri.https('iptv-org.github.io', '/iptv/categories/sports.m3u'));
      if (r2.statusCode == 200) {
        final lines = r2.body.split('\n');
        for (int i = 0; i < lines.length && channels.length < 25; i++) {
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
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _tab == 1
              ? ListView(children: channels.map((c) => ListTile(title: Text(c.values.first, style: const TextStyle(color: Colors.white)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InternalPlayer(title: c.values.first, url: c.values.last))))).toList())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Padding(padding: EdgeInsets.all(10), child: Text('قنوات الرياضة المباشرة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
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
                      const Padding(padding: EdgeInsets.all(10), child: Text('أحدث المسلسلات والأفلام', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                      SizedBox(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          children: shows.map((s) {
                            final m = s as Map;
                            final imgMap = m.containsKey('image') && m.values.first != null ? (m.values.firstWhere((v) => v is Map && v.containsKey('medium'), orElse: () => {}) as Map) : {};
                            final img = imgMap.values.isNotEmpty ? imgMap.values.first.toString() : '';
                            final name = m.values.elementAt(2).toString();
                            if (!img.startsWith('http')) return const SizedBox();
                            return GestureDetector(
                              onTap: () => launchUrl(Uri.https('://google.com', '/search', {'q': 'مشاهدة $name مترجم'}), mode: LaunchMode.externalApplication),
                              child: Container(width: 115, margin: const EdgeInsets.symmetric(horizontal: 5), child: Image.network(img, fit: BoxFit.cover)),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'القنوات'),
        ],
      ),
    );
  }
}




