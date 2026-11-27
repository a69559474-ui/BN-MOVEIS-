
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: BNApp()));

class BNApp extends StatefulWidget {
  const BNApp({super.key});
  @override
  State<BNApp> createState() => _BNAppState();
}

class _BNAppState extends State<BNApp> {
  final c = TextEditingController();
  bool ok = false;

  @override
  Widget build(BuildContext context) {
    if (ok) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('BN MOVEIS'), backgroundColor: Colors.red[900]),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _btn('القنوات الرياضية والمباشرة', Icons.live_tv, 'https://github.io'),
            _btn('أحدث الأنميات المترجمة', Icons.animation, 'https://myanimelist.net'),
            _btn('أفلام ومسلسلات متجددة', Icons.movie, 'https://imdb.com'),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('BN MOVEIS', style: TextStyle(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: c, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Code: BN2026', hintStyle: TextStyle(color: Colors.grey))),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () { if (c.text.trim() == 'BN2026') setState(() => ok = true); },
              child: const Text('تفعيل الدخول', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => launchUrl(Uri.parse('https://wa.me'), mode: LaunchMode.externalApplication),
              child: const Text('اشتراك واتساب (الكريمي / النجم / كاش)', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(String t, IconData i, String u) => Card(
    color: Colors.grey[900],
    child: ListTile(
      leading: Icon(i, color: Colors.red),
      title: Text(t, style: const TextStyle(color: Colors.white)),
      onTap: () => launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication),
    ),
  );
}





