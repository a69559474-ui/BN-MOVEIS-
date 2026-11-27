import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'netflix_home.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: LockScreen()));

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final c = TextEditingController();
  bool checking = false;

  Future<void> _verify() async {
    final input = c.text.trim();
    if (input.isEmpty) return;
    setState(() => checking = true);
    try {
      final url = Uri.parse('https://githubusercontent.com');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final validCodes = res.body.split('\n').map((e) => e.trim()).toList();
        if (validCodes.contains(input)) {
          if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NetflixHome()));
          return;
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u0627\u0644\u0643\u0648\u062f \u063a\u064a\u0631 \u0635\u062d\u064a\u062d'), backgroundColor: Colors.red),
        );
      }
    } catch (_) {}
    if (mounted) setState(() => checking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('BN MOVEIS', style: TextStyle(fontSize: 34, color: Color(0xFFE50914), fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 25),
            TextField(
              controller: c,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: '\u0623\u062f\u062e\u0644 \u0643\u0648\u062f \u0627\u0644\u062a\u0641\u0639\u064a\u0644',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                onPressed: checking ? null : _verify,
                child: checking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('\u062f\u062e\u0648\u0644 \u0627\u0644\u062a\u0637\u0628\u064a\u0642', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
              onPressed: () => launchUrl(Uri.parse('https://wa.me'), mode: LaunchMode.externalApplication),
              child: const Text('\u0627\u0634\u062a\u0631\u0627\u0643 \u0648\u0627\u062a\u0633\u0627\u0628 (\u0627\u0644\u0643\u0631\u064a\u0645\u064a / \u0627\u0644\u0646\u062c\u0645 / \u0643\u0627\u0634)', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}





